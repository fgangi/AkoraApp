import 'package:akora_app/core/navigation/app_router.dart';
import 'package:akora_app/core/services/notification_service.dart';
import 'package:akora_app/data/sources/local/app_database.dart';
import 'package:akora_app/features/therapy_management/models/therapy_enums.dart';
import 'package:akora_app/features/therapy_management/models/therapy_setup_model.dart';
import 'package:akora_app/main.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show TimeOfDay;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class TherapySummaryScreen extends StatefulWidget {
  final TherapySetupData? setupData;
  final Therapy? initialTherapy;

  const TherapySummaryScreen({
    super.key,
    this.setupData,
    this.initialTherapy,
  }) : assert(setupData != null || initialTherapy != null);

  @override
  State<TherapySummaryScreen> createState() => _TherapySummaryScreenState();
}

class _TherapySummaryScreenState extends State<TherapySummaryScreen> {
  late TherapySetupData currentData;

  @override
  void initState() {
    super.initState();
    currentData = widget.setupData ?? TherapySetupData.fromTherapy(widget.initialTherapy!);
  }

  String _formatFrequency(BuildContext context) {
    // Join all the times with a comma, e.g., "08:30, 20:00"
    final timesString = currentData.reminderTimes.join(', ');

    switch (currentData.selectedFrequency) {
      case TakingFrequency.onceDaily:
        return 'Ogni giorno alle $timesString';
      case TakingFrequency.twiceDaily:
        return 'Due volte al giorno ($timesString)';
      case TakingFrequency.onceWeekly:
        return 'Una volta a settimana alle $timesString';
      case TakingFrequency.other:
        return 'Frequenza personalizzata';
    }
  }

  Future<void> _launchEditScreen(String routeName) async {
    currentData.isSingleEditMode = true;
    final result = await context.pushNamed(routeName, extra: currentData);
    if (result is TherapySetupData && mounted) {
      result.isSingleEditMode = false;
      setState(() {
        currentData = result;
      });
    }
  }

  Future<void> _saveAndConfirm(BuildContext context) async {
    try {
      if (currentData.initialTherapy != null) {
        // --- UPDATE LOGIC ---
        print('--- UPDATING THERAPY ID: ${currentData.initialTherapy!.id} ---');
        await NotificationService().cancelTherapyNotifications(currentData.initialTherapy!);
        
        final updatedTherapy = currentData.initialTherapy!.copyWith(
          takingFrequency: currentData.selectedFrequency,
          reminderTimes: currentData.reminderTimes,
          repeatAfter10Min: currentData.repeatAfter10Min,
          startDate: currentData.startDate,
          endDate: currentData.endDate,
          doseThreshold: currentData.doseThreshold,
          expiryDate: Value(currentData.expiryDate),
          dosesRemaining: Value(currentData.initialDoses),
          doseAmount: currentData.doseAmount,
        );
        await db.updateTherapy(updatedTherapy);
        
        // --- CHECK LOW STOCK ON UPDATE ---
        if (updatedTherapy.dosesRemaining != null && 
            updatedTherapy.dosesRemaining! <= updatedTherapy.doseThreshold) {
          await NotificationService().triggerLowStockNotification(
            therapyId: updatedTherapy.id,
            drugName: updatedTherapy.drugName,
            remainingDoses: updatedTherapy.dosesRemaining!,
          );
        } else {
          // If the user updated the count to be ABOVE the threshold, cancel any old warning.
          await NotificationService().cancelLowStockNotification(updatedTherapy.id);
        }

        // Reschedule other notifications
        await NotificationService().scheduleNotificationForTherapy(updatedTherapy);
        await NotificationService().scheduleExpiryNotification(updatedTherapy);
        print('--- THERAPY UPDATED AND NOTIFICATIONS RESCHEDULED ---');

      } else {
        // --- CREATE LOGIC ---
        print('--- SAVING NEW THERAPY TO DATABASE ---');
        final therapyToInsert = TherapiesCompanion(
          drugName: Value(currentData.currentDrug.name),
          drugDosage: Value(currentData.currentDrug.dosage),
          takingFrequency: Value(currentData.selectedFrequency),
          reminderTimes: Value(currentData.reminderTimes),
          repeatAfter10Min: Value(currentData.repeatAfter10Min),
          startDate: Value(currentData.startDate),
          endDate: Value(currentData.endDate),
          doseThreshold: Value(currentData.doseThreshold),
          expiryDate: Value(currentData.expiryDate),
          dosesRemaining: Value(currentData.initialDoses),
          doseAmount: Value(currentData.doseAmount),
        );
        final newTherapyId = await db.createTherapy(therapyToInsert);
        final newTherapy = await db.getTherapyById(newTherapyId);
        print('--- THERAPY SAVED, SCHEDULING NOTIFICATIONS ---');
        // --- CHECK LOW STOCK ON CREATE ---
        if (newTherapy.dosesRemaining != null && 
            newTherapy.dosesRemaining! <= newTherapy.doseThreshold) {
          await NotificationService().triggerLowStockNotification(
            therapyId: newTherapy.id,
            drugName: newTherapy.drugName,
            remainingDoses: newTherapy.dosesRemaining!,
          );
        }

        // Schedule other notifications
        await NotificationService().scheduleNotificationForTherapy(newTherapy);
        await NotificationService().scheduleExpiryNotification(newTherapy);
      }

      if (context.mounted) {
        context.goNamed(AppRouter.homeRouteName);
      }
    } catch (e, s) {
      print('--- FAILED TO SAVE/UPDATE THERAPY: $e ---');
      print(s);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = CupertinoTheme.of(context);
    final pageBackgroundColor = theme.primaryColor.withOpacity(0.95);

    return CupertinoPageScaffold(
      backgroundColor: pageBackgroundColor,
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Riepilogo Terapia'),
        previousPageTitle: 'Indietro', // Generic 'Back' title is safer
        backgroundColor: pageBackgroundColor,
        brightness: Brightness.dark,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const Text(
                'Controlla le impostazioni prima di confermare',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: CupertinoColors.lightBackgroundGray),
              ),
              const SizedBox(height: 30),
              Expanded(
                child: ListView(
                  children: [
                    _buildSummaryRow(
                      icon: FontAwesomeIcons.pills,
                      text: currentData.currentDrug.fullDescription,
                      onEdit: null,
                    ),
                    _buildSummaryRow(
                      icon: CupertinoIcons.time,
                      text: _formatFrequency(context),
                      onEdit: () => _launchEditScreen(AppRouter.therapyFrequencyRouteName),
                    ),
                    _buildSummaryRow(
                      icon: CupertinoIcons.calendar,
                      text: 'Dal ${DateFormat('dd/MM/yyyy').format(currentData.startDate)} al ${DateFormat('dd/MM/yyyy').format(currentData.endDate)}',
                      onEdit: () => _launchEditScreen(AppRouter.therapyDurationRouteName),
                    ),
                    _buildSummaryRow(
                      icon: FontAwesomeIcons.prescriptionBottle,
                      text: 'Avviso a ${currentData.doseThreshold} dosi rimanenti',
                      onEdit: () => _launchEditScreen(AppRouter.doseAndExpiryRouteName),
                    ),
                    if (currentData.expiryDate != null)
                      _buildSummaryRow(
                        icon: CupertinoIcons.exclamationmark_triangle,
                        text: 'Notifica per scadenza 7 giorni prima',
                        onEdit: () => _launchEditScreen(AppRouter.doseAndExpiryRouteName),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              CupertinoButton(
                color: CupertinoColors.white,
                onPressed: () => _saveAndConfirm(context),
                child: Text(
                  'SALVA E CONFERMA',
                  style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow({required IconData icon, required String text, VoidCallback? onEdit}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          SizedBox(
            width: 30, // Adjust this width
            child: Center(
              child: FaIcon(icon, color: CupertinoColors.white, size: 24),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: CupertinoColors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // If onEdit is not null, show the button.
          if (onEdit != null)
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: onEdit,
              child: const Icon(CupertinoIcons.pencil, color: CupertinoColors.white),
            )
          // If onEdit is null, show an empty SizedBox to maintain alignment.
          else
            const SizedBox(width: 44), // Same approximate width as the button
        ],
      ),
    );
  }
}
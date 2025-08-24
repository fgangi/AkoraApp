import 'package:akora_app/core/navigation/app_router.dart';
import 'package:akora_app/core/services/notification_service.dart';
import 'package:akora_app/data/sources/local/app_database.dart';
import 'dart:io';

import 'package:akora_app/features/therapy_management/models/therapy_enums.dart';
import 'package:akora_app/features/therapy_management/models/therapy_setup_model.dart';
import 'package:akora_app/main.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

class TherapySummaryScreen extends StatefulWidget {
  final TherapySetupData? setupData;
  final Therapy? initialTherapy;
  final AppDatabase database;
  final NotificationService notificationService;

  const TherapySummaryScreen({
    super.key,
    this.setupData,
    this.initialTherapy,
    required this.database,
    required this.notificationService,
  }) : assert(setupData != null || initialTherapy != null);

  @override
  State<TherapySummaryScreen> createState() => _TherapySummaryScreenState();
}

class _TherapySummaryScreenState extends State<TherapySummaryScreen> {
  late TherapySetupData currentData;
  bool _isSaving = false;

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
    // This check will only run on Android devices.
    if (Platform.isAndroid) {
      // Check for the exact alarm permission.
      final status = await Permission.scheduleExactAlarm.request();
      if (status != PermissionStatus.granted) {
        // If the permission is denied after asking, show a helpful dialog.
        if (mounted) {
          showCupertinoDialog(
            context: context,
            builder: (ctx) => CupertinoAlertDialog(
              title: const Text('Permesso Necessario'),
              content: const Text(
                  'Per impostare i promemoria, questa app ha bisogno di un permesso speciale.\n\nTocca "Apri Impostazioni", poi vai su "Sveglie e promemoria" e attiva l\'opzione.'),
              actions: [
                CupertinoDialogAction(
                  child: const Text('Annulla'),
                  onPressed: () => Navigator.pop(ctx),
                ),
                CupertinoDialogAction(
                  isDefaultAction: true,
                  child: const Text('Apri Impostazioni'),
                  onPressed: () {
                    openAppSettings();
                    Navigator.pop(ctx);
                  },
                ),
              ],
            ),
          );
        }
        return; // Stop the function if permission is denied.
      }
    }

    if (_isSaving) return;
    setState(() {
      _isSaving = true;
    });
    try {
      if (currentData.initialTherapy != null) {
        // --- UPDATE LOGIC ---
        print('--- UPDATING THERAPY ID: ${currentData.initialTherapy!.id} ---');
        
        await widget.notificationService.cancelTherapyNotifications(currentData.initialTherapy!);

        final updatedTherapy = currentData.initialTherapy!.copyWith(
          takingFrequency: currentData.selectedFrequency,
          reminderTimes: currentData.reminderTimes,
          startDate: currentData.startDate,
          endDate: currentData.endDate,
          doseThreshold: currentData.doseThreshold,
          expiryDate: Value(currentData.expiryDate),
          dosesRemaining: Value(currentData.initialDoses),
          doseAmount: currentData.doseAmount,
        );
        await widget.database.updateTherapy(updatedTherapy);
        
        // --- CHECK LOW STOCK ON UPDATE ---
        if (updatedTherapy.dosesRemaining != null && 
            updatedTherapy.dosesRemaining! <= updatedTherapy.doseThreshold) {
          await widget.notificationService.triggerLowStockNotification(
            therapyId: updatedTherapy.id,
            drugName: updatedTherapy.drugName,
            remainingDoses: updatedTherapy.dosesRemaining!,
          );
        } else {
          // If the user updated the count to be ABOVE the threshold, cancel any old warning.
          await widget.notificationService.cancelLowStockNotification(updatedTherapy.id);
        }

        // Reschedule other notifications
        await widget.notificationService.scheduleNotificationForTherapy(updatedTherapy);
        await widget.notificationService.scheduleExpiryNotification(updatedTherapy);
        print('--- THERAPY UPDATED AND NOTIFICATIONS RESCHEDULED ---');

      } else {
        // --- CREATE LOGIC ---
        print('--- SAVING NEW THERAPY TO DATABASE ---');
        final therapyToInsert = TherapiesCompanion(
          drugName: Value(currentData.currentDrug.name),
          drugDosage: Value(currentData.currentDrug.dosage),
          takingFrequency: Value(currentData.selectedFrequency),
          reminderTimes: Value(currentData.reminderTimes),
          startDate: Value(currentData.startDate),
          endDate: Value(currentData.endDate),
          doseThreshold: Value(currentData.doseThreshold),
          expiryDate: Value(currentData.expiryDate),
          dosesRemaining: Value(currentData.initialDoses),
          doseAmount: Value(currentData.doseAmount),
        );
        final newTherapyId = await widget.database.createTherapy(therapyToInsert);
        final newTherapy = await widget.database.getTherapyById(newTherapyId);
        print('--- THERAPY SAVED, SCHEDULING NOTIFICATIONS ---');
        // --- CHECK LOW STOCK ON CREATE ---
        if (newTherapy.dosesRemaining != null && 
            newTherapy.dosesRemaining! <= newTherapy.doseThreshold) {
          await widget.notificationService.triggerLowStockNotification(
            therapyId: newTherapy.id,
            drugName: newTherapy.drugName,
            remainingDoses: newTherapy.dosesRemaining!,
          );
        }

        // Schedule other notifications
        await widget.notificationService.scheduleNotificationForTherapy(newTherapy);
        await widget.notificationService.scheduleExpiryNotification(newTherapy);
      }

      if (context.mounted) {
        context.goNamed(AppRouter.homeRouteName);
      }
    } catch (e, s) {
      print('--- FAILED TO SAVE/UPDATE THERAPY: $e ---');
      print(s);
    }finally {
      // --- LOADING STATE MANAGEMENT (New) ---
      // Make sure to turn off the loading indicator.
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = CupertinoTheme.of(context);
    final pageBackgroundColor = theme.primaryColor.withOpacity(0.95);

    // Determine if we are in a "Create" flow.
    // In our logic, this is true if initialTherapy is null.
    final bool isCreateMode = currentData.initialTherapy == null;

    return CupertinoPageScaffold(
      backgroundColor: pageBackgroundColor,
      navigationBar: CupertinoNavigationBar(
        middle: const Text(
          'Riepilogo Terapia',
          style: TextStyle(color: CupertinoColors.white),
        ),
        
        // We will build our own back/cancel button to have full control.
        // The automaticallyImplyLeading: false prevents Flutter from adding its own.
        automaticallyImplyLeading: false, 
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            if (isCreateMode) {
              // In create mode, "Annulla" should go all the way home.
              context.goNamed(AppRouter.homeRouteName);
            } else {
              // In edit mode, "Indietro" should just go back one screen.
              context.pop();
            }
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(CupertinoIcons.back, color: CupertinoColors.white),
              const SizedBox(width: 4.0),
              Text(
                isCreateMode ? 'Annulla' : 'Indietro',
                style: const TextStyle(color: CupertinoColors.white),
              ),
            ],
          ),
        ),
        
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
                      text: '${currentData.currentDrug.name} ${currentData.currentDrug.dosage}',
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
                // Disable the button when saving, and call the correct method.
                onPressed: _isSaving ? null : () => _saveAndConfirm(context),
                child: _isSaving
                    // Show a spinner when saving
                    ? const CupertinoActivityIndicator()
                    // Show the text when not saving
                    : Text(
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
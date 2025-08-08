import 'package:akora_app/core/navigation/app_router.dart';
import 'package:akora_app/core/services/notification_service.dart';
import 'package:akora_app/data/models/drug_model.dart';
import 'package:akora_app/data/sources/local/app_database.dart';
import 'package:akora_app/features/therapy_management/models/therapy_enums.dart';
import 'package:akora_app/main.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'; // For TimeOfDay
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class TherapySummaryScreen extends StatelessWidget {
  // Data for both create and edit mode
  final Drug currentDrug;
  final TakingFrequency selectedFrequency;
  final TimeOfDay selectedTime;
  final bool repeatAfter10Min;
  final DateTime startDate;
  final DateTime endDate;
  final int doseThreshold;
  final DateTime? expiryDate;
  final int? initialDoses;
  // This will be non-null only in edit mode
  final Therapy? initialTherapy;

  const TherapySummaryScreen({
    super.key,
    required this.currentDrug,
    required this.selectedFrequency,
    required this.selectedTime,
    required this.repeatAfter10Min,
    required this.startDate,
    required this.endDate,
    required this.doseThreshold,
    this.expiryDate,
    this.initialDoses,
    this.initialTherapy,
  });

  String _formatFrequency(BuildContext context) {
    switch (selectedFrequency) {
      case TakingFrequency.onceDaily:
        return 'Ogni giorno alle ${selectedTime.format(context)}';
      case TakingFrequency.twiceDaily:
        return 'Due volte al giorno';
      case TakingFrequency.onceWeekly:
        return 'Una volta a settimana';
      case TakingFrequency.other:
        return 'Frequenza personalizzata';
    }
  }

  Future<void> _saveAndConfirm(BuildContext context) async {
    try {
      if (initialTherapy != null) {
        // --- UPDATE LOGIC ---
        print('--- UPDATING THERAPY ID: ${initialTherapy!.id} ---');
        
        await NotificationService().cancelTherapyNotifications(initialTherapy!);
        
        final updatedTherapy = initialTherapy!.copyWith(
          takingFrequency: selectedFrequency,
          reminderHour: selectedTime.hour,
          reminderMinute: selectedTime.minute,
          repeatAfter10Min: repeatAfter10Min,
          startDate: startDate,
          endDate: endDate,
          doseThreshold: doseThreshold,
          expiryDate: Value(expiryDate),
          dosesRemaining: Value(initialDoses),
        );
        await db.updateTherapy(updatedTherapy);

        // Reschedule notifications with the updated information
        await NotificationService().scheduleNotificationForTherapy(updatedTherapy);
        
        print('--- THERAPY SUCCESSFULLY UPDATED AND NOTIFICATIONS RESCHEDULED ---');

      } else {
        // --- CREATE LOGIC ---
        print('--- SAVING NEW THERAPY TO DATABASE ---');
        
        final therapyToInsert = TherapiesCompanion(
          drugName: Value(currentDrug.name),
          drugDosage: Value(currentDrug.dosage),
          takingFrequency: Value(selectedFrequency),
          reminderHour: Value(selectedTime.hour),
          reminderMinute: Value(selectedTime.minute),
          repeatAfter10Min: Value(repeatAfter10Min),
          startDate: Value(startDate),
          endDate: Value(endDate),
          doseThreshold: Value(doseThreshold),
          expiryDate: Value(expiryDate),
          dosesRemaining: Value(initialDoses),
        );
        final newTherapyId = await db.createTherapy(therapyToInsert);
        // Fetch the full new therapy object to pass to the notification service
        final newTherapy = await db.getTherapyById(newTherapyId);
        
        print('--- THERAPY SUCCESSFULLY SAVED WITH ID: $newTherapyId ---');
        
        // Schedule notifications for the new therapy
        await NotificationService().scheduleNotificationForTherapy(newTherapy);
      }

      if (context.mounted) {
        context.goNamed(AppRouter.homeRouteName);
      }
    } catch (e, s) {
      print('--- FAILED TO SAVE/UPDATE THERAPY: $e ---');
      print(s);
      if (context.mounted) {
        showCupertinoDialog(
          context: context,
          builder: (ctx) => CupertinoAlertDialog(
            title: const Text('Errore'),
            content: const Text('Impossibile salvare la terapia. Si prega di riprovare.'),
            actions: [
              CupertinoDialogAction(
                child: const Text('OK'),
                isDefaultAction: true,
                onPressed: () => Navigator.pop(ctx),
              )
            ],
          ),
        );
      }
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
        previousPageTitle: 'Promemoria',
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
                style: TextStyle(
                  fontSize: 16,
                  color: CupertinoColors.lightBackgroundGray,
                ),
              ),
              const SizedBox(height: 30),
              Expanded(
                child: ListView(
                  children: [
                    _buildSummaryRow(
                      icon: FontAwesomeIcons.pills,
                      text: currentDrug.fullDescription,
                      onEdit: () {
                        print('Edit Drug tapped');
                      },
                    ),
                    _buildSummaryRow(
                      icon: CupertinoIcons.time,
                      text: _formatFrequency(context),
                      onEdit: () {
                        print('Edit Time tapped');
                      },
                    ),
                    _buildSummaryRow(
                      icon: CupertinoIcons.calendar,
                      text: 'Dal ${DateFormat('dd/MM/yyyy').format(startDate)} al ${DateFormat('dd/MM/yyyy').format(endDate)}',
                      onEdit: () {
                        print('Edit Duration tapped');
                      },
                    ),
                    _buildSummaryRow(
                      icon: FontAwesomeIcons.prescriptionBottle,
                      text: 'Avviso a $doseThreshold dosi rimanenti',
                      onEdit: () {
                        print('Edit Dose Alert tapped');
                      },
                    ),
                    if (expiryDate != null)
                      _buildSummaryRow(
                        icon: CupertinoIcons.exclamationmark_triangle,
                        text: 'Notifica per scadenza 7 giorni prima',
                        onEdit: () {
                          print('Edit Expiry Alert tapped');
                        },
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
                  style: TextStyle(
                    color: theme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow({required IconData icon, required String text, required VoidCallback onEdit}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          FaIcon(icon, color: CupertinoColors.white, size: 24),
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
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: onEdit,
            child: const Icon(CupertinoIcons.pencil, color: CupertinoColors.white),
          ),
        ],
      ),
    );
  }
}
// lib/features/therapy_management/screens/therapy_summary_screen.dart

// --- NEW IMPORTS FOR DATABASE INTERACTION ---
import 'package:akora_app/data/sources/local/app_database.dart';
import 'package:akora_app/main.dart'; // To access the global 'db' instance
import 'package:drift/drift.dart' show Value;

// --- EXISTING IMPORTS ---
import 'package:akora_app/core/navigation/app_router.dart';
import 'package:akora_app/data/models/drug_model.dart';
import 'package:akora_app/features/therapy_management/models/therapy_enums.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'; // For TimeOfDay
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class TherapySummaryScreen extends StatelessWidget {
  final Drug selectedDrug;
  final TakingFrequency selectedFrequency;
  final TimeOfDay selectedTime;
  final bool repeatAfter10Min;
  final DateTime startDate;
  final DateTime endDate;
  final int doseThreshold;
  final DateTime? expiryDate;
  final NotificationSound notificationSound;

  const TherapySummaryScreen({
    super.key,
    required this.selectedDrug,
    required this.selectedFrequency,
    required this.selectedTime,
    required this.repeatAfter10Min,
    required this.startDate,
    required this.endDate,
    required this.doseThreshold,
    this.expiryDate,
    required this.notificationSound,
  });

  // Helper function to format the frequency display text (no changes)
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

  // --- UPDATED _saveAndConfirm METHOD ---
  Future<void> _saveAndConfirm(BuildContext context) async {
    print('--- SAVING THERAPY TO LOCAL DRIFT/SQLITE DATABASE ---');

    // Drift uses "Companion" objects for inserts and updates.
    // They are type-safe and handle default values and nullability gracefully.
    final therapyToInsert = TherapiesCompanion(
      drugName: Value(selectedDrug.name),
      drugDosage: Value(selectedDrug.dosage),
      takingFrequency: Value(selectedFrequency),
      reminderHour: Value(selectedTime.hour),
      reminderMinute: Value(selectedTime.minute),
      repeatAfter10Min: Value(repeatAfter10Min),
      startDate: Value(startDate),
      endDate: Value(endDate),
      doseThreshold: Value(doseThreshold),
      expiryDate: Value(expiryDate), // Drift correctly handles null values when wrapped in Value()
      notificationSound: Value(notificationSound),
      // isActive and isPaused will use their default values (true and false)
    );

    try {
      // Use the global 'db' instance (from main.dart) to call the create method
      // that we defined in our AppDatabase class.
      await db.createTherapy(therapyToInsert);
      
      print('--- THERAPY SUCCESSFULLY SAVED ---');

      // TODO: Schedule local notifications based on the saved data. This is the next major feature.

      // After a successful save, navigate to the main home screen,
      // clearing the entire setup flow from the navigation stack.
      if (context.mounted) {
        // Use context.goNamed() to replace the navigation stack so the user
        // can't press 'back' to get into the setup flow again.
        context.goNamed(AppRouter.homeRouteName);
      }

    } catch (e) {
      print('--- FAILED TO SAVE THERAPY TO LOCAL DB: $e ---');
      
      // Show an error dialog to the user if saving fails.
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
                      text: selectedDrug.fullDescription,
                      onEdit: () {
                        print('Edit Drug tapped');
                        // TODO: Implement navigation back to drug search
                      },
                    ),
                    _buildSummaryRow(
                      icon: CupertinoIcons.time,
                      text: _formatFrequency(context),
                      onEdit: () {
                        print('Edit Time tapped');
                        // TODO: Implement navigation back to frequency/time screens
                      },
                    ),
                    _buildSummaryRow(
                      icon: CupertinoIcons.calendar,
                      text: 'Dal ${DateFormat('dd/MM/yyyy').format(startDate)} al ${DateFormat('dd/MM/yyyy').format(endDate)}',
                      onEdit: () {
                        print('Edit Duration tapped');
                        // TODO: Implement navigation back to duration screen
                      },
                    ),
                    _buildSummaryRow(
                      icon: FontAwesomeIcons.prescriptionBottle,
                      text: 'Avviso a $doseThreshold dosi rimanenti',
                      onEdit: () {
                        print('Edit Dose Alert tapped');
                        // TODO: Implement navigation back to dose/expiry screen
                      },
                    ),
                    if (expiryDate != null)
                      _buildSummaryRow(
                        icon: CupertinoIcons.exclamationmark_triangle,
                        text: 'Notifica per scadenza 7 giorni prima',
                        onEdit: () {
                          print('Edit Expiry Alert tapped');
                          // TODO: Implement navigation back to dose/expiry screen
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
import 'package:akora_app/core/navigation/app_router.dart';
import 'package:akora_app/core/services/notification_service.dart';
import 'package:akora_app/data/sources/local/app_database.dart';
import 'package:akora_app/features/therapy_management/models/therapy_enums.dart';
import 'package:akora_app/features/therapy_management/models/therapy_setup_model.dart'; // Import the new data model
import 'package:akora_app/main.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class TherapySummaryScreen extends StatefulWidget {
  // The constructor now takes the single data model object.
  final TherapySetupData initialData;

  const TherapySummaryScreen({super.key, required this.initialData});

  @override
  State<TherapySummaryScreen> createState() => _TherapySummaryScreenState();
}

class _TherapySummaryScreenState extends State<TherapySummaryScreen> {
  // The local state holds the current data, which can be updated after returning from an edit screen.
  late TherapySetupData currentData;

  @override
  void initState() {
    super.initState();
    currentData = widget.initialData;
  }

  String _formatFrequency(BuildContext context) {
    switch (currentData.selectedFrequency) {
      case TakingFrequency.onceDaily:
        return 'Ogni giorno alle ${currentData.selectedTime.format(context)}';
      case TakingFrequency.twiceDaily:
        return 'Due volte al giorno';
      case TakingFrequency.onceWeekly:
        return 'Una volta a settimana';
      case TakingFrequency.other:
        return 'Frequenza personalizzata';
    }
  }

  // --- NAVIGATION METHODS FOR EDIT BUTTONS ---

  // Navigates to the Frequency/Time screens and waits for the updated data.
  Future<void> _editFrequencyAndTime() async {
    currentData.isEditing = true; // Set the editing state to true

    final result = await context.pushNamed(
      AppRouter.therapyFrequencyRouteName,
      extra: currentData, // Pass the current data to the start of the sub-flow
    );

    if (result is TherapySetupData && mounted) {
      result.isEditing = false; // Reset the editing state
      setState(() {
        currentData = result; // Update the UI with the returned, modified data
      });
    }
  }

  // Navigates to the Duration screen and waits for the updated data.
  Future<void> _editDuration() async {
    currentData.isEditing = true;

    final result = await context.pushNamed(
      AppRouter.therapyDurationRouteName,
      extra: currentData,
    );

    if (result is TherapySetupData && mounted) {
      result.isEditing = false; // Reset the editing state
      setState(() {
        currentData = result;
      });
    }
  }

  // Navigates to the Dose/Expiry screen and waits for the updated data.
  Future<void> _editDoseAndExpiry() async {
    currentData.isEditing = true; // Set the editing state to true

    final result = await context.pushNamed(
      AppRouter.doseAndExpiryRouteName,
      extra: currentData,
    );

    if (result is TherapySetupData && mounted) {
      result.isEditing = false; // Reset the editing state
      setState(() {
        currentData = result;
      });
    }
  }


  Future<void> _saveAndConfirm(BuildContext context) async {
    // The save logic now uses the 'currentData' state variable.
    try {
      if (currentData.initialTherapy != null) {
        // --- UPDATE LOGIC ---
        print('--- UPDATING THERAPY ID: ${currentData.initialTherapy!.id} ---');
        await NotificationService().cancelTherapyNotifications(currentData.initialTherapy!);
        
        final updatedTherapy = currentData.initialTherapy!.copyWith(
          takingFrequency: currentData.selectedFrequency,
          reminderHour: currentData.selectedTime.hour,
          reminderMinute: currentData.selectedTime.minute,
          repeatAfter10Min: currentData.repeatAfter10Min,
          startDate: currentData.startDate,
          endDate: currentData.endDate,
          doseThreshold: currentData.doseThreshold,
          expiryDate: Value(currentData.expiryDate),
          dosesRemaining: Value(currentData.initialDoses),
        );
        await db.updateTherapy(updatedTherapy);
        await NotificationService().scheduleNotificationForTherapy(updatedTherapy);
        print('--- THERAPY SUCCESSFULLY UPDATED AND NOTIFICATIONS RESCHEDULED ---');

      } else {
        // --- CREATE LOGIC ---
        print('--- SAVING NEW THERAPY TO DATABASE ---');
        final therapyToInsert = TherapiesCompanion(
          drugName: Value(currentData.currentDrug.name),
          drugDosage: Value(currentData.currentDrug.dosage),
          takingFrequency: Value(currentData.selectedFrequency),
          reminderHour: Value(currentData.selectedTime.hour),
          reminderMinute: Value(currentData.selectedTime.minute),
          repeatAfter10Min: Value(currentData.repeatAfter10Min),
          startDate: Value(currentData.startDate),
          endDate: Value(currentData.endDate),
          doseThreshold: Value(currentData.doseThreshold),
          expiryDate: Value(currentData.expiryDate),
          dosesRemaining: Value(currentData.initialDoses),
        );
        final newTherapyId = await db.createTherapy(therapyToInsert);
        final newTherapy = await db.getTherapyById(newTherapyId);
        print('--- THERAPY SUCCESSFULLY SAVED WITH ID: $newTherapyId ---');
        await NotificationService().scheduleNotificationForTherapy(newTherapy);
      }

      if (context.mounted) {
        context.goNamed(AppRouter.homeRouteName);
      }
    } catch (e, s) {
      print('--- FAILED TO SAVE/UPDATE THERAPY: $e ---');
      print(s);
      // ... (Error dialog)
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
        previousPageTitle: 'Promemoria', // This will need to be dynamic
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
                      text: currentData.currentDrug.fullDescription,
                      onEdit: () {
                        // Drug selection cannot be edited, so this button can be disabled or do nothing.
                        print('Edit Drug tapped - (Action Disabled)');
                      },
                    ),
                    _buildSummaryRow(
                      icon: CupertinoIcons.time,
                      text: _formatFrequency(context),
                      onEdit: _editFrequencyAndTime, // Assign the edit method
                    ),
                    _buildSummaryRow(
                      icon: CupertinoIcons.calendar,
                      text: 'Dal ${DateFormat('dd/MM/yyyy').format(currentData.startDate)} al ${DateFormat('dd/MM/yyyy').format(currentData.endDate)}',
                      onEdit: _editDuration, // Assign the edit method
                    ),
                    _buildSummaryRow(
                      icon: FontAwesomeIcons.prescriptionBottle,
                      text: 'Avviso a ${currentData.doseThreshold} dosi rimanenti',
                      onEdit: _editDoseAndExpiry, // Assign the edit method
                    ),
                    if (currentData.expiryDate != null)
                      _buildSummaryRow(
                        icon: CupertinoIcons.exclamationmark_triangle,
                        text: 'Notifica per scadenza 7 giorni prima',
                        onEdit: _editDoseAndExpiry, // Also goes to the same screen
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
// lib/features/therapy_management/screens/therapy_summary_screen.dart
import 'package:akora_app/data/models/drug_model.dart';
import 'package:akora_app/features/therapy_management/screens/dose_and_expiry_screen.dart';
import 'package:akora_app/features/therapy_management/screens/therapy_frequency_screen.dart';
import 'package:akora_app/features/therapy_management/models/therapy_enums.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'; // For TimeOfDay
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:akora_app/core/navigation/app_router.dart';
import 'package:intl/intl.dart';

class TherapySummaryScreen extends StatelessWidget {
  // ... (constructor and all properties remain the same) ...
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

  // Helper function to format the frequency display text
  String _formatFrequency(BuildContext context) {
    switch (selectedFrequency) {
      case TakingFrequency.onceDaily:
        // THE FIX IS HERE: Just call .format(context) directly on the TimeOfDay object.
        return 'Ogni giorno alle ${selectedTime.format(context)}';
      case TakingFrequency.twiceDaily:
        return 'Due volte al giorno';
      case TakingFrequency.onceWeekly:
        return 'Una volta a settimana';
      case TakingFrequency.other:
        return 'Frequenza personalizzata';
    }
  }

  // ... (_saveAndConfirm method remains the same) ...
  void _saveAndConfirm(BuildContext context) {
    print('--- THERAPY SAVED ---');
    print('Drug: ${selectedDrug.name}');
    print('Frequency: $selectedFrequency');
    print('Time: ${selectedTime.format(context)}'); // Also use format(context) here for consistency
    print('Repeat: $repeatAfter10Min');
    print('Start Date: $startDate');
    print('End Date: $endDate');
    print('Dose Threshold: $doseThreshold');
    print('Expiry Date: $expiryDate');
    print('Notification Sound: $notificationSound');
    // TODO: Save to DB, schedule notifications, navigate home
  }

  @override
  Widget build(BuildContext context) {
    // ... (build method and _buildSummaryRow method are exactly the same as the previous correct version) ...
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
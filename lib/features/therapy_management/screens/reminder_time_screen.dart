// lib/features/therapy_management/screens/reminder_time_screen.dart
import 'package:akora_app/core/navigation/app_router.dart';
import 'package:akora_app/data/models/drug_model.dart';
import 'package:akora_app/features/therapy_management/screens/therapy_frequency_screen.dart';
import 'package:akora_app/features/therapy_management/models/therapy_enums.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'; // Import for TimeOfDay
import 'package:go_router/go_router.dart';

class ReminderTimeScreen extends StatefulWidget {
  final Drug selectedDrug;
  final TakingFrequency selectedFrequency;

  const ReminderTimeScreen({
    super.key,
    required this.selectedDrug,
    required this.selectedFrequency,
  });

  @override
  State<ReminderTimeScreen> createState() => _ReminderTimeScreenState();
}

class _ReminderTimeScreenState extends State<ReminderTimeScreen> {
  // State for this screen
  Duration _selectedDuration = const Duration(hours: 8, minutes: 30); // Default to 08:30
  bool _repeatAfter10Min = false; // State for the "Ripeti dopo 10 min" switch

  void _navigateToNextStep() {
    final selectedTime = TimeOfDay(
      hour: _selectedDuration.inHours,
      minute: _selectedDuration.inMinutes.remainder(60),
    );

    // Navigate to the next screen (Therapy Duration), passing all collected data.
    context.pushNamed(
      AppRouter.therapyDurationRouteName,
      extra: {
        'drug': widget.selectedDrug,
        'frequency': widget.selectedFrequency,
        'time': selectedTime,
        'repeat': _repeatAfter10Min,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(widget.selectedDrug.name),
        previousPageTitle: 'Frequenza',
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(height: 30),
              const Text(
                'A CHE ORA VUOI RICEVERE IL PROMEMORIA?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),

              // --- Time Picker ---
              SizedBox(
                height: 200,
                child: CupertinoTimerPicker(
                  mode: CupertinoTimerPickerMode.hm,
                  initialTimerDuration: _selectedDuration,
                  onTimerDurationChanged: (Duration newDuration) {
                    setState(() {
                      _selectedDuration = newDuration;
                    });
                  },
                ),
              ),
              const SizedBox(height: 40),

              // --- Notification Options (Simplified) ---
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                decoration: BoxDecoration(
                  color: CupertinoColors.secondarySystemGroupedBackground.resolveFrom(context),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: _buildSwitchRow(
                  text: 'Ripeti dopo 10 min',
                  value: _repeatAfter10Min,
                  onChanged: (bool value) {
                    setState(() {
                      _repeatAfter10Min = value;
                    });
                  },
                ),
              ),

              const Spacer(), // Pushes the button to the bottom

              CupertinoButton.filled(
                onPressed: _navigateToNextStep,
                child: const Text('Avanti'),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget for the switch row
  Widget _buildSwitchRow({required String text, required bool value, required ValueChanged<bool> onChanged}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          CupertinoSwitch(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
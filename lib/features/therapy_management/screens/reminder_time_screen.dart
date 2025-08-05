// lib/features/therapy_management/screens/reminder_time_screen.dart
import 'package:akora_app/core/navigation/app_router.dart';
import 'package:akora_app/data/models/drug_model.dart';
import 'package:akora_app/data/sources/local/app_database.dart'; // Import for Therapy
import 'package:akora_app/features/therapy_management/models/therapy_enums.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'; // Import for TimeOfDay
import 'package:go_router/go_router.dart';

class ReminderTimeScreen extends StatefulWidget {
  final Drug currentDrug;
  final TakingFrequency selectedFrequency;
  final Therapy? initialTherapy; // For Edit Mode

  const ReminderTimeScreen({
    super.key,
    required this.currentDrug,
    required this.selectedFrequency,
    this.initialTherapy,
  });

  @override
  State<ReminderTimeScreen> createState() => _ReminderTimeScreenState();
}

class _ReminderTimeScreenState extends State<ReminderTimeScreen> {
  late DateTime _selectedDateTime;
  late bool _repeatAfter10Min;

  @override
  void initState() {
    super.initState();
    if (widget.initialTherapy != null) {
      // --- EDIT MODE ---
      // Pre-fill state from the existing therapy
      _selectedDateTime = DateTime(
        2000, 1, 1, // Use a dummy date
        widget.initialTherapy!.reminderHour,
        widget.initialTherapy!.reminderMinute,
      );
      _repeatAfter10Min = widget.initialTherapy!.repeatAfter10Min;
    } else {
      // --- CREATE MODE ---
      // Use defaults
      _selectedDateTime = DateTime(2000, 1, 1, 8, 30);
      _repeatAfter10Min = false;
    }
  }

  void _navigateToNextStep() {
    final selectedTime = TimeOfDay.fromDateTime(_selectedDateTime);

    context.pushNamed(
      AppRouter.therapyDurationRouteName,
      extra: {
        'drug': widget.currentDrug,
        'frequency': widget.selectedFrequency,
        'time': selectedTime,
        'repeat': _repeatAfter10Min,
        'initialTherapy': widget.initialTherapy, // Pass it along
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // The build method does not need changes, it will use the pre-filled state
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(widget.currentDrug.name),
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
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              SizedBox(
                height: 200,
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.time,
                  initialDateTime: _selectedDateTime,
                  use24hFormat: true,
                  onDateTimeChanged: (DateTime newDateTime) {
                    setState(() {
                      _selectedDateTime = newDateTime;
                    });
                  },
                ),
              ),
              const SizedBox(height: 40),
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
                    setState(() { _repeatAfter10Min = value; });
                  },
                ),
              ),
              const Spacer(),
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
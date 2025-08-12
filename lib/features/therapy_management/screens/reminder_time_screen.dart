import 'package:akora_app/core/navigation/app_router.dart';
import 'package:akora_app/features/therapy_management/models/therapy_enums.dart';
import 'package:akora_app/features/therapy_management/models/therapy_setup_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

class ReminderTimeScreen extends StatefulWidget {
  final TherapySetupData initialData;
  const ReminderTimeScreen({super.key, required this.initialData});

  @override
  State<ReminderTimeScreen> createState() => _ReminderTimeScreenState();
}

class _ReminderTimeScreenState extends State<ReminderTimeScreen> {
  // We now manage a list of times, not a single time.
  late List<DateTime> _selectedDateTimes;
  late bool _repeatAfter10Min;

  @override
  void initState() {
    super.initState();
    _repeatAfter10Min = widget.initialData.repeatAfter10Min;

    // Initialize the list of times from the data model.
    _selectedDateTimes = widget.initialData.reminderTimes.map((timeStr) {
      final parts = timeStr.split(':');
      return DateTime(2000, 1, 1, int.parse(parts[0]), int.parse(parts[1]));
    }).toList();

    // Ensure we have the correct number of time pickers for the selected frequency.
    _adjustTimePickerCount();
  }

  void _adjustTimePickerCount() {
    int requiredCount = 1; // Default to 1 picker
    if (widget.initialData.selectedFrequency == TakingFrequency.twiceDaily) {
      requiredCount = 2;
    } // Add more else if blocks for other frequencies like three times a day, etc.

    // Add default times if we need more pickers
    while (_selectedDateTimes.length < requiredCount) {
      // Add a sensible default for the second dose, e.g., 20:00
      _selectedDateTimes.add(DateTime(2000, 1, 1, 20, 00));
    }

    // Remove extra times if the user changed from a higher to lower frequency
    while (_selectedDateTimes.length > requiredCount) {
      _selectedDateTimes.removeLast();
    }
  }

  void _onConfirm() {
    // Convert the list of DateTime back to a list of "HH:mm" strings
    final List<String> timeStrings = _selectedDateTimes.map((dt) {
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    }).toList();
    
    // Update the data model with the new values
    final updatedData = widget.initialData
      ..reminderTimes = timeStrings
      ..repeatAfter10Min = _repeatAfter10Min;

    if (widget.initialData.isSingleEditMode) {
      context.pop(updatedData);
    } else {
      context.pushNamed(
        AppRouter.therapyDurationRouteName,
        extra: updatedData,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(widget.initialData.currentDrug.name),
        previousPageTitle: widget.initialData.isSingleEditMode ? 'Riepilogo' : 'Frequenza',
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Use Expanded + ListView to handle multiple scrollable time pickers
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                children: [
                  const SizedBox(height: 30),
                  Text(
                    _selectedDateTimes.length > 1
                        ? 'A CHE ORE VUOI RICEVERE I PROMEMORIA?'
                        : 'A CHE ORA VUOI RICEVERE IL PROMEMORIA?',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 30),
                  
                  // Dynamically build a time picker for each required time
                  ...List.generate(_selectedDateTimes.length, (index) {
                    return Column(
                      children: [
                        if (_selectedDateTimes.length > 1)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Text(
                              'Orario ${index + 1}',
                              style: const TextStyle(fontSize: 16, color: CupertinoColors.secondaryLabel, fontWeight: FontWeight.w600),
                            ),
                          ),
                        SizedBox(
                          height: 220,
                          child: CupertinoDatePicker(
                            mode: CupertinoDatePickerMode.time,
                            initialDateTime: _selectedDateTimes[index],
                            use24hFormat: true,
                            onDateTimeChanged: (DateTime newDateTime) {
                              setState(() {
                                _selectedDateTimes[index] = newDateTime;
                              });
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    );
                  }),                  
                ],
              ),
            ),
            
            // Fixed bottom button
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
              child: CupertinoButton.filled(
                onPressed: _onConfirm,
                child: Text(widget.initialData.isSingleEditMode ? 'Conferma' : 'Avanti'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchRow({required String text, required bool value, required ValueChanged<bool> onChanged}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(text, style: const TextStyle(fontSize: 16))),
          CupertinoSwitch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}
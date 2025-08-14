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
  // We manage a LIST of times now.
  late List<DateTime> _selectedDateTimes;
  late int _requiredTimePickers;

  @override
  void initState() {
    super.initState();
    // Initialize the list of times by parsing the strings from the data model.
    _selectedDateTimes = widget.initialData.reminderTimes.map((timeStr) {
      final parts = timeStr.split(':');
      return DateTime(2000, 1, 1, int.parse(parts[0]), int.parse(parts[1]));
    }).toList();

    // Call a helper to ensure we have the correct number of time pickers.
    _adjustTimePickerCount();
  }

  // This helper function makes the screen dynamic.
  void _adjustTimePickerCount() {
    switch (widget.initialData.selectedFrequency) {
      case TakingFrequency.twiceDaily:
        _requiredTimePickers = 2;
        break;
      case TakingFrequency.onceDaily:
      case TakingFrequency.onceWeekly:
        _requiredTimePickers = 1;
        break;
    }

    // Add default times if we need more pickers (e.g., user selected "twice daily")
    while (_selectedDateTimes.length < _requiredTimePickers) {
      // Add a sensible default for the second dose, e.g., 20:00
      _selectedDateTimes.add(DateTime(2000, 1, 1, 20, 00));
    }

    // Remove extra times if the user changed from a higher to lower frequency
    while (_selectedDateTimes.length > _requiredTimePickers) {
      _selectedDateTimes.removeLast();
    }
  }

  void _onConfirm() {
    // Convert the list of DateTime objects back into a list of "HH:mm" strings
    final List<String> timeStrings = _selectedDateTimes.map((dt) {
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    }).toList();
    
    // Update the data model with the new list of times
    final updatedData = widget.initialData..reminderTimes = timeStrings;

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
            // The main content is now a ListView to allow scrolling if needed
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                children: [
                  const SizedBox(height: 30),
                  Text(
                    _requiredTimePickers > 1
                        ? 'A CHE ORE VUOI RICEVERE I PROMEMORIA?'
                        : 'A CHE ORA VUOI RICEVERE IL PROMEMORIA?',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 30),
                  
                  // This generates a widget for each time in our _selectedDateTimes list.
                  ...List.generate(_selectedDateTimes.length, (index) {
                    return Column(
                      children: [
                        // Only show a label if there's more than one picker
                        if (_selectedDateTimes.length > 1)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Text(
                              'Orario ${index + 1}',
                              style: const TextStyle(fontSize: 16, color: CupertinoColors.secondaryLabel, fontWeight: FontWeight.w600),
                            ),
                          ),
                        SizedBox(
                          height: 150, // A more compact height
                          child: CupertinoDatePicker(
                            mode: CupertinoDatePickerMode.time,
                            initialDateTime: _selectedDateTimes[index],
                            use24hFormat: true,
                            onDateTimeChanged: (DateTime newDateTime) {
                              setState(() {
                                // Update the specific time in the list
                                _selectedDateTimes[index] = newDateTime;
                              });
                            },
                          ),
                        ),
                        const SizedBox(height: 30),
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
}
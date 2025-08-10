import 'package:akora_app/core/navigation/app_router.dart';
import 'package:akora_app/features/therapy_management/models/therapy_setup_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show TimeOfDay;
import 'package:go_router/go_router.dart';

class ReminderTimeScreen extends StatefulWidget {
  final TherapySetupData initialData;
  const ReminderTimeScreen({super.key, required this.initialData});

  @override
  State<ReminderTimeScreen> createState() => _ReminderTimeScreenState();
}

class _ReminderTimeScreenState extends State<ReminderTimeScreen> {
  late DateTime _selectedDateTime;
  late bool _repeatAfter10Min;

  @override
  void initState() {
    super.initState();
    _selectedDateTime = DateTime(2000, 1, 1, widget.initialData.selectedTime.hour, widget.initialData.selectedTime.minute);
    _repeatAfter10Min = widget.initialData.repeatAfter10Min;
  }

  void _onConfirm() {
    final updatedData = widget.initialData
      ..selectedTime = TimeOfDay.fromDateTime(_selectedDateTime)
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
                    setState(() { _selectedDateTime = newDateTime; });
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
                onPressed: _onConfirm,
                child: Text(widget.initialData.isSingleEditMode ? 'Conferma' : 'Avanti'),
              ),
              const SizedBox(height: 20),
            ],
          ),
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
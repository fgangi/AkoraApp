import 'package:akora_app/core/navigation/app_router.dart';
import 'package:akora_app/features/therapy_management/models/therapy_setup_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

class TherapyDurationScreen extends StatefulWidget {
  final TherapySetupData initialData;
  const TherapyDurationScreen({super.key, required this.initialData});

  @override
  State<TherapyDurationScreen> createState() => _TherapyDurationScreenState();
}

class _TherapyDurationScreenState extends State<TherapyDurationScreen> {
  late DateTime _startDate;
  late DateTime _endDate;

  @override
  void initState() {
    super.initState();
    _startDate = widget.initialData.startDate;
    _endDate = widget.initialData.endDate;
  }

  void _onConfirm() {
    final updatedData = widget.initialData
      ..startDate = _startDate
      ..endDate = _endDate;

    if (widget.initialData.isSingleEditMode) {
      context.pop(updatedData);
    } else {
      context.pushNamed(
        AppRouter.doseAndExpiryRouteName,
        extra: updatedData,
      );
    }
  }

  void _showDatePicker(BuildContext context, {required bool isStartDate}) {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: 250,
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: CupertinoDatePicker(
          initialDateTime: isStartDate ? _startDate : _endDate,
          minimumDate: isStartDate ? null : _startDate,
          mode: CupertinoDatePickerMode.date,
          onDateTimeChanged: (newDate) {
            setState(() {
              if (isStartDate) {
                _startDate = newDate;
                if (_endDate.isBefore(_startDate)) {
                  _endDate = _startDate.add(const Duration(days: 1));
                }
              } else {
                _endDate = newDate;
              }
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(widget.initialData.currentDrug.name),
        previousPageTitle: widget.initialData.isSingleEditMode ? 'Riepilogo' : 'Orario',
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(height: 30),
              const Text(
                'IMPOSTA LA DURATA DELLA TUA TERAPIA',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),
              const Text('INIZIO TERAPIA', style: TextStyle(fontWeight: FontWeight.w600, color: CupertinoColors.secondaryLabel)),
              const SizedBox(height: 8),
              _buildDateRow(date: _startDate, onTap: () => _showDatePicker(context, isStartDate: true)),
              const SizedBox(height: 30),
              const Text('FINE TERAPIA', style: TextStyle(fontWeight: FontWeight.w600, color: CupertinoColors.secondaryLabel)),
              const SizedBox(height: 8),
              _buildDateRow(date: _endDate, onTap: () => _showDatePicker(context, isStartDate: false)),
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

  Widget _buildDateRow({required DateTime date, required VoidCallback onTap}) {
    return CupertinoButton(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: CupertinoColors.tertiarySystemFill.resolveFrom(context),
      onPressed: onTap,
      child: Text(
        '${date.day} ${getMonthName(date.month)} ${date.year}',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: CupertinoColors.label.resolveFrom(context)),
      ),
    );
  }

  String getMonthName(int month) {
    const months = ['Gennaio', 'Febbraio', 'Marzo', 'Aprile', 'Maggio', 'Giugno', 'Luglio', 'Agosto', 'Settembre', 'Ottobre', 'Novembre', 'Dicembre'];
    return months[month - 1];
  }
}
// lib/features/therapy_management/screens/therapy_duration_screen.dart
import 'package:akora_app/core/navigation/app_router.dart';
import 'package:akora_app/data/models/drug_model.dart';
import 'package:akora_app/data/sources/local/app_database.dart'; // Import for Therapy
import 'package:akora_app/features/therapy_management/models/therapy_enums.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'; // For TimeOfDay
import 'package:go_router/go_router.dart';

class TherapyDurationScreen extends StatefulWidget {
  final Drug currentDrug;
  final TakingFrequency selectedFrequency;
  final TimeOfDay selectedTime;
  final bool repeatAfter10Min;
  final Therapy? initialTherapy; // For Edit Mode

  const TherapyDurationScreen({
    super.key,
    required this.currentDrug,
    required this.selectedFrequency,
    required this.selectedTime,
    required this.repeatAfter10Min,
    this.initialTherapy,
  });

  @override
  State<TherapyDurationScreen> createState() => _TherapyDurationScreenState();
}

class _TherapyDurationScreenState extends State<TherapyDurationScreen> {
  late DateTime _startDate;
  late DateTime _endDate;

  @override
  void initState() {
    super.initState();
    if (widget.initialTherapy != null) {
      // --- EDIT MODE ---
      _startDate = widget.initialTherapy!.startDate;
      _endDate = widget.initialTherapy!.endDate;
    } else {
      // --- CREATE MODE ---
      _startDate = DateTime.now();
      _endDate = DateTime.now().add(const Duration(days: 7));
    }
  }

  void _navigateToNextStep() {
    context.pushNamed(
      AppRouter.doseAndExpiryRouteName,
      extra: {
        'drug': widget.currentDrug,
        'frequency': widget.selectedFrequency,
        'time': widget.selectedTime,
        'repeat': widget.repeatAfter10Min,
        'startDate': _startDate,
        'endDate': _endDate,
        'initialTherapy': widget.initialTherapy, // Pass it along
      },
    );
  }

  // Helper to show a date picker
  void _showDatePicker(BuildContext context, {required bool isStartDate}) {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: 250,
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: CupertinoDatePicker(
          initialDateTime: isStartDate ? _startDate : _endDate,
          mode: CupertinoDatePickerMode.date,
          onDateTimeChanged: (newDate) {
            setState(() {
              if (isStartDate) {
                _startDate = newDate;
                // Ensure end date is always after start date
                if (_endDate.isBefore(_startDate)) {
                  _endDate = _startDate.add(const Duration(days: 1));
                }
              } else {
                // Ensure end date is not before start date
                if (newDate.isBefore(_startDate)) {
                  return; // Or show an error
                }
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
        middle: Text(widget.currentDrug.name),
        previousPageTitle: 'Orario',
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
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),

              // --- Start Date Section ---
              const Text('INIZIO TERAPIA', style: TextStyle(fontWeight: FontWeight.bold, color: CupertinoColors.secondaryLabel)),
              const SizedBox(height: 8),
              _buildDateRow(
                context: context,
                date: _startDate,
                onTap: () => _showDatePicker(context, isStartDate: true),
              ),
              const SizedBox(height: 30),

              // --- End Date Section ---
              const Text('FINE TERAPIA', style: TextStyle(fontWeight: FontWeight.bold, color: CupertinoColors.secondaryLabel)),
              const SizedBox(height: 8),
              _buildDateRow(
                context: context,
                date: _endDate,
                onTap: () => _showDatePicker(context, isStartDate: false),
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

  // Helper to build the date display rows.
  // The +/- buttons from the mockup would require more complex state management
  // to increment/decrement day/month/year. We will use a standard picker for now.
  Widget _buildDateRow({required BuildContext context, required DateTime date, required VoidCallback onTap}) {
    return CupertinoButton(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: CupertinoColors.tertiarySystemFill.resolveFrom(context),
      onPressed: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Using hardcoded month names for Italian, localization would be better
          Text(
            '${date.day} ${getMonthName(date.month)} ${date.year}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: CupertinoColors.label,
            ),
          ),
        ],
      ),
    );
  }

  String getMonthName(int month) {
    const months = ['Gennaio', 'Febbraio', 'Marzo', 'Aprile', 'Maggio', 'Giugno', 'Luglio', 'Agosto', 'Settembre', 'Ottobre', 'Novembre', 'Dicembre'];
    return months[month - 1];
  }
}
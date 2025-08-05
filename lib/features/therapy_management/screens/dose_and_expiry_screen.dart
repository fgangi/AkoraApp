// lib/features/therapy_management/screens/dose_and_expiry_screen.dart
import 'package:akora_app/core/navigation/app_router.dart';
import 'package:akora_app/data/models/drug_model.dart';
import 'package:akora_app/data/sources/local/app_database.dart'; // Import for Therapy
import 'package:akora_app/features/therapy_management/models/therapy_enums.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'; // For TimeOfDay
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class DoseAndExpiryScreen extends StatefulWidget {
  final Drug currentDrug;
  final TakingFrequency selectedFrequency;
  final TimeOfDay selectedTime;
  final bool repeatAfter10Min;
  final DateTime startDate;
  final DateTime endDate;
  final Therapy? initialTherapy; // For Edit Mode

  const DoseAndExpiryScreen({
    super.key,
    required this.currentDrug,
    required this.selectedFrequency,
    required this.selectedTime,
    required this.repeatAfter10Min,
    required this.startDate,
    required this.endDate,
    this.initialTherapy,
  });

  @override
  State<DoseAndExpiryScreen> createState() => _DoseAndExpiryScreenState();
}

class _DoseAndExpiryScreenState extends State<DoseAndExpiryScreen> {
  late int _remainingDosesThreshold;
  DateTime? _expiryDate;

  @override
  void initState() {
    super.initState();
    if (widget.initialTherapy != null) {
      // --- EDIT MODE ---
      _remainingDosesThreshold = widget.initialTherapy!.doseThreshold;
      _expiryDate = widget.initialTherapy!.expiryDate;
    } else {
      // --- CREATE MODE ---
      _remainingDosesThreshold = 10;
      _expiryDate = DateTime(DateTime.now().year + 1, DateTime.now().month, DateTime.now().day);
    }
  }

  void _navigateToNextStep() {
    context.pushNamed(
      AppRouter.therapySummaryRouteName,
      extra: {
        'drug': widget.currentDrug,
        'frequency': widget.selectedFrequency,
        'time': widget.selectedTime,
        'repeat': widget.repeatAfter10Min,
        'startDate': widget.startDate,
        'endDate': widget.endDate,
        'doseThreshold': _remainingDosesThreshold,
        'expiryDate': _expiryDate,
        'initialTherapy': widget.initialTherapy, // Pass it along for the final save/update
      },
    );
  }

  // Helper to show a date picker for expiry date
  void _showExpiryDatePicker(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: 250,
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: CupertinoDatePicker(
          initialDateTime: _expiryDate ?? DateTime.now().add(const Duration(days: 365)),
          minimumDate: DateTime.now(),
          mode: CupertinoDatePickerMode.date,
          onDateTimeChanged: (newDate) {
            setState(() {
              _expiryDate = newDate;
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // The build method remains exactly the same as the previous correct version.
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(widget.currentDrug.name),
        previousPageTitle: 'Durata',
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(height: 30),
              const Text(
                'ATTIVA PROMEMORIA PER DOSI E SCADENZA',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),
              const Text(
                'Ricevi un promemoria quando restano:',
                style: TextStyle(fontSize: 17),
              ),
              const SizedBox(height: 12),
              _buildDoseSelector(),
              const SizedBox(height: 30),
              _buildExpiryDateSelector(),
              const SizedBox(height: 50),
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

  // All helper methods (_buildDoseSelector, _buildExpiryDateSelector, _buildSoundSelector)
  // remain exactly the same as before.
  Widget _buildDoseSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CupertinoButton(
          onPressed: () {
            if (_remainingDosesThreshold > 1) {
              setState(() => _remainingDosesThreshold--);
            }
          },
          child: const Icon(CupertinoIcons.minus),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: CupertinoColors.tertiarySystemFill.resolveFrom(context),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            _remainingDosesThreshold.toString(),
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ),
        CupertinoButton(
          onPressed: () => setState(() => _remainingDosesThreshold++),
          child: const Icon(CupertinoIcons.add),
        ),
        const SizedBox(width: 8),
        const Text('Compresse', style: TextStyle(color: CupertinoColors.secondaryLabel)),
      ],
    );
  }

  Widget _buildExpiryDateSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Data di scadenza farmaco', style: TextStyle(fontSize: 17)),
        const SizedBox(height: 8),
        CupertinoButton(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: CupertinoColors.tertiarySystemFill.resolveFrom(context),
          onPressed: () => _showExpiryDatePicker(context),
          child: SizedBox(
            width: double.infinity,
            child: Text(
              _expiryDate != null ? DateFormat('dd/MM/yyyy').format(_expiryDate!) : 'Seleziona data',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: _expiryDate != null ? CupertinoColors.label.resolveFrom(context) : CupertinoColors.placeholderText,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Riceverai un avviso 7 giorni prima della scadenza',
          style: TextStyle(fontSize: 14, color: CupertinoColors.secondaryLabel),
        ),
      ],
    );
  }
}
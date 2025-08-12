import 'package:akora_app/core/navigation/app_router.dart';
import 'package:akora_app/features/therapy_management/models/therapy_setup_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class DoseAndExpiryScreen extends StatefulWidget {
  final TherapySetupData initialData;
  const DoseAndExpiryScreen({super.key, required this.initialData});

  @override
  State<DoseAndExpiryScreen> createState() => _DoseAndExpiryScreenState();
}

class _DoseAndExpiryScreenState extends State<DoseAndExpiryScreen> {
  // State variables
  late int _doseAmount;
  late int _initialDoses;
  late int _remainingDosesThreshold;
  DateTime? _expiryDate;

  @override
  void initState() {
    super.initState();
    if (widget.initialData.initialTherapy != null) {
      // Edit Mode: Pre-fill from existing therapy data
      _doseAmount = int.tryParse(widget.initialData.doseAmount) ?? 1;
      _initialDoses = widget.initialData.initialDoses ?? 20;
      _remainingDosesThreshold = widget.initialData.doseThreshold;
      _expiryDate = widget.initialData.expiryDate;
    } else {
      // Create Mode: Use defaults from the data model
      _doseAmount = int.tryParse(widget.initialData.doseAmount) ?? 1;
      _initialDoses = widget.initialData.initialDoses ?? 20;
      _remainingDosesThreshold = widget.initialData.doseThreshold;
      _expiryDate = widget.initialData.expiryDate;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _onConfirm() {
    final updatedData = widget.initialData
      ..doseThreshold = _remainingDosesThreshold
      ..expiryDate = _expiryDate
      ..initialDoses = _initialDoses
      ..doseAmount = _doseAmount.toString();

    if (widget.initialData.isSingleEditMode) {
      context.pop(updatedData);
    } else {
      context.pushNamed(
        AppRouter.therapySummaryRouteName,
        extra: updatedData,
      );
    }
  }

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
            setState(() { _expiryDate = newDate; });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isEditing = widget.initialData.isSingleEditMode;

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(widget.initialData.currentDrug.name),
        previousPageTitle: isEditing ? 'Riepilogo' : 'Durata',
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(height: 30),
              const Text(
                'PROMEMORIA DOSI E SCADENZA',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),

              // --- Dose Amount Stepper ---
              const Text('Quanto ne assumi ogni volta?', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: CupertinoColors.secondaryLabel)),
              const SizedBox(height: 12),
              _buildDoseStepper(
                value: _doseAmount,
                onDecrement: () {
                  if (_doseAmount > 1) setState(() => _doseAmount--);
                },
                onIncrement: () => setState(() => _doseAmount++),
                label: _doseAmount == 1 ? 'dose' : 'dosi',
              ),
              const SizedBox(height: 40),

              // --- Initial Doses in Package Stepper ---
              const Text('Quante dosi ci sono nella confezione?', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: CupertinoColors.secondaryLabel)),
              const SizedBox(height: 12),
              _buildDoseStepper(
                value: _initialDoses,
                onDecrement: () {
                  if (_initialDoses > 1) setState(() => _initialDoses--);
                },
                onIncrement: () => setState(() => _initialDoses++),
                label: _initialDoses == 1 ? 'dose' : 'dosi',
              ),
              const SizedBox(height: 40),

              // --- Low Stock Threshold Stepper ---
              const Text('Avvisami quando restano:', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: CupertinoColors.secondaryLabel)),
              const SizedBox(height: 12),
              _buildDoseStepper(
                value: _remainingDosesThreshold,
                onDecrement: () {
                  if (_remainingDosesThreshold > 1) setState(() => _remainingDosesThreshold--);
                },
                onIncrement: () => setState(() => _remainingDosesThreshold++),
                label: _remainingDosesThreshold == 1 ? 'dose' : 'dosi',
              ),
              const SizedBox(height: 40),

              _buildExpiryDateSelector(),
              const SizedBox(height: 50),
              CupertinoButton.filled(
                onPressed: _onConfirm,
                child: Text(isEditing ? 'Conferma' : 'Avanti'),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDoseStepper({
    required int value,
    required VoidCallback onDecrement,
    required VoidCallback onIncrement,
    required String label,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CupertinoButton(onPressed: onDecrement, child: const Icon(CupertinoIcons.minus_circle)),
        Container(
          width: 80, // Give it a fixed width for consistent alignment
          padding: const EdgeInsets.symmetric(vertical: 12),
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: CupertinoColors.tertiarySystemFill.resolveFrom(context),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            value.toString(),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ),
        CupertinoButton(onPressed: onIncrement, child: const Icon(CupertinoIcons.add_circled)),
        const SizedBox(width: 8),
        // Use a SizedBox to give the label a fixed width, helping to center the whole component
        SizedBox(
          width: 50,
          child: Text(label, style: const TextStyle(color: CupertinoColors.secondaryLabel, fontSize: 18)),
        ),
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
        const Text('Riceverai un avviso 7 giorni prima della scadenza', style: TextStyle(fontSize: 14, color: CupertinoColors.secondaryLabel)),
      ],
    );
  }
}
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
  late int _remainingDosesThreshold;
  DateTime? _expiryDate;
  final TextEditingController _initialDoseController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _remainingDosesThreshold = widget.initialData.doseThreshold;
    _expiryDate = widget.initialData.expiryDate;
    _initialDoseController.text = widget.initialData.initialDoses?.toString() ?? '';
  }

  @override
  void dispose() {
    _initialDoseController.dispose();
    super.dispose();
  }

  void _onConfirm() {
    final updatedData = widget.initialData
      ..doseThreshold = _remainingDosesThreshold
      ..expiryDate = _expiryDate
      ..initialDoses = int.tryParse(_initialDoseController.text);

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
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(widget.initialData.currentDrug.name),
        previousPageTitle: widget.initialData.isSingleEditMode ? 'Riepilogo' : 'Durata',
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
              const Text('Quante dosi ci sono nella confezione?', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: CupertinoColors.secondaryLabel)),
              const SizedBox(height: 8),
              CupertinoTextField(
                controller: _initialDoseController,
                placeholder: 'Es. 20',
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                padding: const EdgeInsets.all(12),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                decoration: BoxDecoration(
                  color: CupertinoColors.tertiarySystemFill.resolveFrom(context),
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              const SizedBox(height: 40),
              const Text('Avvisami quando restano:', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: CupertinoColors.secondaryLabel)),
              const SizedBox(height: 12),
              _buildDoseSelector(),
              const SizedBox(height: 40),
              _buildExpiryDateSelector(),
              const SizedBox(height: 50),
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
          child: Text(_remainingDosesThreshold.toString(), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        ),
        CupertinoButton(
          onPressed: () => setState(() => _remainingDosesThreshold++),
          child: const Icon(CupertinoIcons.add),
        ),
        const SizedBox(width: 8),
        const Text('Dosi', style: TextStyle(color: CupertinoColors.secondaryLabel)),
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
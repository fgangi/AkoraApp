import 'package:akora_app/core/navigation/app_router.dart';
import 'package:akora_app/data/models/drug_model.dart';
import 'package:akora_app/data/sources/local/app_database.dart'; // Needed for the Therapy data class
import 'package:akora_app/features/therapy_management/models/therapy_enums.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

class TherapyFrequencyScreen extends StatefulWidget {
  // For creating a new therapy, we pass the Drug selected from the search.
  final Drug? selectedDrug;
  // For editing an existing therapy, we pass the full Therapy object.
  final Therapy? initialTherapy;

  const TherapyFrequencyScreen({
    super.key,
    this.selectedDrug,
    this.initialTherapy,
    // This assertion ensures that you must provide one or the other, but not both/neither.
  }) : assert(selectedDrug != null || initialTherapy != null,
            'Either selectedDrug or initialTherapy must be provided');

  @override
  State<TherapyFrequencyScreen> createState() => _TherapyFrequencyScreenState();
}

class _TherapyFrequencyScreenState extends State<TherapyFrequencyScreen> {
  // Local state for this screen's selections
  TakingFrequency? _selectedFrequency;
  
  // A variable to hold the details of the drug being configured,
  // regardless of whether we are in create or edit mode.
  late Drug _currentDrug;

  @override
  void initState() {
    super.initState();
    if (widget.initialTherapy != null) {
      // --- EDIT MODE ---
      // We are editing, so pre-fill the state from the existing therapy object.
      _selectedFrequency = widget.initialTherapy!.takingFrequency;
      
      // We don't have a full 'Drug' object, so we create a temporary one
      // from the therapy data to display in the UI.
      _currentDrug = Drug(
        id: 'therapy_${widget.initialTherapy!.id}', // A temporary, unique ID
        name: widget.initialTherapy!.drugName,
        dosage: widget.initialTherapy!.drugDosage,
        // These fields are not stored in the Therapy table, so we use placeholders.
        activeIngredient: '', 
        quantityDescription: '', 
        form: DrugForm.other, 
      );

    } else {
      // --- CREATE MODE ---
      // We are creating a new therapy, so use the drug passed from the search screen.
      _currentDrug = widget.selectedDrug!;
    }
  }

  void _onFrequencySelected(TakingFrequency frequency) {
    setState(() {
      _selectedFrequency = frequency;
    });
  }

  void _navigateToNextStep() {
    if (_selectedFrequency == null) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Selezione Mancante'),
          content: const Text('Per favore, seleziona una frequenza.'),
          actions: [
            CupertinoDialogAction(
              child: const Text('OK'),
              isDefaultAction: true,
              onPressed: () => Navigator.pop(context),
            )
          ],
        ),
      );
      return;
    }
    
    // Navigate to the next screen (Reminder Time).
    // We now also pass the initialTherapy object if we are in edit mode.
    context.pushNamed(
      AppRouter.reminderTimeRouteName,
      extra: {
        'drug': _currentDrug, // Pass the drug details
        'frequency': _selectedFrequency!,
        'initialTherapy': widget.initialTherapy, // Will be null in create mode
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(_currentDrug.name), // Use the state variable _currentDrug
        previousPageTitle: widget.initialTherapy != null ? 'Dettagli' : 'Cerca',
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(height: 10),
              Text(
                _currentDrug.fullDescription, // Use the state variable
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: CupertinoColors.secondaryLabel,
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                'CON CHE FREQUENZA ASSUMI QUESTO FARMACO?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),

              // Frequency Options will now show the pre-selected value in edit mode
              _buildFrequencyButton(
                context: context,
                text: 'Una volta al giorno',
                isSelected: _selectedFrequency == TakingFrequency.onceDaily,
                onTap: () => _onFrequencySelected(TakingFrequency.onceDaily),
              ),
              const SizedBox(height: 12),
              _buildFrequencyButton(
                context: context,
                text: 'Due volte al giorno',
                isSelected: _selectedFrequency == TakingFrequency.twiceDaily,
                onTap: () => _onFrequencySelected(TakingFrequency.twiceDaily),
              ),
              const SizedBox(height: 12),
              _buildFrequencyButton(
                context: context,
                text: 'Una volta a settimana',
                isSelected: _selectedFrequency == TakingFrequency.onceWeekly,
                onTap: () => _onFrequencySelected(TakingFrequency.onceWeekly),
              ),
              const SizedBox(height: 12),
              _buildFrequencyButton(
                context: context,
                text: 'Altre opzioni...',
                isSelected: _selectedFrequency == TakingFrequency.other,
                onTap: () {
                  _onFrequencySelected(TakingFrequency.other);
                  print('Altre opzioni selected');
                },
              ),
              const Spacer(),
              CupertinoButton.filled(
                onPressed: _navigateToNextStep,
                child: const Text('Avanti'),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  // This helper widget doesn't need any changes.
  Widget _buildFrequencyButton({
    required BuildContext context,
    required String text,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = CupertinoTheme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        decoration: BoxDecoration(
          color: isSelected ? theme.primaryColor : CupertinoColors.tertiarySystemFill.resolveFrom(context),
          borderRadius: BorderRadius.circular(12.0),
          border: isSelected ? null : Border.all(
            color: CupertinoColors.separator.resolveFrom(context),
            width: 1.0,
          ),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: isSelected ? CupertinoColors.white : CupertinoColors.label.resolveFrom(context),
            ),
          ),
        ),
      ),
    );
  }
}
import 'package:akora_app/core/navigation/app_router.dart';
import 'package:akora_app/data/models/drug_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:akora_app/core/navigation/app_router.dart';
import 'package:akora_app/features/therapy_management/models/therapy_enums.dart';

class TherapyFrequencyScreen extends StatefulWidget {
  final Drug selectedDrug;

  const TherapyFrequencyScreen({super.key, required this.selectedDrug});

  @override
  State<TherapyFrequencyScreen> createState() => _TherapyFrequencyScreenState();
}

class _TherapyFrequencyScreenState extends State<TherapyFrequencyScreen> {
  TakingFrequency? _selectedFrequency;

  // This method updates the state when a frequency button is tapped.
  void _onFrequencySelected(TakingFrequency frequency) {
    setState(() {
      _selectedFrequency = frequency;
    });
  }

  // This method handles the logic for the "Avanti" button.
  void _navigateToNextStep() {
    // First, check if a frequency has been selected. If not, show an alert.
    if (_selectedFrequency == null) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Selezione Mancante'),
          content: const Text('Per favore, seleziona una frequenza di assunzione.'),
          actions: [
            CupertinoDialogAction(
              child: const Text('OK'),
              isDefaultAction: true,
              onPressed: () => Navigator.pop(context),
            )
          ],
        ),
      );
      return; // Stop execution if nothing is selected
    }

    // If a selection was made, navigate to the next screen (ReminderTimeScreen).
    // We pass both the drug and the selected frequency in a Map via the 'extra' parameter.
    context.pushNamed(
      AppRouter.reminderTimeRouteName,
      extra: {
        'drug': widget.selectedDrug,
        'frequency': _selectedFrequency!, // Use '!' because we've already checked for null.
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = CupertinoTheme.of(context);

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(widget.selectedDrug.name), // Show drug name in the nav bar
        previousPageTitle: 'Cerca', // Provides a back button title
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(height: 10),
              // Display the selected drug's full description for user context.
              Text(
                widget.selectedDrug.fullDescription,
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

              // --- Frequency Options ---
              // Each button is built by the helper method below.
              _buildFrequencyButton(
                context: context,
                text: 'Una volta al giorno',
                frequency: TakingFrequency.onceDaily,
                isSelected: _selectedFrequency == TakingFrequency.onceDaily,
                onTap: () => _onFrequencySelected(TakingFrequency.onceDaily),
              ),
              const SizedBox(height: 12),
              _buildFrequencyButton(
                context: context,
                text: 'Due volte al giorno',
                frequency: TakingFrequency.twiceDaily,
                isSelected: _selectedFrequency == TakingFrequency.twiceDaily,
                onTap: () => _onFrequencySelected(TakingFrequency.twiceDaily),
              ),
              const SizedBox(height: 12),
              _buildFrequencyButton(
                context: context,
                text: 'Una volta a settimana',
                frequency: TakingFrequency.onceWeekly,
                isSelected: _selectedFrequency == TakingFrequency.onceWeekly,
                onTap: () => _onFrequencySelected(TakingFrequency.onceWeekly),
              ),
              const SizedBox(height: 12),
              _buildFrequencyButton(
                context: context,
                text: 'Altre opzioni...',
                frequency: TakingFrequency.other,
                isSelected: _selectedFrequency == TakingFrequency.other,
                onTap: () {
                  _onFrequencySelected(TakingFrequency.other);
                  // TODO: Implement UI for custom frequency input (dialog or new screen).
                  print('Altre opzioni selected');
                },
              ),

              const Spacer(), // Pushes the "Avanti" button to the bottom of the screen.

              CupertinoButton.filled(
                onPressed: _navigateToNextStep,
                child: const Text('Avanti'),
              ),
              const SizedBox(height: 10), // Some padding at the very bottom.
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget to build the selectable frequency buttons, reducing code duplication.
  Widget _buildFrequencyButton({
    required BuildContext context,
    required String text,
    required TakingFrequency frequency,
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
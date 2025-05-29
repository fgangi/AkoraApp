// lib/features/therapy_management/screens/therapy_frequency_screen.dart
import 'package:akora_app/data/models/drug_model.dart';
import 'package:flutter/cupertino.dart';
// TODO: Import AppRouter and next screen's route name when ready

enum TakingFrequency { onceDaily, twiceDaily, onceWeekly, other }

class TherapyFrequencyScreen extends StatefulWidget {
  final Drug selectedDrug;

  const TherapyFrequencyScreen({super.key, required this.selectedDrug});

  @override
  State<TherapyFrequencyScreen> createState() => _TherapyFrequencyScreenState();
}

class _TherapyFrequencyScreenState extends State<TherapyFrequencyScreen> {
  TakingFrequency? _selectedFrequency;
  // TODO: Add state for "Altre opzioni..." if needed

  void _onFrequencySelected(TakingFrequency frequency) {
    setState(() {
      _selectedFrequency = frequency;
    });
  }

  void _navigateToNextStep() {
    if (_selectedFrequency == null) {
      // Show an alert or disable button if no frequency is selected
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
    print('Selected Drug: ${widget.selectedDrug.name}');
    print('Selected Frequency: $_selectedFrequency');
    // TODO: Navigate to the next screen (e.g., reminder time - Mockup Page 7)
    // You'll pass both selectedDrug and _selectedFrequency (or derived data)
    // context.pushNamed(AppRouter.reminderTimeRouteName, extra: {'drug': widget.selectedDrug, 'frequency': _selectedFrequency});
  }

  @override
  Widget build(BuildContext context) {
    final theme = CupertinoTheme.of(context);

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(widget.selectedDrug.name), // Show drug name in nav bar
        previousPageTitle: 'Cerca', // Or "Conferma" if there was an intermediate screen
        // We'll add a back button later if needed, GoRouter handles it by default
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(height: 10),
              // Displaying the selected drug again (optional, but good for context)
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

              // Frequency Options
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
                frequency: TakingFrequency.other, // Special case
                isSelected: _selectedFrequency == TakingFrequency.other,
                onTap: () {
                  _onFrequencySelected(TakingFrequency.other);
                  // TODO: Show a dialog or navigate to a screen for custom frequency input
                  print('Altre opzioni selected');
                },
              ),

              const Spacer(), // Pushes the button to the bottom

              CupertinoButton.filled(
                onPressed: _navigateToNextStep,
                child: const Text('Avanti'),
              ),
              const SizedBox(height: 10), // Padding at the bottom
            ],
          ),
        ),
      ),
    );
  }

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
          color: isSelected ? theme.primaryColor : theme.scaffoldBackgroundColor, // Or a light grey like CupertinoColors.tertiarySystemFill
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(
            color: isSelected ? theme.primaryColor : CupertinoColors.separator.resolveFrom(context),
            width: 1.5,
          ),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: isSelected ? CupertinoColors.white : theme.primaryColor, // Or CupertinoColors.label
            ),
          ),
        ),
      ),
    );
  }
}
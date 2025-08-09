import 'package:akora_app/core/navigation/app_router.dart';
import 'package:akora_app/features/therapy_management/models/therapy_enums.dart';
import 'package:akora_app/features/therapy_management/models/therapy_setup_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

class TherapyFrequencyScreen extends StatefulWidget {
  final TherapySetupData initialData;
  const TherapyFrequencyScreen({super.key, required this.initialData});

  @override
  State<TherapyFrequencyScreen> createState() => _TherapyFrequencyScreenState();
}

class _TherapyFrequencyScreenState extends State<TherapyFrequencyScreen> {
  late TakingFrequency _selectedFrequency;

  @override
  void initState() {
    super.initState();
    _selectedFrequency = widget.initialData.selectedFrequency;
  }

  void _onFrequencySelected(TakingFrequency frequency) {
    setState(() {
      _selectedFrequency = frequency;
    });
  }

  void _navigateToNextStep() {
    widget.initialData.selectedFrequency = _selectedFrequency;

    if (widget.initialData.isEditing) {
      context.pop(widget.initialData);
      return;
    }
    
    context.pushNamed(AppRouter.reminderTimeRouteName, extra: widget.initialData);
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(widget.initialData.currentDrug.name),
        // Determine the back button title based on the mode.
        previousPageTitle:
            widget.initialData.initialTherapy != null ? 'Dettagli' : 'Cerca',
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(height: 10),
              Text(
                widget.initialData.currentDrug.fullDescription,
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

              _buildFrequencyButton(
                text: 'Una volta al giorno',
                isSelected: _selectedFrequency == TakingFrequency.onceDaily,
                onTap: () => _onFrequencySelected(TakingFrequency.onceDaily),
              ),
              const SizedBox(height: 12),
              _buildFrequencyButton(
                text: 'Due volte al giorno',
                isSelected: _selectedFrequency == TakingFrequency.twiceDaily,
                onTap: () => _onFrequencySelected(TakingFrequency.twiceDaily),
              ),
              const SizedBox(height: 12),
              _buildFrequencyButton(
                text: 'Una volta a settimana',
                isSelected: _selectedFrequency == TakingFrequency.onceWeekly,
                onTap: () => _onFrequencySelected(TakingFrequency.onceWeekly),
              ),
              const SizedBox(height: 12),
              _buildFrequencyButton(
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

  Widget _buildFrequencyButton({
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
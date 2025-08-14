import 'package:akora_app/core/navigation/app_router.dart';
import 'package:akora_app/features/therapy_management/models/therapy_enums.dart';
import 'package:akora_app/features/therapy_management/models/therapy_setup_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

class TherapyFrequencyScreen extends StatefulWidget {
  // This constructor is now simpler. It only accepts the unified data model.
  final TherapySetupData initialData;

  const TherapyFrequencyScreen({
    super.key,
    required this.initialData,
  });

  @override
  State<TherapyFrequencyScreen> createState() => _TherapyFrequencyScreenState();
}

class _TherapyFrequencyScreenState extends State<TherapyFrequencyScreen> {
  late TherapySetupData _currentData;
  late bool _isSingleEditMode;

  @override
  void initState() {
    super.initState();
    _currentData = widget.initialData;
    // Set our local convenience flag from the model
    _isSingleEditMode = _currentData.isSingleEditMode;
  }

  void _onFrequencySelected(TakingFrequency frequency) {
    setState(() {
      _currentData.selectedFrequency = frequency;
    });
  }

  void _onConfirm() {
    if (_isSingleEditMode) { // or check _currentData.isSingleEditMode directly
      context.pop(_currentData);
    } else {
      context.pushNamed(
        AppRouter.reminderTimeRouteName,
        extra: _currentData,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // The build method now determines the button and back title text
    // based on the more specific 'isSingleEditMode' flag.
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(_currentData.currentDrug.name),
        // If it's a single edit, the previous page was the summary.
        // Otherwise, it was the search screen.
        previousPageTitle: _isSingleEditMode ? 'Riepilogo' : 'Cerca',
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(height: 10),
              Text(
                _currentData.currentDrug.fullDescription,
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
                context: context,
                text: 'Una volta al giorno',
                isSelected: _currentData.selectedFrequency == TakingFrequency.onceDaily,
                onTap: () => _onFrequencySelected(TakingFrequency.onceDaily),
              ),
              const SizedBox(height: 12),
              _buildFrequencyButton(
                context: context,
                text: 'Due volte al giorno',
                isSelected: _currentData.selectedFrequency == TakingFrequency.twiceDaily,
                onTap: () => _onFrequencySelected(TakingFrequency.twiceDaily),
              ),
              const SizedBox(height: 12),
              _buildFrequencyButton(
                context: context,
                text: 'Una volta a settimana',
                isSelected: _currentData.selectedFrequency == TakingFrequency.onceWeekly,
                onTap: () => _onFrequencySelected(TakingFrequency.onceWeekly),
              ),
              const Spacer(),
              CupertinoButton.filled(
                onPressed: _onConfirm,
                // The button text is now "Conferma" only for single edits,
                // and "Avanti" for all full setup flows (create or edit).
                child: Text(_isSingleEditMode ? 'Conferma' : 'Avanti'),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFrequencyButton({
    required BuildContext context,
    required String text,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    // This helper method is perfect and needs no changes.
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
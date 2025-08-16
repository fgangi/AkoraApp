import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class DoseStatusIcon extends StatelessWidget {
  final bool isTaken;
  final VoidCallback onTap;

  const DoseStatusIcon({
    super.key,
    required this.isTaken,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = CupertinoTheme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 36, // Smaller size for the icons
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isTaken ? CupertinoColors.systemGreen : theme.primaryColor.withOpacity(0.15),
          border: Border.all(
            color: isTaken ? CupertinoColors.systemGreen : theme.primaryColor,
            width: 2,
          ),
        ),
        child: Center(
          child: isTaken
              ? const FaIcon(
                  FontAwesomeIcons.check,
                  color: CupertinoColors.white,
                  size: 16,
                )
              : null, // Show nothing inside if not taken
        ),
      ),
    );
  }
}
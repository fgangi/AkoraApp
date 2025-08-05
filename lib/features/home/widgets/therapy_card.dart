import 'package:akora_app/data/sources/local/app_database.dart';
import 'package:akora_app/core/navigation/app_router.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'; // For TimeOfDay
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class TherapyCard extends StatelessWidget {
  final Therapy therapy;

  const TherapyCard({super.key, required this.therapy});

  @override
  Widget build(BuildContext context) {
    final theme = CupertinoTheme.of(context);
    final time = TimeOfDay(hour: therapy.reminderHour, minute: therapy.reminderMinute);

    return GestureDetector(
      onTap: () {
        context.pushNamed(AppRouter.therapyDetailRouteName, extra: therapy);
      },
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: CupertinoColors.secondarySystemGroupedBackground.resolveFrom(context),
          // The borderRadius is now handled by ClipRRect in the parent.
          // The margin is now handled by Padding in the parent.
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.systemGrey.withOpacity(0.15),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3),
            )
          ],
        ),
        child: Row(
          children: [
            // Left side: Icon and Time
            Column(
              children: [
                FaIcon(
                  FontAwesomeIcons.pills, // TODO: Map this icon based on drug form from therapy data
                  color: theme.primaryColor,
                  size: 32,
                ),
                const SizedBox(height: 8),
                Text(
                  time.format(context),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            // Right side: Drug details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    therapy.drugName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    therapy.drugDosage,
                    style: const TextStyle(
                      fontSize: 16,
                      color: CupertinoColors.secondaryLabel,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6.0),
                    ),
                    child: Text(
                      '1 compressa', // TODO: This should come from the therapy data (e.g., amount per dose)
                      style: TextStyle(
                        color: theme.primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Far right: Chevron
            const Icon(CupertinoIcons.chevron_forward, color: CupertinoColors.inactiveGray),
          ],
        ),
      ),
    );
  }
}
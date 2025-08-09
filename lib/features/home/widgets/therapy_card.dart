import 'package:akora_app/data/sources/local/app_database.dart';
import 'package:akora_app/core/services/notification_service.dart';
import 'package:akora_app/main.dart'; // To access the global 'db' instance
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'; // For TimeOfDay
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:akora_app/core/navigation/app_router.dart';
import 'package:timezone/timezone.dart' as tz;

class TherapyCard extends StatefulWidget {
  final Therapy therapy;

  const TherapyCard({super.key, required this.therapy});

  @override
  State<TherapyCard> createState() => _TherapyCardState();
}

class _TherapyCardState extends State<TherapyCard> {
  // A stream that will tell us if today's dose has been logged
  late Stream<MedicationLog?> _logStream;
  
  @override
  void initState() {
    super.initState();
    // Subscribe to the stream that watches for a log entry for this specific therapy for today.
    _logStream = db.watchDoseLogForDay(
      therapyId: widget.therapy.id,
      day: DateTime.now(),
    );
  }

  void _markAsTaken() async { // Make the method async
    final now = DateTime.now();
    final scheduledTimeForToday = DateTime(
      now.year,
      now.month,
      now.day,
      widget.therapy.reminderHour,
      widget.therapy.reminderMinute,
    );

    // We need to know what the count will be *after* we decrement it.
    if (widget.therapy.dosesRemaining != null) {
      final newDoseCount = widget.therapy.dosesRemaining! - 1;
      
      // Check if the new count has hit the threshold
      if (newDoseCount == widget.therapy.doseThreshold) {
        // If it has, trigger the low stock notification
        await NotificationService().scheduleLowStockNotification(
          therapyId: widget.therapy.id,
          drugName: widget.therapy.drugName,
          remainingDoses: newDoseCount,
        );
      }
    }
    
    // Now, log the dose and decrement in the database
    await db.logDoseTaken(
      therapyId: widget.therapy.id,
      scheduledTime: scheduledTimeForToday,
    );

    // Cancel today's upcoming notification
    NotificationService().cancelDailyNotification(widget.therapy.id, DateTime.now());
  }

  void _undoTaken() {
    final now = DateTime.now();
    final scheduledTimeForToday = DateTime(
      now.year,
      now.month,
      now.day,
      widget.therapy.reminderHour,
      widget.therapy.reminderMinute,
    );
    
    // Remove the log from the database
    db.removeDoseLog(
      therapyId: widget.therapy.id,
      scheduledTime: scheduledTimeForToday,
    );

    // --- Reschedule today's notification IF it's still in the future ---
    final scheduledDateTime = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      widget.therapy.reminderHour,
      widget.therapy.reminderMinute,
    );

    if (scheduledDateTime.isAfter(tz.TZDateTime.now(tz.local))) {
      NotificationService().scheduleNotificationForTherapy(widget.therapy);
      // Note: This reschedules ALL future notifications for the therapy. A more optimized
      // version would just schedule today's, but this is safer and works well.
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = CupertinoTheme.of(context);
    final time = TimeOfDay(hour: widget.therapy.reminderHour, minute: widget.therapy.reminderMinute);

    // Logic to check if the remaining dose count is low
    bool areDosesLow = false;
    if (widget.therapy.dosesRemaining != null) {
      if (widget.therapy.dosesRemaining! <= widget.therapy.doseThreshold) {
        areDosesLow = true;
      }
    }

    return GestureDetector(
      onTap: () {
        context.pushNamed(AppRouter.therapyDetailRouteName, extra: widget.therapy);
      },
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: CupertinoColors.secondarySystemGroupedBackground.resolveFrom(context),
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
                FaIcon(FontAwesomeIcons.pills, color: theme.primaryColor, size: 32),
                const SizedBox(height: 8),
                Text(
                  time.format(context),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(width: 16),
            // Middle section: Drug details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.therapy.drugName,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.therapy.drugDosage,
                    style: const TextStyle(fontSize: 16, color: CupertinoColors.secondaryLabel),
                  ),
                  const SizedBox(height: 8),
                  
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: theme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6.0),
                        ),
                        child: Text(
                          '1 compressa', // Placeholder for dose amount
                          style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.w500),
                        ),
                      ),
                      const Spacer(),
                      
                      // Conditionally display the remaining dose count text
                      if (widget.therapy.dosesRemaining != null)
                        Text(
                          'Rimaste: ${widget.therapy.dosesRemaining}',
                          style: TextStyle(
                            fontSize: 14,
                            // Apply warning style if doses are low
                            color: areDosesLow ? CupertinoColors.systemRed : CupertinoColors.secondaryLabel,
                            fontWeight: areDosesLow ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Checkmark Button
            StreamBuilder<MedicationLog?>(
              stream: _logStream,
              builder: (context, snapshot) {
                final bool isTaken = snapshot.hasData && snapshot.data != null;

                return GestureDetector(
                  // If it's taken, the tap action is _undoTaken.
                  // If it's not taken, the tap action is _markAsTaken.
                  onTap: isTaken ? _undoTaken : _markAsTaken,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isTaken ? CupertinoColors.systemGreen : CupertinoColors.systemGrey5,
                    ),
                    child: Center(
                      child: FaIcon(
                        FontAwesomeIcons.check,
                        color: isTaken ? CupertinoColors.white : CupertinoColors.systemGrey,
                        size: 24,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
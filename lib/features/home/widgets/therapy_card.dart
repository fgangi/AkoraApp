import 'package:akora_app/core/navigation/app_router.dart';
import 'package:akora_app/core/services/notification_service.dart';
import 'package:akora_app/data/sources/local/app_database.dart';
import 'package:akora_app/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'; // For TimeOfDay
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:timezone/timezone.dart' as tz; // Keep timezone import for safety

class TherapyCard extends StatefulWidget {
  final Therapy therapy;

  //const TherapyCard({super.key, required this.therapy});
  final AppDatabase database;
  final NotificationService notificationService;

  // Modify the constructor to require them
  const TherapyCard({
    super.key,
    required this.therapy,
    required this.database,
    required this.notificationService,
  });
  @override
  State<TherapyCard> createState() => _TherapyCardState();
}

class _TherapyCardState extends State<TherapyCard> {
  // Now we watch a list of logs for today, to handle multiple doses
  late Stream<List<MedicationLog>> _logsStreamForToday;

  @override
  void initState() {
    super.initState();
    // This query is slightly different. Instead of watchSingleOrNull, we watch a list.
    _logsStreamForToday = widget.database.watchDoseLogsForDay(
      therapyId: widget.therapy.id,
      day: DateTime.now(),
    );
  }

  // Determines which dose is the "current" one based on the time of day.
  TimeOfDay _getCurrentDoseTime() {
    final now = TimeOfDay.now();
    
    // Convert reminder time strings to TimeOfDay objects
    final reminderTimes = widget.therapy.reminderTimes.map((t) {
      final parts = t.split(':');
      return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    }).toList();

    // Find the last scheduled time that has passed or is now
    TimeOfDay? relevantTime;
    for (final time in reminderTimes) {
      final timeMinutes = time.hour * 60 + time.minute;
      final nowMinutes = now.hour * 60 + now.minute;
      if (timeMinutes <= nowMinutes) {
        relevantTime = time;
      } else {
        // If we find a time in the future, we're done.
        break;
      }
    }
    
    // If no time has passed yet today, default to the first dose.
    // If all times have passed, default to the last dose.
    return relevantTime ?? reminderTimes.first;
  }

  void _markAsTaken(TimeOfDay doseTime) async {
    if (widget.therapy.dosesRemaining != null) {
      final newDoseCount = widget.therapy.dosesRemaining! - 1;
      if (newDoseCount <= widget.therapy.doseThreshold) {
        await widget.notificationService.triggerLowStockNotification(
          therapyId: widget.therapy.id,
          drugName: widget.therapy.drugName,
          remainingDoses: newDoseCount,
        );
      }
    }

    final now = DateTime.now();
    final scheduledTimeForToday = DateTime(now.year, now.month, now.day, doseTime.hour, doseTime.minute);
    
    await widget.database.logDoseTaken(therapyId: widget.therapy.id, scheduledTime: scheduledTimeForToday);

    // Cancel and reschedule is a safe way to handle notification updates
    await widget.notificationService.cancelTherapyNotifications(widget.therapy);
    await widget.notificationService.scheduleNotificationForTherapy(widget.therapy);
  }

  void _undoTaken(TimeOfDay doseTime) async {
    final now = DateTime.now();
    final scheduledTimeForToday = DateTime(now.year, now.month, now.day, doseTime.hour, doseTime.minute);
    
    await widget.database.removeDoseLog(therapyId: widget.therapy.id, scheduledTime: scheduledTimeForToday);

    // Reschedule all notifications to bring back the undone one (if it's in the future)
    await widget.notificationService.cancelTherapyNotifications(widget.therapy);
    await widget.notificationService.scheduleNotificationForTherapy(widget.therapy);
  }

  @override
  Widget build(BuildContext context) {
    final theme = CupertinoTheme.of(context);
    
    // Determine the main time to display on the left.
    // For "twice daily", we might show the next upcoming time. For now, we'll show the first.
    final String displayTime = widget.therapy.reminderTimes.isNotEmpty
        ? widget.therapy.reminderTimes[0]
        : '--:--';

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
        // Increased vertical padding to make the card taller and cleaner
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        decoration: BoxDecoration(
          color: CupertinoColors.white, // A white background like the mockup
          // The parent ClipRRect in home_screen.dart handles rounding
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center, // Vertically center align items
          children: [
            // --- Left Section: Icon and Time ---
            // No fixed width, so the time text won't wrap
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FaIcon(FontAwesomeIcons.pills, color: theme.primaryColor, size: 30),
                const SizedBox(height: 8),
                Text(
                  displayTime,
                  style: const TextStyle(
                    fontSize: 22, // Larger font for the time
                    fontWeight: FontWeight.bold,
                    color: CupertinoColors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),

            // --- Middle Section: Drug Details ---
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.therapy.drugName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: CupertinoColors.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.therapy.drugDosage,
                    style: const TextStyle(fontSize: 15, color: CupertinoColors.secondaryLabel),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: theme.primaryColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Text(
                          '${widget.therapy.doseAmount} ${int.tryParse(widget.therapy.doseAmount) == 1 ? "dose" : "dosi"}',
                          style: TextStyle(
                            color: theme.primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const Spacer(),
                      if (widget.therapy.dosesRemaining != null)
                        Text(
                          'Rimaste: ${widget.therapy.dosesRemaining}',
                          style: TextStyle(
                            fontSize: 14,
                            color: areDosesLow ? CupertinoColors.systemRed : CupertinoColors.secondaryLabel,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),

            // --- Right Section: Checkmark Button ---
            StreamBuilder<List<MedicationLog>>(
              stream: _logsStreamForToday,
              builder: (context, snapshot) {
                final takenLogs = snapshot.data ?? [];
                final relevantDoseTime = _getCurrentDoseTime();
                final isTaken = takenLogs.any((log) =>
                    log.scheduledDoseTime.hour == relevantDoseTime.hour &&
                    log.scheduledDoseTime.minute == relevantDoseTime.minute);

                return GestureDetector(
                  onTap: () {
                    if (isTaken) {
                      _undoTaken(relevantDoseTime);
                    } else {
                      _markAsTaken(relevantDoseTime);
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 50, // Made slightly smaller to match mockup
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isTaken ? CupertinoColors.systemGreen : CupertinoColors.systemGrey5,
                    ),
                    child: Center(
                      child: FaIcon(
                        FontAwesomeIcons.check,
                        color: isTaken ? CupertinoColors.white : CupertinoColors.systemGrey,
                        size: 22,
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
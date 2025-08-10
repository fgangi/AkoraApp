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

  const TherapyCard({super.key, required this.therapy});

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
    _logsStreamForToday = db.watchDoseLogsForDay(
      therapyId: widget.therapy.id,
      day: DateTime.now(),
    );
  }

  // --- NEW HELPER METHOD ---
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
  
  // --- REFACTORED METHODS ---

  void _markAsTaken(TimeOfDay doseTime) async {
    if (widget.therapy.dosesRemaining != null) {
      final newDoseCount = widget.therapy.dosesRemaining! - 1;
      if (newDoseCount <= widget.therapy.doseThreshold) {
        await NotificationService().triggerLowStockNotification(
          therapyId: widget.therapy.id,
          drugName: widget.therapy.drugName,
          remainingDoses: newDoseCount,
        );
      }
    }

    final now = DateTime.now();
    final scheduledTimeForToday = DateTime(now.year, now.month, now.day, doseTime.hour, doseTime.minute);
    
    await db.logDoseTaken(therapyId: widget.therapy.id, scheduledTime: scheduledTimeForToday);

    // Cancel and reschedule is a safe way to handle notification updates
    await NotificationService().cancelTherapyNotifications(widget.therapy);
    await NotificationService().scheduleNotificationForTherapy(widget.therapy);
  }

  void _undoTaken(TimeOfDay doseTime) async {
    final now = DateTime.now();
    final scheduledTimeForToday = DateTime(now.year, now.month, now.day, doseTime.hour, doseTime.minute);
    
    await db.removeDoseLog(therapyId: widget.therapy.id, scheduledTime: scheduledTimeForToday);

    // Reschedule all notifications to bring back the undone one (if it's in the future)
    await NotificationService().cancelTherapyNotifications(widget.therapy);
    await NotificationService().scheduleNotificationForTherapy(widget.therapy);
  }

  @override
  Widget build(BuildContext context) {
    final theme = CupertinoTheme.of(context);
    // Display all reminder times, joined by a separator
    final String displayTime = widget.therapy.reminderTimes.join(' - ');

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
                Text(displayTime, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(width: 16),
            // Middle section: Drug details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.therapy.drugName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(widget.therapy.drugDosage, style: const TextStyle(fontSize: 16, color: CupertinoColors.secondaryLabel)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: theme.primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(6.0)),
                        child: Text('${widget.therapy.doseAmount} ${widget.therapy.doseUnit}', style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.w500)),
                      ),
                      const Spacer(),
                      if (widget.therapy.dosesRemaining != null)
                        Text(
                          'Rimaste: ${widget.therapy.dosesRemaining}',
                          style: TextStyle(fontSize: 14, color: areDosesLow ? CupertinoColors.systemRed : CupertinoColors.secondaryLabel, fontWeight: areDosesLow ? FontWeight.bold : FontWeight.normal),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Checkmark Button
            StreamBuilder<List<MedicationLog>>( // Now watches a List of logs
              stream: _logsStreamForToday,
              builder: (context, snapshot) {
                final takenLogs = snapshot.data ?? [];
                
                // Determine which dose we are currently interacting with
                final relevantDoseTime = _getCurrentDoseTime();
                
                // Check if this specific dose has been taken
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
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: isTaken ? CupertinoColors.systemGreen : CupertinoColors.systemGrey5),
                    child: Center(child: FaIcon(FontAwesomeIcons.check, color: isTaken ? CupertinoColors.white : CupertinoColors.systemGrey, size: 24)),
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
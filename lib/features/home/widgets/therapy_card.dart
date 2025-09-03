import 'package:akora_app/core/services/notification_service.dart';
import 'package:akora_app/data/sources/local/app_database.dart';
import 'package:akora_app/features/home/widgets/dose_status_icon.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show TimeOfDay;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class TherapyCard extends StatefulWidget {
  final Therapy therapy;
  final VoidCallback onTap;
  final AppDatabase database;
  final NotificationService notificationService;

  const TherapyCard({
    super.key,
    required this.therapy,
    required this.onTap,
    required this.database,
    required this.notificationService,
  });

  @override
  State<TherapyCard> createState() => _TherapyCardState();
}

class _TherapyCardState extends State<TherapyCard> {
  late Stream<List<MedicationLog>> _logsStreamForToday;

  @override
  void initState() {
    super.initState();
    _logsStreamForToday = widget.database.watchDoseLogsForDay(
      therapyId: widget.therapy.id,
      day: DateTime.now(),
    );
  }

  void _markAsTaken(TimeOfDay doseTime) async {
    final int amountToTake = int.tryParse(widget.therapy.doseAmount) ?? 1;

    if (widget.therapy.dosesRemaining != null) {
      final newDoseCount = widget.therapy.dosesRemaining! - amountToTake;
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
    
    await widget.database.logDoseTaken(
      therapyId: widget.therapy.id,
      scheduledTime: scheduledTimeForToday,
      amount: amountToTake,
    );

    await widget.notificationService.cancelTherapyNotifications(widget.therapy);
    await widget.notificationService.scheduleNotificationForTherapy(widget.therapy);
  }

  void _undoTaken(TimeOfDay doseTime) async {
    final int amountToRestore = int.tryParse(widget.therapy.doseAmount) ?? 1;
    final now = DateTime.now();
    final scheduledTimeForToday = DateTime(now.year, now.month, now.day, doseTime.hour, doseTime.minute);
    
    await widget.database.removeDoseLog(
      therapyId: widget.therapy.id,
      scheduledTime: scheduledTimeForToday,
      amount: amountToRestore,
    );

    await widget.notificationService.cancelTherapyNotifications(widget.therapy);
    await widget.notificationService.scheduleNotificationForTherapy(widget.therapy);
  }

  @override
  Widget build(BuildContext context) {
    final theme = CupertinoTheme.of(context);
    
    final reminderTimes = widget.therapy.reminderTimes.map((t) {
      final parts = t.split(':');
      return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    }).toList();

    bool areDosesLow = false;
    if (widget.therapy.dosesRemaining != null) {
      if (widget.therapy.dosesRemaining! <= widget.therapy.doseThreshold) {
        areDosesLow = true;
      }
    }

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        decoration: const BoxDecoration(
          color: CupertinoColors.white,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // --- Left Section: Icon and Time (Unchanged) ---
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FaIcon(FontAwesomeIcons.pills, color: theme.primaryColor, size: 30),
                const SizedBox(height: 8),
                ...reminderTimes.map((time) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 2.0),
                    child: Text(
                      time.format(context),
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: CupertinoColors.black),
                    ),
                  );
                }).toList(),
              ],
            ),
            const SizedBox(width: 16),
            
            // --- Middle Section: Drug Details ---
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(widget.therapy.drugName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: CupertinoColors.black), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(widget.therapy.drugDosage, style: const TextStyle(fontSize: 15, color: CupertinoColors.secondaryLabel)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(color: theme.primaryColor.withOpacity(0.15), borderRadius: BorderRadius.circular(8.0)),
                        child: Text(
                          '${widget.therapy.doseAmount} ${int.tryParse(widget.therapy.doseAmount) == 1 ? "dose" : "dosi"}',
                          style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),

            // --- Right Section: Buttons and Remaining Count ---
            StreamBuilder<List<MedicationLog>>(
              stream: _logsStreamForToday,
              builder: (context, snapshot) {
                final takenLogs = snapshot.data ?? [];
                
                final reminderTimes = widget.therapy.reminderTimes.map((t) {
                  final parts = t.split(':');
                  return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
                }).toList()
                  ..sort((a, b) => (a.hour * 60 + a.minute).compareTo(b.hour * 60 + b.minute));

                // This is the Column that will hold both the action buttons and the text
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // --- Top Part: The Action Buttons ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: reminderTimes.map((doseTime) {
                        final isTaken = takenLogs.any((log) =>
                            log.scheduledDoseTime.hour == doseTime.hour &&
                            log.scheduledDoseTime.minute == doseTime.minute);
                        
                        return Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: DoseStatusIcon(
                            isTaken: isTaken,
                            onTap: () {
                              if (isTaken) {
                                _undoTaken(doseTime);
                              } else {
                                _markAsTaken(doseTime);
                              }
                            },
                          ),
                        );
                      }).toList(),
                    ),

                    // --- Bottom Part: The "Rimaste" Text ---
                    // Add some space between the buttons and the text
                    const SizedBox(height: 8), 
                    if (widget.therapy.dosesRemaining != null)
                      Text(
                        'Rimaste: ${widget.therapy.dosesRemaining}',
                        style: TextStyle(
                          fontSize: 14,
                          color: areDosesLow ? CupertinoColors.systemRed : CupertinoColors.secondaryLabel,
                        ),
                      )
                    else
                      // Add an empty SizedBox to maintain alignment if dose tracking is off
                      const SizedBox(height: 17), // Approx height of the Text
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
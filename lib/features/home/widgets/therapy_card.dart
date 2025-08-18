import 'package:akora_app/core/navigation/app_router.dart';
import 'package:akora_app/core/services/notification_service.dart';
import 'package:akora_app/data/sources/local/app_database.dart';
import 'package:akora_app/features/home/widgets/dose_status_icon.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show TimeOfDay;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

class TherapyCard extends StatefulWidget {
  final Therapy therapy;
  final AppDatabase database;
  final NotificationService notificationService;

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
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        decoration: BoxDecoration(
          color: CupertinoColors.white,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FaIcon(FontAwesomeIcons.pills, color: theme.primaryColor, size: 30),
                const SizedBox(height: 8),
                Text(
                  displayTime,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: CupertinoColors.black),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(widget.therapy.drugName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: CupertinoColors.black), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(widget.therapy.drugDosage, style: const TextStyle(fontSize: 15, color: CupertinoColors.secondaryLabel)),
                  const SizedBox(height: 8),

                  // Dose Amount Bubble (e.g., "1 dose")
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(color: theme.primaryColor.withOpacity(0.15), borderRadius: BorderRadius.circular(8.0)),
                    child: Text(
                      '${widget.therapy.doseAmount} ${int.tryParse(widget.therapy.doseAmount) == 1 ? "dose" : "dosi"}',
                      style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),

                  // Doses Remaining Text - now on its own line
                  if (widget.therapy.dosesRemaining != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 6.0), // Add a little space above
                      child: Text(
                        'Rimaste: ${widget.therapy.dosesRemaining}',
                        style: TextStyle(
                          fontSize: 14,
                          color: areDosesLow ? CupertinoColors.systemRed : CupertinoColors.secondaryLabel,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            StreamBuilder<List<MedicationLog>>(
              stream: _logsStreamForToday,
              builder: (context, snapshot) {
                final takenLogs = snapshot.data ?? [];
                final reminderTimes = widget.therapy.reminderTimes.map((t) {
                  final parts = t.split(':');
                  return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
                }).toList()
                  ..sort((a, b) => (a.hour * 60 + a.minute).compareTo(b.hour * 60 + b.minute));

                if (reminderTimes.length == 1) {
                  final theOnlyDoseTime = reminderTimes.first;
                  final isTaken = takenLogs.any((log) =>
                      log.scheduledDoseTime.hour == theOnlyDoseTime.hour &&
                      log.scheduledDoseTime.minute == theOnlyDoseTime.minute);

                  return GestureDetector(
                    onTap: () => isTaken ? _undoTaken(theOnlyDoseTime) : _markAsTaken(theOnlyDoseTime),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 50, height: 50,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: isTaken ? CupertinoColors.systemGreen : CupertinoColors.systemGrey5),
                      child: Center(child: FaIcon(FontAwesomeIcons.check, color: isTaken ? CupertinoColors.white : CupertinoColors.systemGrey, size: 22)),
                    ),
                  );
                }

                return Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: reminderTimes.map((doseTime) {
                    final isTaken = takenLogs.any((log) =>
                        log.scheduledDoseTime.hour == doseTime.hour &&
                        log.scheduledDoseTime.minute == doseTime.minute);
                    
                    return Padding(
                      padding: const EdgeInsets.only(left: 6.0),
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
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
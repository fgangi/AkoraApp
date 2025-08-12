import 'package:akora_app/core/navigation/app_router.dart';
import 'package:akora_app/core/services/notification_service.dart';
import 'package:akora_app/data/sources/local/app_database.dart';
import 'package:akora_app/features/home/widgets/therapy_card.dart';
import 'package:akora_app/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // The stream now points back to the simple query for ALL active therapies.
  late Stream<List<Therapy>> _therapiesStream;
  Timer? _dayChangeTimer;

  // A key that we can change to force the ListView to rebuild
  Key _listViewKey = UniqueKey(); 

  @override
  void initState() {
    super.initState();
    _therapiesStream = db.watchAllActiveTherapies();
    _startDayChangeListener();
  }

  @override
  void dispose() {
    _dayChangeTimer?.cancel(); // Always cancel timers
    super.dispose();
  }

  void _startDayChangeListener() {
    // This timer will fire every minute to check if the day has changed.
    _dayChangeTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      final now = DateTime.now();
      // If the timer fires and the time is between 00:00 and 00:01,
      // it's very likely the day has just changed.
      if (now.hour == 0 && now.minute <= 1) {
        print("--- Midnight detected! Rebuilding HomeScreen. ---");
        // Changing the key of the ListView is a clean and effective way
        // to force Flutter to dispose of the old list and build a new one from scratch.
        // This will cause all TherapyCards to re-run their initState.
        setState(() {
          _listViewKey = UniqueKey();
        });
      }
    });
  }

  void _deleteTherapy(Therapy therapyToDelete) {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Conferma Eliminazione'),
        content: const Text(
            'Sei sicuro di voler eliminare questa terapia? Questa azione non può essere annullata.'),
        actions: [
          CupertinoDialogAction(
            child: const Text('Annulla'),
            onPressed: () => Navigator.pop(ctx),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('Elimina'),
            onPressed: () async {
              await NotificationService().cancelTherapyNotifications(therapyToDelete);
              await db.deleteTherapy(therapyToDelete.id);
              if (mounted) Navigator.pop(ctx);
            },
          ),
        ],
      ),
    );
  }

  void _editTherapy(Therapy therapy) {
    context.pushNamed(
      AppRouter.addTherapyStartRouteName,
      extra: therapy,
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        // The middle widget is now your logo image.
        middle: Image.asset(
          'assets/images/akora_logo_banner-b.png', // Ensure this is the correct path
          height: 28, // Adjust the height to fit nicely in the nav bar. 30-35 is usually good.

        ),
        // The trailing '+' button remains the same.
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            context.pushNamed(AppRouter.addTherapyStartRouteName);
          },
          child: const Icon(CupertinoIcons.add),
        ),
      ),
      child: SafeArea(
        child: StreamBuilder<List<Therapy>>(
          stream: _therapiesStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CupertinoActivityIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Errore: ${snapshot.error}'));
            }

            final therapies = snapshot.data ?? [];

            if (therapies.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Text(
                    'Nessuna terapia attiva.\nTocca il pulsante + per aggiungerne una.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 18, color: CupertinoColors.secondaryLabel),
                  ),
                ),
              );
            } else {
              return ListView.builder(
                key: _listViewKey, // Use the key to force rebuilds
                padding: const EdgeInsets.all(16.0),
                itemCount: therapies.length,
                itemBuilder: (context, index) {
                  final therapy = therapies[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12.0),
                      child: Slidable(
                        key: ValueKey(therapy.id),
                        endActionPane: ActionPane(
                          motion: const BehindMotion(),
                          children: [
                            SlidableAction(
                              onPressed: (buildContext) =>
                                  _editTherapy(therapy),
                              backgroundColor: CupertinoColors.systemBlue,
                              foregroundColor: CupertinoColors.white,
                              icon: CupertinoIcons.pencil,
                              label: 'Modifica',
                            ),
                            SlidableAction(
                              onPressed: (buildContext) =>
                                  _deleteTherapy(therapy),
                              backgroundColor: CupertinoColors.destructiveRed,
                              foregroundColor: CupertinoColors.white,
                              icon: CupertinoIcons.delete,
                              label: 'Elimina',
                            ),
                          ],
                        ),
                        child: TherapyCard(therapy: therapy),
                      ),
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}
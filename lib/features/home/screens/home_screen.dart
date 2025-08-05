import 'package:akora_app/core/navigation/app_router.dart';
import 'package:akora_app/core/services/notification_service.dart';
import 'package:akora_app/data/sources/local/app_database.dart';
import 'package:akora_app/features/home/widgets/therapy_card.dart';
import 'package:akora_app/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Stream<List<Therapy>> _therapiesStream;

  @override
  void initState() {
    super.initState();
    _therapiesStream = db.watchAllActiveTherapies();
  }

  // --- UPDATED DELETE METHOD ---
  // The method now takes the full Therapy object to have all necessary info for cancellation.
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
              print('--- Deleting therapy and its notifications ---');
              
              // 1. First, cancel all notifications for this specific therapy.
              //    We need the full therapy object to know the start and end dates.
              await NotificationService().cancelTherapyNotifications(therapyToDelete);
              
              // 2. Then, delete the therapy from the database.
              await db.deleteTherapy(therapyToDelete.id);
              
              if (mounted) Navigator.pop(ctx);
            },
          ),
        ],
      ),
    );
  }

  void _editTherapy(Therapy therapy) {
    print('Editing therapy ID: ${therapy.id} from swipe action.');
    context.pushNamed(
      AppRouter.addTherapyStartRouteName,
      extra: therapy,
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Le Mie Terapie'),
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
                              // Pass the full therapy object to the delete method.
                              onPressed: (buildContext) =>
                                  _deleteTherapy(therapy),
                              backgroundColor: CupertinoColors.destructiveRed,
                              foregroundColor: CupertinoColors.white,
                              icon: CupertinoIcons.delete,
                              label: 'Elimina',
                            ),
                            SlidableAction(
                              onPressed: (buildContext) =>
                                  _editTherapy(therapy),
                              backgroundColor: CupertinoColors.systemBlue,
                              foregroundColor: CupertinoColors.white,
                              icon: CupertinoIcons.pencil,
                              label: 'Modifica',
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
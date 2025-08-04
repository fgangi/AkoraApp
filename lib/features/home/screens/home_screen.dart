import 'package:akora_app/core/navigation/app_router.dart';
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

  void _deleteTherapy(int therapyId) {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Conferma Eliminazione'),
        content: const Text('Sei sicuro di voler eliminare questa terapia? Questa azione non può essere annullata.'),
        actions: [
          CupertinoDialogAction(
            child: const Text('Annulla'),
            onPressed: () => Navigator.pop(ctx),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('Elimina'),
            onPressed: () {
              db.deleteTherapy(therapyId);
              Navigator.pop(ctx);
            },
          ),
        ],
      ),
    );
  }

  void _editTherapy(Therapy therapy) {
    print('Editing therapy ID: ${therapy.id}');
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Funzione in Sviluppo'),
        content: const Text('La modifica della terapia sarà disponibile a breve.'),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            isDefaultAction: true,
            onPressed: () => Navigator.pop(ctx),
          )
        ],
      ),
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
                    style: TextStyle(fontSize: 18, color: CupertinoColors.secondaryLabel),
                  ),
                ),
              );
            } else {
              return ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: therapies.length,
                itemBuilder: (context, index) {
                  final therapy = therapies[index];
                  // Use Padding for vertical spacing between cards.
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    // ClipRRect is the key to rounding both the card and the actions behind it.
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12.0),
                      child: Slidable(
                        key: ValueKey(therapy.id),
                        endActionPane: ActionPane(
                          motion: const BehindMotion(),
                          children: [
                            SlidableAction(
                              onPressed: (buildContext) => _deleteTherapy(therapy.id),
                              backgroundColor: CupertinoColors.destructiveRed,
                              foregroundColor: CupertinoColors.white,
                              icon: CupertinoIcons.delete,
                              label: 'Elimina',
                            ),
                            SlidableAction(
                              onPressed: (buildContext) => _editTherapy(therapy),
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
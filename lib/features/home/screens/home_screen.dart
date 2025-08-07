import 'package:akora_app/core/navigation/app_router.dart';
import 'package:akora_app/core/services/notification_service.dart';
import 'package:akora_app/data/sources/local/app_database.dart';
import 'package:akora_app/features/home/widgets/therapy_card.dart';
import 'package:akora_app/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
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

  // --- DEBUG METHOD to check currently scheduled notifications ---
  Future<void> _checkPendingNotifications() async {
    try {
      final List<PendingNotificationRequest> pendingRequests =
          await NotificationService().plugin.pendingNotificationRequests();

      String message = 'Ci sono ${pendingRequests.length} notifiche in attesa.\n\n';
      if (pendingRequests.isEmpty) {
        print("--- DEBUG: No pending notifications found. ---");
        message = "Nessuna notifica in attesa trovata.";
      } else {
        print("--- DEBUG: Found ${pendingRequests.length} pending notifications. ---");
        // Show only the first 5 to prevent a huge dialog
        for (var p in pendingRequests.take(5)) {
          final line = "ID: ${p.id}, Titolo: ${p.title}\n";
          print(line);
          message += line;
        }
        if (pendingRequests.length > 5) {
          message += "\n...e altre.";
        }
      }
      _showDebugAlert("Notifiche in Coda", message);
    } catch (e, s) {
      print("Error checking pending notifications: $e");
      print(s);
      _showDebugAlert("Errore", "Impossibile recuperare le notifiche in coda: $e");
    }
  }

  void _showDebugAlert(String title, String content) {
    if (mounted) {
      showCupertinoDialog(
        context: context,
        builder: (ctx) => CupertinoAlertDialog(
          title: Text(title),
          content: Text(content),
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
        middle: const Text('Le Mie Terapie'),
        // --- ADDED/MODIFIED DEBUG BUTTONS ---
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            // New Test Button: Schedules a simple notification in 5 seconds
            NotificationService().scheduleTestNotification();
            _showDebugAlert("Test Avviato", "Una notifica di prova è stata programmata tra 5 secondi. Chiudi l'app o vai alla home per vederla.");
          },
          child: const Icon(CupertinoIcons.bell_fill), // Bell icon for testing
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Button to check pending notifications
            CupertinoButton(
              padding: const EdgeInsets.only(left: 8.0),
              onPressed: _checkPendingNotifications,
              child: const Icon(CupertinoIcons.info_circle),
            ),
            // Your original '+' button
            CupertinoButton(
              padding: const EdgeInsets.only(left: 8.0),
              onPressed: () {
                context.pushNamed(AppRouter.addTherapyStartRouteName);
              },
              child: const Icon(CupertinoIcons.add),
            ),
          ],
        ),
      ),
      child: SafeArea(
        child: StreamBuilder<List<Therapy>>(
          stream: _therapiesStream,
          builder: (context, snapshot) {
            // ... (The rest of the StreamBuilder is exactly the same as before)
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
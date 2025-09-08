import 'package:akora_app/core/navigation/app_router.dart';
import 'package:akora_app/core/services/notification_service.dart';
import 'package:akora_app/data/sources/local/app_database.dart';
import 'package:akora_app/features/home/widgets/therapy_card.dart';
import 'package:akora_app/core/utils/responsive_helpers.dart';
import 'package:akora_app/features/home/widgets/empty_detail_scaffold.dart';
import 'package:akora_app/features/therapy_management/screens/therapy_detail_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';

class HomeScreen extends StatefulWidget {
  final AppDatabase database;
  final NotificationService notificationService;

  const HomeScreen({
    super.key,
    required this.database,
    required this.notificationService,
  });
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Stream<List<Therapy>> _therapiesStream;
  Therapy? _selectedTherapyForTablet;
  Timer? _dayChangeTimer;

  // A key that we can change to force the ListView to rebuild
  Key _listViewKey = UniqueKey(); 

  @override
  void initState() {
    super.initState();
    _therapiesStream = widget.database.watchAllActiveTherapies();
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
      // it's very likely the day has just changed.q
      if (now.hour == 0 && now.minute <= 1) {
        print("--- Midnight detected! Rebuilding HomeScreen. ---");
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
        content: const Text('Sei sicuro di voler eliminare questa terapia? Questa azione non può essere annullata.'),
        actions: [
          CupertinoDialogAction(
            child: const Text('Annulla'),
            onPressed: () => Navigator.pop(ctx),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('Elimina'),
            onPressed: () async {
              // Store the ID before the object becomes invalid
              final int deletedTherapyId = therapyToDelete.id;
              
              // Backend: Cancel notifications and delete from the database
              await widget.notificationService.cancelTherapyNotifications(therapyToDelete);
              await widget.database.deleteTherapy(deletedTherapyId);

              // Frontend: Update the UI state if needed for tablet view
              if (mounted && isTablet(context)) {
                // Check if the therapy we just deleted is the one being shown
                // in the detail panel.
                if (_selectedTherapyForTablet?.id == deletedTherapyId) {
                  setState(() {
                    // If it is, clear the selection to show the empty state.
                    _selectedTherapyForTablet = null;
                  });
                }
              }
              
              if (mounted) Navigator.pop(ctx);
            },
          ),
        ],
      ),
    );
  }

  void _editTherapy(Therapy therapy) {
    GoRouter.of(context).pushNamed(
      AppRouter.addTherapyStartRouteName,
      extra: therapy,
    );
  }

  void _onTherapyTapped(Therapy therapy) {
    if (isTablet(context)) {
      // On a tablet, we update the state to show the details on the right.
      setState(() {
        _selectedTherapyForTablet = therapy;
      });
    } else {
      // On a phone, we navigate to the detail screen as before.
      GoRouter.of(context).pushNamed(AppRouter.therapyDetailRouteName, extra: therapy);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (isTablet(context)) {
          return _buildTabletLayout();
        } else {
          return _buildPhoneLayout();
        }
      },
    );
  }

  Widget _buildPhoneLayout() {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Image.asset('assets/images/akora_logo_banner-b.png', height: 28),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            GoRouter.of(context).pushNamed(AppRouter.addTherapyStartRouteName);
          },
          child: const Icon(CupertinoIcons.add),
        ),
      ),
      child: SafeArea(
        child: _buildTherapyList(),
      ),
    );
  }
  
  Widget _buildTabletLayout() {
    return Row(
      children: [
        SizedBox(
          width: 350,
          child: CupertinoPageScaffold(
            navigationBar: CupertinoNavigationBar(
              middle: Image.asset('assets/images/akora_logo_banner-b.png', height: 28),
              trailing: CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  GoRouter.of(context).pushNamed(AppRouter.addTherapyStartRouteName);
                },
                child: const Icon(CupertinoIcons.add),
              ),
            ),
            child: SafeArea(
              child: _buildTherapyList(),
            ),
          ),
        ),
        const VerticalDivider(width: 1.0),
        Expanded(
          child: _selectedTherapyForTablet == null
              ? const EmptyDetailScaffold()
              : TherapyDetailScreen(therapy: _selectedTherapyForTablet!),
        ),
      ],
    );
  }

  // This avoids code duplication between the phone and tablet layouts.
  Widget _buildTherapyList() {
    return StreamBuilder<List<Therapy>>(
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
            key: _listViewKey,
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
                      extentRatio: 0.5, // 50% of the card width for the actions
                      children: [
                        CustomSlidableAction(
                          onPressed: (context) => _editTherapy(therapy),
                          backgroundColor: CupertinoColors.systemBlue,
                          child: const Icon(CupertinoIcons.pencil, color: CupertinoColors.white, size: 25),
                        ),
                        CustomSlidableAction(
                          onPressed: (context) => _deleteTherapy(therapy),
                          backgroundColor: CupertinoColors.destructiveRed,
                          child: const Icon(CupertinoIcons.delete, color: CupertinoColors.white, size: 25),
                        ),
                      ],
                    ),
                    child: TherapyCard(
                      therapy: therapy,
                      database: widget.database,
                      notificationService: widget.notificationService,
                      onTap: () => _onTherapyTapped(therapy),
                    ),
                  ),
                ),
              );
            },
          );
        }
      },
    );
  }
}
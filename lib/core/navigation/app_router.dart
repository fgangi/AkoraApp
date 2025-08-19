import 'package:akora_app/data/sources/local/app_database.dart';
import 'package:akora_app/features/therapy_management/models/therapy_setup_model.dart';

// Import all screens
import 'package:akora_app/features/scaffold/main_scaffold_screen.dart';
import 'package:akora_app/features/therapy_management/screens/drug_search_screen.dart';
import 'package:akora_app/features/therapy_management/screens/therapy_frequency_screen.dart';
import 'package:akora_app/features/therapy_management/screens/reminder_time_screen.dart';
import 'package:akora_app/features/therapy_management/screens/therapy_duration_screen.dart';
import 'package:akora_app/features/therapy_management/screens/dose_and_expiry_screen.dart';
import 'package:akora_app/features/therapy_management/screens/therapy_summary_screen.dart';
import 'package:akora_app/features/therapy_management/screens/therapy_detail_screen.dart';

import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:akora_app/main.dart';
import 'package:akora_app/core/services/notification_service.dart';

class AppRouter {
  // Route names for the existing, functional parts of the app.
  static const String homeRouteName = 'home';
  static const String addTherapyStartRouteName = 'addTherapyStart';
  static const String therapyFrequencyRouteName = 'therapyFrequency';
  static const String reminderTimeRouteName = 'reminderTime';
  static const String therapyDurationRouteName = 'therapyDuration';
  static const String doseAndExpiryRouteName = 'doseAndExpiry';
  static const String therapySummaryRouteName = 'therapySummary';
  static const String therapyDetailRouteName = 'therapyDetail';
  // Removed tutorialRouteName

  static final GoRouter router = GoRouter(
    initialLocation: '/${homeRouteName}',
    routes: <RouteBase>[
      // --- Main App Screen ---
      GoRoute(
        path: '/${homeRouteName}',
        name: homeRouteName,
        builder: (context, state) => MainScaffoldScreen(
          database: db, // Provide the real database instance
          notificationService: NotificationService(), // Provide a new instance of the service
        ),
      ),

      // --- The Unified "Add/Edit Therapy" flow ---
      GoRoute(
        path: '/${addTherapyStartRouteName}',
        name: addTherapyStartRouteName,
        builder: (BuildContext context, GoRouterState state) {
          final Therapy? initialTherapy = state.extra as Therapy?;
          return DrugSearchScreen(initialTherapy: initialTherapy);
        },
      ),
      GoRoute(
        path: '/${therapyFrequencyRouteName}',
        name: therapyFrequencyRouteName,
        builder: (BuildContext context, GoRouterState state) {
          final TherapySetupData data = state.extra as TherapySetupData;
          return TherapyFrequencyScreen(initialData: data);
        },
      ),
      GoRoute(
        path: '/${reminderTimeRouteName}',
        name: reminderTimeRouteName,
        builder: (BuildContext context, GoRouterState state) {
          final TherapySetupData data = state.extra as TherapySetupData;
          return ReminderTimeScreen(initialData: data);
        },
      ),
      GoRoute(
        path: '/${therapyDurationRouteName}',
        name: therapyDurationRouteName,
        builder: (BuildContext context, GoRouterState state) {
          final TherapySetupData data = state.extra as TherapySetupData;
          return TherapyDurationScreen(initialData: data);
        },
      ),
      GoRoute(
        path: '/${doseAndExpiryRouteName}',
        name: doseAndExpiryRouteName,
        builder: (BuildContext context, GoRouterState state) {
          final TherapySetupData data = state.extra as TherapySetupData;
          return DoseAndExpiryScreen(initialData: data);
        },
      ),
      GoRoute(
        path: '/${therapySummaryRouteName}',
        name: therapySummaryRouteName,
        builder: (BuildContext context, GoRouterState state) {
          // This route is the end of the setup flow, so it always receives TherapySetupData.
          final TherapySetupData data = state.extra as TherapySetupData;
          return TherapySummaryScreen(setupData: data);
        },
      ),

      // --- Therapy Detail Screen ---
      GoRoute(
        path: '/${therapyDetailRouteName}',
        name: therapyDetailRouteName,
        builder: (context, state) {
          final Therapy therapy = state.extra as Therapy;
          return TherapyDetailScreen(therapy: therapy);
        },
      ),
      
    ],
    // --- Error Handler ---
    errorBuilder: (context, state) => CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Pagina non Trovata'),
      ),
      child: Center(
        child: Text('Errore: ${state.error?.message ?? 'Route non trovata'}'),
      ),
    ),
  );
}
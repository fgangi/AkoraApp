import 'package:akora_app/data/models/drug_model.dart';
import 'package:akora_app/data/sources/local/app_database.dart';
import 'package:akora_app/features/therapy_management/models/therapy_enums.dart';
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
import 'package:flutter/material.dart'; // Required for TimeOfDay
import 'package:go_router/go_router.dart';

class AppRouter {
  // Define all route names as constants
  static const String homeRouteName = 'home';
  static const String addTherapyStartRouteName = 'addTherapyStart';
  static const String therapyFrequencyRouteName = 'therapyFrequency';
  static const String reminderTimeRouteName = 'reminderTime';
  static const String therapyDurationRouteName = 'therapyDuration';
  static const String doseAndExpiryRouteName = 'doseAndExpiry';
  static const String therapySummaryRouteName = 'therapySummary';
  static const String therapyDetailRouteName = 'therapyDetail';
  static const String tutorialRouteName = 'tutorial';

  static final GoRouter router = GoRouter(
    initialLocation: '/${homeRouteName}',
    routes: <RouteBase>[
      // --- Main App Screen ---
      GoRoute(
        path: '/${homeRouteName}',
        name: homeRouteName,
        builder: (context, state) => const MainScaffoldScreen(),
      ),

      // --- The "Add/Edit Therapy" flow ---
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
          // This route now receives the fully-formed TherapySetupData object
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
          final TherapySetupData data = state.extra as TherapySetupData;
          return TherapySummaryScreen(initialData: data);
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
      
      // --- Placeholder Tutorial Route ---
      GoRoute(
        path: '/${tutorialRouteName}',
        name: tutorialRouteName,
        builder: (context, state) => const CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(middle: Text('Tutorial')),
          child: Center(child: Text('App Tutorial Screen - Placeholder')),
        ),
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
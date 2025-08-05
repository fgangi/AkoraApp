import 'package:akora_app/data/models/drug_model.dart';
import 'package:akora_app/data/sources/local/app_database.dart';
import 'package:akora_app/features/therapy_management/models/therapy_enums.dart';

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
          final Map<String, dynamic> data = state.extra as Map<String, dynamic>;
          return TherapyFrequencyScreen(
            selectedDrug: data['selectedDrug'] as Drug?,
            initialTherapy: data['initialTherapy'] as Therapy?,
          );
        },
      ),
      GoRoute(
        path: '/${reminderTimeRouteName}',
        name: reminderTimeRouteName,
        builder: (BuildContext context, GoRouterState state) {
          final data = state.extra as Map<String, dynamic>;
          return ReminderTimeScreen(
            currentDrug: data['drug'] as Drug,
            selectedFrequency: data['frequency'] as TakingFrequency,
            initialTherapy: data['initialTherapy'] as Therapy?,
          );
        },
      ),
      GoRoute(
        path: '/${therapyDurationRouteName}',
        name: therapyDurationRouteName,
        builder: (BuildContext context, GoRouterState state) {
          final data = state.extra as Map<String, dynamic>;
          return TherapyDurationScreen(
            currentDrug: data['drug'] as Drug,
            selectedFrequency: data['frequency'] as TakingFrequency,
            selectedTime: data['time'] as TimeOfDay,
            repeatAfter10Min: data['repeat'] as bool,
            initialTherapy: data['initialTherapy'] as Therapy?,
          );
        },
      ),
      GoRoute(
        path: '/${doseAndExpiryRouteName}',
        name: doseAndExpiryRouteName,
        builder: (BuildContext context, GoRouterState state) {
          final data = state.extra as Map<String, dynamic>;
          return DoseAndExpiryScreen(
            currentDrug: data['drug'] as Drug,
            selectedFrequency: data['frequency'] as TakingFrequency,
            selectedTime: data['time'] as TimeOfDay,
            repeatAfter10Min: data['repeat'] as bool,
            startDate: data['startDate'] as DateTime,
            endDate: data['endDate'] as DateTime,
            initialTherapy: data['initialTherapy'] as Therapy?,
          );
        },
      ),
      GoRoute(
        path: '/${therapySummaryRouteName}',
        name: therapySummaryRouteName,
        builder: (BuildContext context, GoRouterState state) {
          final data = state.extra as Map<String, dynamic>;
          return TherapySummaryScreen(
            currentDrug: data['drug'] as Drug,
            selectedFrequency: data['frequency'] as TakingFrequency,
            selectedTime: data['time'] as TimeOfDay,
            repeatAfter10Min: data['repeat'] as bool,
            startDate: data['startDate'] as DateTime,
            endDate: data['endDate'] as DateTime,
            doseThreshold: data['doseThreshold'] as int,
            expiryDate: data['expiryDate'] as DateTime?,
            initialTherapy: data['initialTherapy'] as Therapy?,
          );
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
import 'package:akora_app/data/models/drug_model.dart';
import 'package:akora_app/features/onboarding/screens/welcome_screen.dart';
import 'package:akora_app/features/therapy_management/screens/dose_and_expiry_screen.dart';
import 'package:akora_app/features/therapy_management/screens/reminder_time_screen.dart';
import 'package:akora_app/features/therapy_management/screens/therapy_duration_screen.dart';
import 'package:akora_app/features/therapy_management/screens/therapy_frequency_screen.dart';
import 'package:akora_app/features/therapy_management/screens/therapy_summary_screen.dart';
import 'package:akora_app/features/therapy_management/screens/drug_search_screen.dart';

import 'package:akora_app/features/therapy_management/models/therapy_enums.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  // Define all route names as constants for type-safety and easy refactoring
  static const String welcomeRouteName = 'welcome';
  static const String drugSearchRouteName = 'drugSearch';
  static const String therapyFrequencyRouteName = 'therapyFrequency';
  static const String reminderTimeRouteName = 'reminderTime';
  static const String therapyDurationRouteName = 'therapyDuration';
  static const String doseAndExpiryRouteName = 'doseAndExpiry';
  static const String therapySummaryRouteName = 'therapySummary';
  static const String tutorialRouteName = 'tutorial';

  static final GoRouter router = GoRouter(
    initialLocation: '/${welcomeRouteName}',
    routes: <RouteBase>[
      // --- Onboarding Flow ---
      GoRoute(
        path: '/${welcomeRouteName}',
        name: welcomeRouteName,
        builder: (BuildContext context, GoRouterState state) {
          return const WelcomeScreen();
        },
      ),

      // --- Therapy Setup Flow ---
      GoRoute(
        path: '/${drugSearchRouteName}',
        name: drugSearchRouteName,
        builder: (BuildContext context, GoRouterState state) {
          return const DrugSearchScreen();
        },
      ),
      GoRoute(
        path: '/${therapyFrequencyRouteName}',
        name: therapyFrequencyRouteName,
        builder: (BuildContext context, GoRouterState state) {
          final Drug selectedDrug = state.extra as Drug;
          return TherapyFrequencyScreen(selectedDrug: selectedDrug);
        },
      ),
      GoRoute(
        path: '/${reminderTimeRouteName}',
        name: reminderTimeRouteName,
        builder: (BuildContext context, GoRouterState state) {
          final Map<String, dynamic> data = state.extra as Map<String, dynamic>;
          final Drug selectedDrug = data['drug'] as Drug;
          final TakingFrequency selectedFrequency = data['frequency'] as TakingFrequency;
          return ReminderTimeScreen(
            selectedDrug: selectedDrug,
            selectedFrequency: selectedFrequency,
          );
        },
      ),
      GoRoute(
        path: '/${therapyDurationRouteName}',
        name: therapyDurationRouteName,
        builder: (BuildContext context, GoRouterState state) {
          final Map<String, dynamic> data = state.extra as Map<String, dynamic>;
          return TherapyDurationScreen(
            selectedDrug: data['drug'] as Drug,
            selectedFrequency: data['frequency'] as TakingFrequency,
            selectedTime: data['time'] as TimeOfDay,
            repeatAfter10Min: data['repeat'] as bool,
          );
        },
      ),
      GoRoute(
        path: '/${doseAndExpiryRouteName}',
        name: doseAndExpiryRouteName,
        builder: (BuildContext context, GoRouterState state) {
          final Map<String, dynamic> data = state.extra as Map<String, dynamic>;
          return DoseAndExpiryScreen(
            selectedDrug: data['drug'] as Drug,
            selectedFrequency: data['frequency'] as TakingFrequency,
            selectedTime: data['time'] as TimeOfDay,
            repeatAfter10Min: data['repeat'] as bool,
            startDate: data['startDate'] as DateTime,
            endDate: data['endDate'] as DateTime,
          );
        },
      ),
      GoRoute(
        path: '/${therapySummaryRouteName}',
        name: therapySummaryRouteName,
        builder: (BuildContext context, GoRouterState state) {
          // 1. Safely cast the 'extra' data to a Map
          final Map<String, dynamic> data = state.extra as Map<String, dynamic>;

          // 2. Unpack all the data from the map, casting each piece to its correct type
          return TherapySummaryScreen(
            selectedDrug: data['drug'] as Drug,
            selectedFrequency: data['frequency'] as TakingFrequency,
            selectedTime: data['time'] as TimeOfDay,
            repeatAfter10Min: data['repeat'] as bool,
            startDate: data['startDate'] as DateTime,
            endDate: data['endDate'] as DateTime,
            doseThreshold: data['doseThreshold'] as int,
            expiryDate: data['expiryDate'] as DateTime?, // Handle nullable DateTime
            notificationSound: data['notificationSound'] as NotificationSound,
          );
        },
      ),
      GoRoute(
        path: '/${tutorialRouteName}',
        name: tutorialRouteName,
        builder: (BuildContext context, GoRouterState state) {
          return const CupertinoPageScaffold(
            navigationBar: CupertinoNavigationBar(middle: Text('Tutorial')),
            child: Center(child: Text('App Tutorial Screen - Placeholder')),
          );
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
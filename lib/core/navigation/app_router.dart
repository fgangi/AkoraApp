import 'package:akora_app/data/models/drug_model.dart';
import 'package:akora_app/features/therapy_management/models/therapy_enums.dart';

import 'package:akora_app/features/scaffold/main_scaffold_screen.dart'; 

import 'package:akora_app/features/therapy_management/screens/drug_search_screen.dart';
import 'package:akora_app/features/therapy_management/screens/dose_and_expiry_screen.dart';
import 'package:akora_app/features/therapy_management/screens/reminder_time_screen.dart';
import 'package:akora_app/features/therapy_management/screens/therapy_duration_screen.dart';
import 'package:akora_app/features/therapy_management/screens/therapy_frequency_screen.dart';
import 'package:akora_app/features/therapy_management/screens/therapy_summary_screen.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  // Define all route names as constants
  static const String homeRouteName = 'home';
  static const String addTherapyStartRouteName = 'addTherapyStart'; // Renamed from 'welcome'
  static const String therapyFrequencyRouteName = 'therapyFrequency';
  static const String reminderTimeRouteName = 'reminderTime';
  static const String therapyDurationRouteName = 'therapyDuration';
  static const String doseAndExpiryRouteName = 'doseAndExpiry';
  static const String therapySummaryRouteName = 'therapySummary';
  static const String tutorialRouteName = 'tutorial'; // Kept for future use

  static final GoRouter router = GoRouter(
    // The app will now start at '/home', which shows the MainScaffoldScreen
    initialLocation: '/${homeRouteName}', 
    routes: <RouteBase>[
      // --- Main App Screen with Bottom Nav Bar ---
      GoRoute(
        path: '/${homeRouteName}',
        name: homeRouteName,
        builder: (context, state) {
          // This is the new main entry point for the app's UI
          return const MainScaffoldScreen();
        },
      ),

      // --- The "Add Therapy" flow, now triggered by the '+' button ---
      GoRoute(
        // We can't use 'drugSearch' as the path segment because we are renaming the route
        // and its purpose. It's the START of the flow.
        path: '/${addTherapyStartRouteName}',
        name: addTherapyStartRouteName,
        builder: (BuildContext context, GoRouterState state) {
          // The flow begins directly with the drug search screen.
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
          return ReminderTimeScreen(
            selectedDrug: data['drug'] as Drug,
            selectedFrequency: data['frequency'] as TakingFrequency,
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
          final Map<String, dynamic> data = state.extra as Map<String, dynamic>;
          return TherapySummaryScreen(
            selectedDrug: data['drug'] as Drug,
            selectedFrequency: data['frequency'] as TakingFrequency,
            selectedTime: data['time'] as TimeOfDay,
            repeatAfter10Min: data['repeat'] as bool,
            startDate: data['startDate'] as DateTime,
            endDate: data['endDate'] as DateTime,
            doseThreshold: data['doseThreshold'] as int,
            expiryDate: data['expiryDate'] as DateTime?,
            notificationSound: data['notificationSound'] as NotificationSound,
          );
        },
      ),

      // --- Other App Features (like tutorial) ---
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
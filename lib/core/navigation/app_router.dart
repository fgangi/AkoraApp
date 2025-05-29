import 'package:akora_app/data/models/drug_model.dart'; // Import Drug model
import 'package:akora_app/features/onboarding/screens/welcome_screen.dart';
import 'package:akora_app/features/therapy_management/screens/drug_search_screen.dart';
// Import the new screen
import 'package:akora_app/features/therapy_management/screens/therapy_frequency_screen.dart';
// import 'package:akora_app/features/tutorial/screens/tutorial_start_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  static const String welcomeRouteName = 'welcome';
  static const String drugSearchRouteName = 'drugSearch';
  static const String therapyFrequencyRouteName = 'therapyFrequency'; // New route name
  static const String tutorialRouteName = 'tutorial';

  static final GoRouter router = GoRouter(
    initialLocation: '/${welcomeRouteName}',
    routes: <RouteBase>[
      GoRoute(
        path: '/${welcomeRouteName}',
        name: welcomeRouteName,
        builder: (BuildContext context, GoRouterState state) {
          return const WelcomeScreen();
        },
      ),
      GoRoute(
        path: '/${drugSearchRouteName}',
        name: drugSearchRouteName,
        builder: (BuildContext context, GoRouterState state) {
          return const DrugSearchScreen();
        },
      ),
      GoRoute(
        path: '/${therapyFrequencyRouteName}', // Path for frequency screen
        name: therapyFrequencyRouteName,     // Name for frequency screen
        builder: (BuildContext context, GoRouterState state) {
          // Extract the Drug object passed as 'extra'
          final Drug selectedDrug = state.extra as Drug;
          return TherapyFrequencyScreen(selectedDrug: selectedDrug);
        },
      ),
      GoRoute(
        path: '/${tutorialRouteName}',
        name: tutorialRouteName,
        builder: (BuildContext context, GoRouterState state) {
          // ... (tutorial placeholder) ...
          return const CupertinoPageScaffold(
            navigationBar: CupertinoNavigationBar(middle: Text('Tutorial')),
            child: Center(child: Text('App Tutorial Screen - Placeholder')),
          );
        },
      ),
    ],
    errorBuilder: (context, state) => CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Error'),
      ),
      child: Center(
        child: Text('Page not found: ${state.error?.message}'),
      ),
    ),
  );
}
// lib/app.dart
import 'package:akora_app/core/navigation/app_router.dart';
import 'package:akora_app/presentation/theme.dart';
import 'package:flutter/cupertino.dart';

// Import the localization library to get the delegates
import 'package:flutter_localizations/flutter_localizations.dart';

class AkoraApp extends StatelessWidget {
  const AkoraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoApp.router(
      title: 'Akòra', // App title for OS task switcher
      debugShowCheckedModeBanner: false,
      theme: AppTheme.cupertinoTheme,
      routerConfig: AppRouter.router,

      // --- ADD THIS ENTIRE SECTION ---
      // These delegates are required by some Flutter widgets (like date/time pickers
      // and formatters) to access localized strings and formatting rules,
      // even if your app's own text is hardcoded.
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      // We need to declare which locales are supported by these delegates.
      // Since your app is in Italian, we specify Italian.
      supportedLocales: const [
        Locale('it', 'IT'), // Use 'it' for Italian, 'IT' is the optional country code.
      ],
      // We can explicitly set the app's locale to Italian to ensure
      // all date/time formatting defaults to Italian conventions.
      locale: const Locale('it', 'IT'),
    );
  }
}
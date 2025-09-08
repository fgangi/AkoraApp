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
      title: 'Akòra',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.cupertinoTheme,
      routerConfig: AppRouter.router,

      // Add localization delegates and supported locales
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('it', 'IT'),
      ],
      locale: const Locale('it', 'IT'),
    );
  }
}
// lib/app.dart
import 'package:akora_app/core/navigation/app_router.dart';
import 'package:akora_app/presentation/theme.dart';
import 'package:flutter/cupertino.dart';

class AkoraApp extends StatelessWidget {
  const AkoraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoApp.router(
      title: 'Akòra', // App title for OS task switcher
      debugShowCheckedModeBanner: false,
      theme: AppTheme.cupertinoTheme,
      routerConfig: AppRouter.router,
      // No localization-specific properties needed
    );
  }
}
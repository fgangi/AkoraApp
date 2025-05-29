import 'package:akora_app/app.dart';
import 'package:flutter/material.dart'; // Still needed for WidgetsFlutterBinding
// import 'package:flutter_bloc/flutter_bloc.dart'; // For BLoC observer later
// import 'package:akora_app/core/services/notification_service.dart'; // For notifications later
// import 'package:akora_app/data/sources/local/app_database.dart'; // For database later

void main() async {
  // Ensures that plugin services are initialized before runApp()
  WidgetsFlutterBinding.ensureInitialized();

  // --- Initialize Services (uncomment and implement as you build them) ---
  // Example: Initialize Notifications
  // if (NotificationService.instance != null) { // Check if you made it a singleton
  //   await NotificationService.instance!.init();
  // }


  // Example: Initialize Database (if using a global instance, otherwise provide via DI/Bloc)
  // final AppDatabase database = AppDatabase();

  // --- BLoC Observer (optional, for debugging state changes if using BLoC) ---
  // if (Bloc.observer is AppBlocObserver) { // Example, if you create AppBlocObserver
  //   Bloc.observer = AppBlocObserver();
  // }

  runApp(
    // If using Drift/sqflite and BLoC, you'll likely set up RepositoryProviders here
    // that take the database instance. For now, keep it simple.
    const AkoraApp(),
  );
}
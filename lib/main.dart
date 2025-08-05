// lib/main.dart
import 'package:akora_app/app.dart';
import 'package:akora_app/data/sources/local/app_database.dart';
import 'package:akora_app/core/services/notification_service.dart';
import 'package:flutter/cupertino.dart';

// Create a global instance of the database.
late AppDatabase db;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the notification service.
  await NotificationService().init();

  // Initialize the database instance.
  db = AppDatabase();

  runApp(const AkoraApp());
}
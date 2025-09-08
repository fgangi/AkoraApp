// coverage:ignore-file
// lib/main.dart
import 'package:akora_app/app.dart';
import 'package:akora_app/data/sources/local/app_database.dart';
import 'package:akora_app/core/services/notification_service.dart';
import 'package:akora_app/core/services/ai_api_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/cupertino.dart';

// Create a global instance of the database.
late AppDatabase db;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  // Initialize the notification service.
  AiApiService.init();
  await NotificationService().init();

  // Initialize the database instance.
  db = AppDatabase();

  runApp(const AkoraApp());
}
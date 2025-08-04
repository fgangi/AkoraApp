// lib/main.dart
import 'package:akora_app/app.dart';
import 'package:akora_app/data/sources/local/app_database.dart';
import 'package:flutter/cupertino.dart';

// Create a global instance of the database.
late AppDatabase db;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize the database instance.
  db = AppDatabase();

  runApp(const AkoraApp());
}
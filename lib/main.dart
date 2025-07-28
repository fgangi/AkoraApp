// lib/main.dart
import 'package:akora_app/app.dart';
import 'package:flutter/cupertino.dart'; // Use Cupertino or Material
import 'package:flutter/material.dart';

// 1. Import Firebase Core
import 'package:firebase_core/firebase_core.dart';
// 2. Import the generated firebase_options.dart file
import 'firebase_options.dart';

void main() async {
  // 3. Ensure that the Flutter binding is initialized before calling Firebase.initializeApp
  WidgetsFlutterBinding.ensureInitialized();

  // 4. Initialize Firebase using the generated options for the current platform
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // You can remove any old local DB initialization code that might have been here.
  // For example:
  // late AppDatabase db;
  // db = AppDatabase();

  // 5. Run your app
  runApp(const AkoraApp());
}
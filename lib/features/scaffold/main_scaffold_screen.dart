// lib/features/scaffold/main_scaffold_screen.dart
import 'package:akora_app/core/services/notification_service.dart';
import 'package:akora_app/main.dart';
import 'package:akora_app/features/chat/screens/ai_doctor_screen.dart';
import 'package:akora_app/features/home/screens/home_screen.dart';
import 'package:akora_app/features/maps/screens/pharmacy_maps_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:akora_app/data/sources/local/app_database.dart';
import 'package:akora_app/core/services/notification_service.dart';

class MainScaffoldScreen extends StatelessWidget {
  final AppDatabase database;
  final NotificationService notificationService;
  
  const MainScaffoldScreen({
    super.key,
    required this.database,
    required this.notificationService,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      // Add a controller just to set the initial tab index.
      controller: CupertinoTabController(initialIndex: 1),
      tabBuilder: (BuildContext context, int index) {
        final List<Widget> pages = [
          const AiDoctorScreen(),
          // changed for the testing to provide the real database and a new instance of the notification service
          HomeScreen(database: database, notificationService: notificationService),
          const PharmacyMapsScreen(),
        ];
        return CupertinoTabView(
          builder: (BuildContext context) {
            return pages[index];
          },
        );
      },
      tabBar: CupertinoTabBar(
        activeColor: CupertinoTheme.of(context).primaryColor,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.chat_bubble_2),
            label: 'Dottore AI',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.map),
            label: 'Trova Farmacie',
          ),
        ],
      ),
    );
  }
}
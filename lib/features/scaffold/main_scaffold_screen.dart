// lib/features/scaffold/main_scaffold_screen.dart
import 'package:akora_app/features/chat/screens/ai_doctor_screen.dart';
import 'package:akora_app/features/home/screens/home_screen.dart';
import 'package:akora_app/features/maps/screens/pharmacy_maps_screen.dart';
import 'package:flutter/cupertino.dart';

class MainScaffoldScreen extends StatelessWidget {
  const MainScaffoldScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      // Add a controller just to set the initial tab index.
      controller: CupertinoTabController(initialIndex: 1),
      tabBuilder: (BuildContext context, int index) {
        // Here we define the pages for our tabs.
        // Since HomeScreen is now a StatefulWidget, it cannot be a const.
        final List<Widget> pages = [
          const AiDoctorScreen(),
          HomeScreen(),
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
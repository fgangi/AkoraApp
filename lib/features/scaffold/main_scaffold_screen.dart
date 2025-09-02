import 'package:akora_app/features/chat/screens/ai_doctor_screen.dart';
import 'package:akora_app/features/home/screens/home_screen.dart';
import 'package:akora_app/features/maps/screens/pharmacy_maps_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:akora_app/data/sources/local/app_database.dart';
import 'package:akora_app/core/services/notification_service.dart';

class MainScaffoldScreen extends StatefulWidget {
  final AppDatabase database;
  final NotificationService notificationService;
  
  const MainScaffoldScreen({
    super.key,
    required this.database,
    required this.notificationService,
  });

  @override
  State<MainScaffoldScreen> createState() => _MainScaffoldScreenState();
}

class _MainScaffoldScreenState extends State<MainScaffoldScreen> {
  int _currentIndex = 1; // Start on the Home tab

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const AiDoctorScreen(),
      HomeScreen(database: widget.database, notificationService: widget.notificationService),
      const PharmacyMapsScreen(),
    ];

    return CupertinoTabScaffold(
      // The tabBar's job is just to update the index.
      tabBar: CupertinoTabBar(
        currentIndex: _currentIndex,
        onTap: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        activeColor: CupertinoTheme.of(context).primaryColor,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.chat_bubble_2), label: 'Dottore AI'),
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.map), label: 'Farmacie'),
        ],
      ),
      // The tabBuilder now builds a Stack to control the animation.
      tabBuilder: (BuildContext context, int index) {
        return CupertinoTabView(
          builder: (BuildContext context) {
            // Use a Stack to layer all pages on top of each other.
            // This keeps their state alive.
            return Stack(
              children: List.generate(pages.length, (pageIndex) {
                // Wrap each page in an AnimatedOpacity and IgnorePointer.
                return AnimatedOpacity(
                  // Animate the opacity over your desired duration.
                  duration: const Duration(milliseconds: 200),
                  // The opacity is 1.0 if the page's index matches the current tab index,
                  // otherwise it's 0.0 (invisible).
                  opacity: _currentIndex == pageIndex ? 1.0 : 0.0,
                  child: IgnorePointer(
                    // When a page is invisible, we also want to ignore any taps on it.
                    ignoring: _currentIndex != pageIndex,
                    child: pages[pageIndex],
                  ),
                );
              }),
            );
          },
        );
      },
    );
  }
}
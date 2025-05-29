// lib/features/onboarding/screens/welcome_screen.dart
import 'package:akora_app/core/navigation/app_router.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final CupertinoThemeData cupertinoTheme = CupertinoTheme.of(context);

    return CupertinoPageScaffold(
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Align( // Language selection button can be removed or repurposed
                  alignment: Alignment.topRight,
                  child: CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          CupertinoIcons.question, // Or another relevant icon
                          color: cupertinoTheme.primaryColor,
                          size: 14,
                        ),
                        const SizedBox(width: 6),
                        Text( // Hardcoded string
                          'Info',
                          style: TextStyle(
                            color: cupertinoTheme.primaryColor,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    onPressed: () {
                      // Button is now unused for language change
                      print('Settings or info button tapped?');
                    },
                  ),
                ),
                const Spacer(flex: 1),
                const Text( // Hardcoded string
                  'BENVENUTO\nSU AKÒRA',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                const Text( // Hardcoded string
                  'Il tuo supporto terapeutico quotidiano',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 17,
                  ),
                ),
                const SizedBox(height: 40),
                CupertinoButton.filled(
                  onPressed: () {
                    context.pushNamed(AppRouter.drugSearchRouteName);
                  },
                  child: const Text('Inserisci il farmaco'), // Hardcoded string
                ),
                const SizedBox(height: 15),
                CupertinoButton(
                  onPressed: () {
                    context.pushNamed(AppRouter.tutorialRouteName);
                  },
                  child: const Text('Tutorial App'), // Hardcoded string
                ),
                const Spacer(flex: 2),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
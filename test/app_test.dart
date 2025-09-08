import 'package:akora_app/app.dart';
import 'package:akora_app/data/sources/local/app_database.dart';
import 'package:akora_app/features/home/screens/home_screen.dart';
import 'package:akora_app/features/scaffold/main_scaffold_screen.dart';
import 'package:akora_app/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'home_screen_test.mocks.dart';

void main() {
  late MockAppDatabase mockDb;

  setUp(() {
    mockDb = MockAppDatabase();
    db = mockDb;
    // We can assign a dummy NotificationService to the global instance if needed,
    // but since we are injecting it via the constructor now, this is better.
  });

  group('AkoraApp Widget Tests', () {
    // A helper function to build the app with mocked dependencies
    Future<void> pumpAkoraApp(WidgetTester tester) async {
      // Stub the database call that HomeScreen will make
      when(mockDb.watchAllActiveTherapies()).thenAnswer((_) => Stream.value(<Therapy>[]));
      
      // We need to build AkoraApp because it provides the CupertinoApp shell
      await tester.pumpWidget(const AkoraApp());
      // pumpAndSettle waits for all animations (like the fade) to complete
      await tester.pumpAndSettle(); 
    }

    testWidgets('builds correctly and contains a CupertinoApp', (WidgetTester tester) async {
      await pumpAkoraApp(tester);
      expect(find.byType(CupertinoApp), findsOneWidget);
    });

    testWidgets('CupertinoApp has correct title and disabled debug banner', (tester) async {
      await pumpAkoraApp(tester);
      final cupertinoApp = tester.widget<CupertinoApp>(find.byType(CupertinoApp));
      expect(cupertinoApp.title, 'Akòra');
      expect(cupertinoApp.debugShowCheckedModeBanner, false);
    });

    testWidgets('CupertinoApp has correct localization delegates and locale set', (tester) async {
      await pumpAkoraApp(tester);
      final cupertinoApp = tester.widget<CupertinoApp>(find.byType(CupertinoApp));

      // Check the explicit locale
      expect(cupertinoApp.locale, const Locale('it', 'IT'));

      // Check that the list of supported locales contains Italian
      expect(cupertinoApp.supportedLocales, contains(const Locale('it', 'IT')));
      
      // Verify that all necessary delegates are present
      final delegates = cupertinoApp.localizationsDelegates!.toList();
      expect(delegates, hasLength(3)); // Or 4 if you add your own S.delegate back
      expect(delegates, contains(isA<LocalizationsDelegate<WidgetsLocalizations>>()));
      expect(delegates, contains(isA<LocalizationsDelegate<MaterialLocalizations>>()));
      expect(delegates, contains(isA<LocalizationsDelegate<CupertinoLocalizations>>()));
    });

    testWidgets('initial route is the MainScaffoldScreen', (tester) async {
      await pumpAkoraApp(tester);
      
      // After building the app, we expect the MainScaffoldScreen to be on screen,
      // as it's our initial route ('/home').
      expect(find.byType(MainScaffoldScreen), findsOneWidget);
      
      // We can also check for a widget inside MainScaffoldScreen to be more specific.
      // Since it starts on the home tab, the HomeScreen should be there.
      expect(find.byType(HomeScreen), findsOneWidget);
    });
  });
}
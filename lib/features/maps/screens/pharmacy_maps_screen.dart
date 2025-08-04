import 'package:flutter/cupertino.dart';

class PharmacyMapsScreen extends StatelessWidget {
  const PharmacyMapsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // This will host the map view
    return const CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Farmacie Vicine'),
      ),
      child: Center(
        child: Text('Pharmacy Maps Screen'),
      ),
    );
  }
}
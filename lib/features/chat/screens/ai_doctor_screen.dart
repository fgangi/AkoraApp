import 'package:flutter/cupertino.dart';

class AiDoctorScreen extends StatelessWidget {
  const AiDoctorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // This will host the chat interface
    return const CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Dottore AI'),
      ),
      child: Center(
        child: Text('AI Doctor Chat Screen'),
      ),
    );
  }
}
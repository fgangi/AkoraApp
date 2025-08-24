import 'package:flutter/cupertino.dart';

class EmptyDetailScaffold extends StatelessWidget {
  const EmptyDetailScaffold({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.doc_text_search,
              size: 80,
              color: CupertinoColors.systemGrey3,
            ),
            const SizedBox(height: 16),
            const Text(
              'Seleziona una terapia',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: CupertinoColors.systemGrey,
              ),
            ),
            const Text(
              'Scegli una terapia dalla lista a sinistra per vederne i dettagli.',
              style: TextStyle(
                fontSize: 16,
                color: CupertinoColors.systemGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
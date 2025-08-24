import 'package:akora_app/core/navigation/app_router.dart';
import 'package:akora_app/data/sources/local/app_database.dart';
import 'package:akora_app/features/therapy_management/models/therapy_enums.dart';
import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class TherapyDetailScreen extends StatelessWidget {
  final Therapy therapy;

  const TherapyDetailScreen({super.key, required this.therapy});

    String _formatFrequency(BuildContext context) {
    // Join all reminder times with a comma and space for readability.
    final String timesString = therapy.reminderTimes.join(', ');
    
    // Safety check: if for some reason the reminder times are empty, show a fallback message.
    if (therapy.reminderTimes.isEmpty) {
      return 'Nessun orario impostato';
    }

    // Use a switch statement on the frequency to return the appropriate descriptive text.
    switch (therapy.takingFrequency) {
      case TakingFrequency.onceDaily:
        return 'Ogni giorno alle $timesString';
        
      case TakingFrequency.twiceDaily:
        return 'Due volte al giorno ($timesString)';
        
      case TakingFrequency.onceWeekly:
        return 'Una volta a settimana alle $timesString';
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      // We are providing a unique Hero tag to the navigation bar of the detail screen.
      // This prevents it from conflicting with the navigation bar in the master list on tablets.
      navigationBar: CupertinoNavigationBar(
        // By giving the Hero a unique tag based on the therapy ID, we ensure it's unique.
        // We also need a HeroControllerScope wrapper.
        // Let's try a simpler fix first. Disable the transition.
        transitionBetweenRoutes: false, // This is the simplest way to disable the hero animation
        middle: Text(therapy.drugName),
        previousPageTitle: 'Terapie',
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            context.pushNamed(
              AppRouter.addTherapyStartRouteName,
              extra: therapy,
            );
          },
          child: const Text('Modifica'),
        ),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20.0),
          children: <Widget>[
            _buildDetailRow(
              icon: FontAwesomeIcons.pills,
              label: 'Farmaco',
              value: '${therapy.drugName} ${therapy.drugDosage}',
            ),
            _buildDetailRow(
              icon: CupertinoIcons.time,
              label: 'Frequenza e Orario',
              value: _formatFrequency(context),
            ),
            _buildDetailRow(
              icon: CupertinoIcons.calendar,
              label: 'Durata Terapia',
              value: 'Dal ${DateFormat('dd/MM/yyyy').format(therapy.startDate)} al ${DateFormat('dd/MM/yyyy').format(therapy.endDate)}',
            ),
            _buildDetailRow(
              icon: FontAwesomeIcons.prescriptionBottle,
              label: 'Promemoria Scorte',
              value: 'Avviso a ${therapy.doseThreshold} dosi rimanenti',
            ),
            if (therapy.expiryDate != null)
              _buildDetailRow(
                icon: CupertinoIcons.exclamationmark_triangle,
                label: 'Data di Scadenza',
                value: DateFormat('dd/MM/yyyy').format(therapy.expiryDate!),
              ),
          ],
        ),
      ),
    );
  }

  // Helper widget for displaying each detail row
  Widget _buildDetailRow({required IconData icon, required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 35, // Adjust this width as needed
            child: Center(
              child: FaIcon(icon, color: CupertinoColors.secondaryLabel, size: 22),
            ),
          ),
          const SizedBox(width: 16), // Adjust spacing if needed
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 15,
                    color: CupertinoColors.secondaryLabel,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
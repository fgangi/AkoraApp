import 'package:akora_app/core/navigation/app_router.dart';
import 'package:akora_app/data/sources/local/app_database.dart';
import 'package:akora_app/features/therapy_management/models/therapy_enums.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show TimeOfDay;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class TherapyDetailScreen extends StatelessWidget {
  final Therapy therapy;

  const TherapyDetailScreen({super.key, required this.therapy});

  String _formatFrequency(BuildContext context) {
    final time = TimeOfDay(hour: therapy.reminderHour, minute: therapy.reminderMinute);
    // Use a try-catch for enums that might have been added/removed in development
    try {
      switch (therapy.takingFrequency) {
        case TakingFrequency.onceDaily:
          return 'Ogni giorno alle ${time.format(context)}';
        case TakingFrequency.twiceDaily:
          return 'Due volte al giorno';
        case TakingFrequency.onceWeekly:
          return 'Una volta a settimana';
        case TakingFrequency.other:
          return 'Frequenza personalizzata';
      }
    } catch (e) {
      return 'Frequenza non definita';
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(therapy.drugName),
        previousPageTitle: 'Terapie',

        // --- UPDATED EDIT BUTTON ---
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            // Navigate to the beginning of the setup flow in "Edit Mode".
            // We pass the full therapy object. The receiving screen (DrugSearchScreen)
            // will know to pre-fill its data because this object is not null.
            context.pushNamed(
              AppRouter.addTherapyStartRouteName,
              extra: therapy, // Pass the therapy object directly
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
            _buildDetailRow(
              icon: CupertinoIcons.repeat,
              label: 'Opzioni Notifica',
              value: therapy.repeatAfter10Min ? 'Ripeti dopo 10 min' : 'Nessuna opzione extra',
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
          FaIcon(icon, color: CupertinoColors.secondaryLabel, size: 22),
          const SizedBox(width: 20),
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
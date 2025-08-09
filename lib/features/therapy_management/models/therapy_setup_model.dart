import 'package:akora_app/data/models/drug_model.dart';
import 'package:akora_app/data/sources/local/app_database.dart';
import 'package:akora_app/features/therapy_management/models/therapy_enums.dart';
import 'package:flutter/material.dart' show TimeOfDay;

// A simple class to hold all the data during the setup/edit flow.
class TherapySetupData {
  Drug currentDrug;
  TakingFrequency selectedFrequency;
  TimeOfDay selectedTime;
  bool repeatAfter10Min;
  DateTime startDate;
  DateTime endDate;
  int doseThreshold;
  int? initialDoses;
  DateTime? expiryDate;
  // This will be non-null only in edit mode, used to identify the record to update.
  Therapy? initialTherapy;
  bool isEditing;

  TherapySetupData({
    required this.currentDrug,
    required this.selectedFrequency,
    required this.selectedTime,
    required this.repeatAfter10Min,
    required this.startDate,
    required this.endDate,
    required this.doseThreshold,
    this.initialDoses,
    this.expiryDate,
    this.initialTherapy,
    this.isEditing = false,
  });

  // A factory constructor to create an instance from an existing Therapy object
  factory TherapySetupData.fromTherapy(Therapy therapy) {
    return TherapySetupData(
      currentDrug: Drug(
        id: 'therapy_${therapy.id}',
        name: therapy.drugName,
        dosage: therapy.drugDosage,
        // Placeholders for fields not in the Therapy object
        activeIngredient: '',
        quantityDescription: '',
        form: DrugForm.other,
      ),
      selectedFrequency: therapy.takingFrequency,
      selectedTime: TimeOfDay(hour: therapy.reminderHour, minute: therapy.reminderMinute),
      repeatAfter10Min: therapy.repeatAfter10Min,
      startDate: therapy.startDate,
      endDate: therapy.endDate,
      doseThreshold: therapy.doseThreshold,
      initialDoses: therapy.dosesRemaining,
      expiryDate: therapy.expiryDate,
      initialTherapy: therapy,
      isEditing: true,
    );
  }
}
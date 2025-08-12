// lib/features/therapy_management/models/therapy_setup_model.dart
import 'package:akora_app/data/models/drug_model.dart';
import 'package:akora_app/data/sources/local/app_database.dart';
import 'package:akora_app/features/therapy_management/models/therapy_enums.dart';
// TimeOfDay is no longer needed here, but we'll leave the import for now
// as other screens might still be using it temporarily during the refactor.
import 'package:flutter/material.dart' show TimeOfDay;

class TherapySetupData {
  Drug currentDrug;
  TakingFrequency selectedFrequency;
  
  List<String> reminderTimes; // e.g., ["08:30", "20:00"]
  
  bool repeatAfter10Min;
  DateTime startDate;
  DateTime endDate;
  int doseThreshold;
  int? initialDoses;
  DateTime? expiryDate;
  Therapy? initialTherapy;
  bool isSingleEditMode;
  String doseAmount;

  TherapySetupData({
    required this.currentDrug,
    required this.selectedFrequency,
    required this.reminderTimes,
    required this.repeatAfter10Min,
    required this.startDate,
    required this.endDate,
    required this.doseThreshold,
    this.initialDoses,
    this.expiryDate,
    this.initialTherapy,
    required this.doseAmount,
    this.isSingleEditMode = false,
  });

  // A factory constructor to create an instance from an existing Therapy object
  factory TherapySetupData.fromTherapy(Therapy therapy) {
    return TherapySetupData(
      currentDrug: Drug(
        id: 'therapy_${therapy.id}',
        name: therapy.drugName,
        dosage: therapy.drugDosage,
        activeIngredient: '',
        quantityDescription: '',
        form: DrugForm.other,
      ),
      selectedFrequency: therapy.takingFrequency,
      reminderTimes: therapy.reminderTimes,
      repeatAfter10Min: therapy.repeatAfter10Min,
      startDate: therapy.startDate,
      endDate: therapy.endDate,
      doseThreshold: therapy.doseThreshold,
      initialDoses: therapy.dosesRemaining,
      expiryDate: therapy.expiryDate,
      initialTherapy: therapy,
      isSingleEditMode: false,
      doseAmount: therapy.doseAmount,
    );
  }
}
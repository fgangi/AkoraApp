// lib/data/models/drug_model.dart
import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

enum DrugForm { tablet, drops, capsule, syrup, injection, other }

class Drug {
  final String id; // Unique identifier for the drug
  final String name; // Commercial name
  final String activeIngredient; // e.g., "Alprazolam"
  final String dosage; // e.g., "0,50mg", "0,75mg/ml"
  final String quantityDescription; // e.g., "20 compresse"
  final DrugForm form;
  final IconData icon;

  Drug({
    required this.id,
    required this.name,
    required this.activeIngredient,
    required this.dosage,
    required this.quantityDescription,
    required this.form,
    this.icon = FontAwesomeIcons.pills,
  });

  // A helper to display the full description in search results
  String get fullDescription => '$name $dosage $quantityDescription';
  String get subtitle => '($activeIngredient)';
}
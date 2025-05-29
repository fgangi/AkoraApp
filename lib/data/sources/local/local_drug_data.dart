// lib/data/sources/local/local_drug_data.dart
import 'package:akora_app/data/models/drug_model.dart';
// Import FontAwesome
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

final List<Drug> sampleItalianDrugs = [
  Drug(
    id: 'seryfil_0.5mg_20cpr',
    name: 'Seryfil',
    activeIngredient: 'Alprazolam',
    dosage: '0,50mg',
    quantityDescription: '20 compresse',
    form: DrugForm.tablet,
    icon: FontAwesomeIcons.pills, // Tablet/Pill icon
  ),
  Drug(
    id: 'seryfil_0.75mgml_20ml',
    name: 'Seryfil',
    activeIngredient: 'Alprazolam',
    dosage: '0,75mg/ml',
    quantityDescription: '20ml gocce',
    form: DrugForm.drops,
    icon: FontAwesomeIcons.eyeDropper, // Or .prescriptionBottle for general liquid
  ),
  Drug(
    id: 'seryfil_1mg_20cpr',
    name: 'Seryfil',
    activeIngredient: 'Alprazolam',
    dosage: '1mg',
    quantityDescription: '20 compresse',
    form: DrugForm.tablet,
    icon: FontAwesomeIcons.pills,
  ),
  Drug(
    id: 'tachipirina_500mg_20cpr',
    name: 'Tachipirina',
    activeIngredient: 'Paracetamolo',
    dosage: '500mg',
    quantityDescription: '20 compresse',
    form: DrugForm.tablet,
    icon: FontAwesomeIcons.pills,
  ),
  Drug(
    id: 'tachipirina_1000mg_16cpr',
    name: 'Tachipirina',
    activeIngredient: 'Paracetamolo',
    dosage: '1000mg',
    quantityDescription: '16 compresse',
    form: DrugForm.tablet,
    icon: FontAwesomeIcons.pills,
  ),
  Drug(
    id: 'moment_200mg_12cpr',
    name: 'Moment',
    activeIngredient: 'Ibuprofene',
    dosage: '200mg',
    quantityDescription: '12 compresse rivestite',
    form: DrugForm.tablet,
    icon: FontAwesomeIcons.pills,
  ),
  Drug(
    id: 'artaliv_100mg_30cps',
    name: 'Artaliv',
    activeIngredient: 'Celecoxib',
    dosage: '100mg',
    quantityDescription: '30 capsule',
    form: DrugForm.capsule,
    icon: FontAwesomeIcons.capsules, // Capsule icon
  ),
  Drug(
    id: 'brufen_400mg_30cpr',
    name: 'Brufen',
    activeIngredient: 'Ibuprofene',
    dosage: '400mg',
    quantityDescription: '30 compresse',
    form: DrugForm.tablet,
    icon: FontAwesomeIcons.pills,
  ),
  Drug(
    id: 'gaviscon_advance_20bust',
    name: 'Gaviscon Advance',
    activeIngredient: 'Sodio Alginato + Potassio Bicarbonato',
    dosage: '10ml',
    quantityDescription: '20 bustine monodose',
    form: DrugForm.syrup, // Representing liquid in sachet
    icon: FontAwesomeIcons.prescriptionBottle, // Or .kitMedical for sachets
  ),
  // You can explore more icons:
  // FontAwesomeIcons.syringe (for injections)
  // FontAwesomeIcons.tablets (alternative for pills)
  // FontAwesomeIcons.staffAesculapius (medical staff/pharmacy symbol)
];
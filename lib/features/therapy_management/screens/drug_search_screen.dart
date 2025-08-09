import 'package:akora_app/core/navigation/app_router.dart';
import 'package:akora_app/data/models/drug_model.dart';
import 'package:akora_app/data/sources/local/app_database.dart';
import 'package:akora_app/data/sources/local/local_drug_data.dart';
import 'package:akora_app/features/therapy_management/models/therapy_enums.dart';
import 'package:akora_app/features/therapy_management/models/therapy_setup_model.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; 
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DrugSearchScreen extends StatefulWidget {
  final Therapy? initialTherapy;
  const DrugSearchScreen({super.key, this.initialTherapy});

  @override
  State<DrugSearchScreen> createState() => _DrugSearchScreenState();
}

class _DrugSearchScreenState extends State<DrugSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Drug> _searchResults = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _handleEditMode();
    _searchController.addListener(_performSearch);
  }

  void _handleEditMode() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (widget.initialTherapy != null) {
        final setupData = TherapySetupData.fromTherapy(widget.initialTherapy!);
        context.pushReplacementNamed(AppRouter.therapyFrequencyRouteName, extra: setupData);
      }
    });
  }

  void _onDrugSelected(Drug selectedDrug) {
    final setupData = TherapySetupData(
      currentDrug: selectedDrug,
      selectedFrequency: TakingFrequency.onceDaily,
      selectedTime: const TimeOfDay(hour: 8, minute: 30),
      repeatAfter10Min: false,
      startDate: DateTime.now(),
      endDate: DateTime.now().add(const Duration(days: 7)),
      doseThreshold: 10,
      initialDoses: 20,
      expiryDate: DateTime(DateTime.now().year + 1, DateTime.now().month, DateTime.now().day),
      initialTherapy: null,
    );
    context.pushNamed(AppRouter.therapyFrequencyRouteName, extra: setupData);
  }

  void _performSearch() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      _isLoading = true;
    });

    Future.delayed(const Duration(milliseconds: 100), () {
      final List<Drug> results = query.isEmpty
          ? <Drug>[]
          : sampleItalianDrugs.where((drug) {
              return drug.fullDescription.toLowerCase().contains(query) ||
                  drug.activeIngredient.toLowerCase().contains(query);
            }).toList(); // cast<Drug>() is often not needed here but is safe

      if (mounted) {
        setState(() {
          _searchResults = results;
          _isLoading = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_performSearch);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.initialTherapy != null) {
      return const CupertinoPageScaffold(
        child: Center(child: CupertinoActivityIndicator()),
      );
    }

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Cerca Farmaco'),
        leading: CupertinoNavigationBarBackButton(
          onPressed: () => context.pop(),
        ),
      ),
      child: SafeArea(
        // Use a Column to separate the fixed search bar from the scrollable results.
        child: Column(
          children: [
            // --- This is the fixed top part ---
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
              child: Column(
                children: [
                  const Text('CERCA IL TUO FARMACO', /* ... */),
                  const SizedBox(height: 12),
                  const Text('Inserisci il nome del farmaco.', /* ... */),
                  const SizedBox(height: 20),
                  CupertinoSearchTextField(
                    controller: _searchController,
                    placeholder: 'Nome farmaco...',
                  ),
                ],
              ),
            ),

            // --- This is the dynamic, scrollable bottom part ---
            // The Expanded widget is crucial. It tells the child (the list or message)
            // to take up all the REMAINING vertical space.
            Expanded(
              child: () {
                if (_isLoading) {
                  return const Center(child: CupertinoActivityIndicator());
                }
                if (_searchResults.isNotEmpty) {
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      final drug = _searchResults[index];
                      // The Padding here provides spacing between items
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: _buildDrugResultItem(
                          icon: drug.icon,
                          title: drug.fullDescription,
                          subtitle: drug.subtitle,
                          onTap: () => _onDrugSelected(drug),
                        ),
                      );
                    },
                  );
                }
                if (_searchController.text.isNotEmpty) {
                  return const Center(child: Text('Nessun farmaco trovato.'));
                }
                // Default empty state
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'Inizia a digitare per cercare un farmaco.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: CupertinoColors.systemGrey),
                    ),
                  ),
                );
              }(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrugResultItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      // The Container itself is well-behaved and won't expand infinitely.
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
        // REMOVED the margin from here. Spacing is now handled by the Padding in ListView.builder.
        // margin: const EdgeInsets.only(bottom: 8.0), 
        decoration: BoxDecoration(
          color: CupertinoColors.tertiarySystemGroupedBackground.resolveFrom(context),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Row(
          children: [
            FaIcon(icon, color: CupertinoTheme.of(context).primaryColor, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 14, color: CupertinoColors.secondaryLabel),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(CupertinoIcons.chevron_forward, color: CupertinoColors.tertiaryLabel),
          ],
        ),
      ),
    );
  }
}
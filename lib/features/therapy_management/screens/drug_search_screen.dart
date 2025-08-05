// lib/features/therapy_management/screens/drug_search_screen.dart
import 'package:akora_app/data/models/drug_model.dart';
import 'package:akora_app/data/sources/local/app_database.dart';
import 'package:akora_app/data/sources/local/local_drug_data.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:akora_app/core/navigation/app_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
    _searchResults = [];
    _searchController.addListener(_performSearch);
  }

  void _handleEditMode() {
    // Use a post-frame callback to ensure the widget is built before navigating.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return; // Add a safety check
      if (widget.initialTherapy != null) {
        print('DrugSearchScreen in EDIT mode. Forwarding to frequency screen...');
        // If we are in edit mode, we don't show the search UI.
        // We immediately navigate to the next screen, passing the initialTherapy.
        context.pushReplacementNamed(
          AppRouter.therapyFrequencyRouteName,
          extra: {'initialTherapy': widget.initialTherapy}, // Pass in a map
        );
      } else {
        print('DrugSearchScreen in CREATE mode.');
      }
    });
  }

  void _performSearch() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      _isLoading = true;
    });

    Future.delayed(const Duration(milliseconds: 100), () {
      final List<Drug> results = query.isEmpty
          ? <Drug>[] // Typed empty list
          : sampleItalianDrugs.where((drug) {
              return drug.name.toLowerCase().contains(query) ||
                     drug.activeIngredient.toLowerCase().contains(query) ||
                     drug.dosage.toLowerCase().contains(query) ||
                     drug.fullDescription.toLowerCase().contains(query);
            }).toList().cast<Drug>();

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

  void _onDrugSelected(Drug selectedDrug) {
    // This method is only for CREATE mode.
    context.pushNamed(
      AppRouter.therapyFrequencyRouteName,
      extra: {'selectedDrug': selectedDrug}, // Pass in a map
    );
  }

  @override
  Widget build(BuildContext context) {
    // If we are in edit mode, we can show a loading indicator while we redirect.
    if (widget.initialTherapy != null) {
      return const CupertinoPageScaffold(
        child: Center(
          child: CupertinoActivityIndicator(),
        ),
      );
    }

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Cerca Farmaco'),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
              child: Column(
                children: [
                  const Text(
                    'CERCA IL TUO FARMACO',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Inserisci il nome del farmaco.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: CupertinoColors.secondaryLabel),
                  ),
                  const SizedBox(height: 20),
                  CupertinoSearchTextField(
                    controller: _searchController,
                    placeholder: 'Nome farmaco...',
                  ),
                ],
              ),
            ),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(child: CupertinoActivityIndicator()),
              )
            else if (_searchResults.isEmpty && _searchController.text.isNotEmpty)
              const Expanded(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('Nessun farmaco trovato.'),
                  ),
                ),
              )
            else if (_searchResults.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final drug = _searchResults[index];
                    return _buildDrugResultItem(
                      icon: drug.icon,
                      title: drug.fullDescription,
                      subtitle: drug.subtitle,
                      onTap: () => _onDrugSelected(drug),
                    );
                  },
                ),
              )
            else
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Inizia a digitare per cercare un farmaco.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: CupertinoColors.systemGrey),
                    ),
                  ),
                ),
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
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
        margin: const EdgeInsets.only(bottom: 8.0),
        decoration: BoxDecoration(
          color: CupertinoColors.tertiarySystemGroupedBackground.resolveFrom(context),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Row(
          children: [
            FaIcon(icon, color: CupertinoTheme.of(context).primaryColor, size: 28), // Use FaIcon if icons are FontAwesome
            // Icon(icon, color: CupertinoTheme.of(context).primaryColor, size: 28), // Use Icon for CupertinoIcons
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
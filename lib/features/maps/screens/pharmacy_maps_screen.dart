import 'dart:async';
import 'dart:convert';
import 'package:akora_app/features/maps/models/pharmacy_model.dart';
import 'package:akora_app/features/maps/services/maps_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart' as latlng;
import 'package:map_launcher/map_launcher.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';

class PharmacyMapsScreen extends StatefulWidget {
  final IMapsService mapsService;
  final TileProvider? tileProviderForTest;
  
  const PharmacyMapsScreen({
    super.key,
    required this.mapsService,
     this.tileProviderForTest,
  });

  @override
  State<PharmacyMapsScreen> createState() => _PharmacyMapsScreenState();
}

class _PharmacyMapsScreenState extends State<PharmacyMapsScreen> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  List<String> _suggestions = []; // To hold the autocomplete results
  Timer? _debounce; // The debouncer timer
  bool _isGeocoding = false;
  latlng.LatLng? _currentPosition;
  String _statusMessage = 'Accesso alla posizione...';
  List<Pharmacy> _pharmacies = [];
  bool _isLoadingPharmacies = false;

  @override
  void initState() {
    super.initState();
    _determinePosition();
    // Listen to changes in the search text field
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _determinePosition() async {
    if (mounted) {
      setState(() {
        _statusMessage = 'Accesso alla posizione...';
        _pharmacies = [];
      });
    }

    try {
      // We just call our service. It handles all the complex logic.
      Position position = await widget.mapsService.determinePosition();
      
      if (mounted) {
        final newPosition = latlng.LatLng(position.latitude, position.longitude);
        setState(() {
          _currentPosition = newPosition;
          _statusMessage = 'Posizione trovata! Cerco farmacie...';
        });
        _mapController.move(newPosition, 14.0);
        await _findNearbyPharmacies(newPosition);
      }
    } catch (e) {
      // The service throws a clear error message on failure, which we display.
      if (mounted) setState(() => _statusMessage = e.toString());
    }
  }

  Future<void> _findNearbyPharmacies(latlng.LatLng center) async {
    if (mounted) setState(() => _isLoadingPharmacies = true);
    
    // 1. Check connectivity via the service
    final connectivityResult = await widget.mapsService.checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none)) {
      if (mounted) {
        setState(() {
          _statusMessage = 'Nessuna connessione a internet.';
          _isLoadingPharmacies = false;
        });
      }
      return;
    }

    // 2. Find pharmacies via the service
    try {
      final foundPharmacies = await widget.mapsService.findNearbyPharmacies(center);
      if (mounted) {
        setState(() {
          _pharmacies = foundPharmacies;
          _statusMessage = 'Trovate ${foundPharmacies.length} farmacie nelle vicinanze.';
        });
      }
    } catch (e,stackTrace) {
      if (mounted) {
        print("--- ERROR caught in _findNearbyPharmacies: $e"); // Print the specific error
        print("--- STACK TRACE: $stackTrace");
        setState(() => _statusMessage = 'Errore nel caricare le farmacie.');
      }
    } finally {
      if (mounted) setState(() => _isLoadingPharmacies = false);
    }
  }

  void _onSearchChanged() {
    // If we are currently geocoding an address the user just tapped,
    // do not trigger a new autocomplete search.
    if (_isGeocoding) return;

    // If a timer is already active, cancel it
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    // Start a new timer. The API call will only happen if the user
    // stops typing for 500 milliseconds.
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (_searchController.text.length > 2) { // Only search after 2 characters
        _fetchAutocompleteSuggestions(_searchController.text);
      } else {
        setState(() {
          _suggestions = []; // Clear suggestions if text is too short
        });
      }
    });
  }

  Future<void> _fetchAutocompleteSuggestions(String query) async {
    final url = Uri.parse('https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(query)}&format=json&limit=5');
    
    try {
      final response = await http.get(url, headers: {'User-Agent': 'com.example.akoraApp'});
      if (response.statusCode == 200 && mounted) {
        final results = jsonDecode(response.body) as List;
        setState(() {
          // We just want the 'display_name' from each result
          _suggestions = results.map((r) => r['display_name'] as String).toList();
        });
      }
    } catch (e) {
      print("Error fetching autocomplete suggestions: $e");
    }
  }

  Future<void> _geocodeAndSearchAddress(String address) async {
    // Hide the keyboard
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    // Unfocus the search text field to prevent it from re-triggering listeners
    FocusScope.of(context).unfocus();

    if (address.trim().isEmpty) return;

    // Update the UI to show that we are searching for the address.
    if (mounted) {
      setState(() {
        _statusMessage = 'Cerco "$address"...';
        _isLoadingPharmacies = true;
        _suggestions = []; // Clear and hide the suggestion list
        _isGeocoding = true; // Set the flag to prevent new searches
      });
    }

    // Construct the URL for the Nominatim API.
    // Uri.encodeComponent ensures that special characters in the address are handled correctly.
    final url = Uri.parse('https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(address)}&format=json&limit=1');

    try {
      // Make the API request. It's good practice to set a custom User-Agent.
      final response = await http.get(
        url,
        headers: {'User-Agent': 'com.example.akoraApp'},
      );

      if (response.statusCode == 200) {
        final results = jsonDecode(response.body) as List;

        if (results.isNotEmpty && mounted) {
          // If we get one or more results, take the first one.
          final firstResult = results.first;
          final lat = double.parse(firstResult['lat']);
          final lon = double.parse(firstResult['lon']);
          final newCenter = latlng.LatLng(lat, lon);

          // Update the map to center on the new location.
          _mapController.move(newCenter, 14.0);
          
          // Now that the map is centered, find the pharmacies in that new area.
          await _findNearbyPharmacies(newCenter);

        } else {
          // If the results list is empty, the address was not found.
          if (mounted) setState(() => _statusMessage = 'Indirizzo non trovato.');
        }
      } else {
        // Handle non-200 status codes (e.g., server errors).
        if (mounted) setState(() => _statusMessage = 'Errore di geocoding (Server: ${response.statusCode})');
      }
    } catch (e) {
      // Handle network errors (e.g., no internet connection).
      if (mounted) setState(() => _statusMessage = 'Errore di rete.');
    } finally {
      // This block always runs, ensuring the loading spinner is turned off
      // whether the search succeeds or fails.
      if (mounted) {
        setState(() {
          _isLoadingPharmacies = false;
          _isGeocoding = false;
        });
      }
    }
  }
  
  void _showPharmacyInfo(Pharmacy pharmacy) {
    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: Text(pharmacy.name),
        content: pharmacy.address != null ? Text('\n${pharmacy.address!}') : null,
        actions: [
          CupertinoDialogAction(
            child: const Text('Chiudi'),
            onPressed: () => Navigator.pop(ctx),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            child: const Text('Indicazioni'),
            onPressed: () async {
              Navigator.pop(ctx);
              
              final availableMaps = await MapLauncher.installedMaps;

              if (availableMaps.isEmpty) {
                _showDebugAlert("Nessuna App di Mappe", "Nessuna applicazione di mappe trovata sul dispositivo.");
                return;
              }
              
              if (availableMaps.length == 1) {
                await availableMaps.first.showDirections(
                  destination: Coords(pharmacy.position.latitude, pharmacy.position.longitude),
                  destinationTitle: pharmacy.name,
                );
              } else {
                showCupertinoModalPopup(
                  context: context,
                  builder: (BuildContext context) {
                    return CupertinoActionSheet(
                      title: const Text('Apri con...'),
                      actions: <CupertinoActionSheetAction>[
                        for (var map in availableMaps)
                          CupertinoActionSheetAction(
                            onPressed: () {
                              map.showDirections(
                                destination: Coords(pharmacy.position.latitude, pharmacy.position.longitude),
                                destinationTitle: pharmacy.name,
                              );
                              Navigator.pop(context);
                            },
                            child: Text(map.mapName),
                          ),
                      ],
                      cancelButton: CupertinoActionSheetAction(
                        child: const Text('Annulla'),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    );
                  },
                );
              }
            },
          ),
        ],
      ),
    );
  }

  // You can add this helper method to your class for the "no maps" case
  void _showDebugAlert(String title, String content) {
    if (mounted) {
      showCupertinoDialog(
        context: context,
        builder: (ctx) => CupertinoAlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            CupertinoDialogAction(
              child: const Text('OK'),
              isDefaultAction: true,
              onPressed: () => Navigator.pop(ctx),
            )
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: SafeArea(
        maintainBottomViewPadding: true,
        child: Column(
          children: [
            // --- CUSTOM HEADER WITH SEARCH BAR ---
            _buildHeader(),

            // --- EXPANDED STACK FOR MAP AND OVERLAYS ---
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // 1. The Map itself
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: _currentPosition ?? const latlng.LatLng(41.9028, 12.4964),
                      initialZoom: _currentPosition == null ? 6.0 : 14.0,
                      interactionOptions: const InteractionOptions(
                        // This allows all interactions (pan, zoom) EXCEPT the two-finger rotate gesture.
                        flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                      ),
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.akoraApp',
                        tileProvider: widget.tileProviderForTest ?? NetworkTileProvider(),
                      ),
                      MarkerLayer(
                        markers: _pharmacies.map((pharmacy) {
                          return Marker(
                            width: 40.0,
                            height: 40.0,
                            point: pharmacy.position,
                            child: CupertinoButton(
                              padding: EdgeInsets.zero,
                              onPressed: () => _showPharmacyInfo(pharmacy),
                              child: const Icon(
                                CupertinoIcons.placemark_fill,
                                color: CupertinoColors.systemRed,
                                size: 35.0,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                  
                  // 2. Overlays on top of the map
                  
                  // "Search This Area" button
                  Positioned(
                    top: 10,
                    left: MediaQuery.of(context).size.width * 0.25,
                    right: MediaQuery.of(context).size.width * 0.25,
                    child: CupertinoButton(
                      color: CupertinoTheme.of(context).primaryColor.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20.0),
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      onPressed: () {
                        final mapCenter = _mapController.camera.center;
                        _findNearbyPharmacies(mapCenter);
                      },
                      child: const Text(
                        'Cerca in questa zona',
                        style: TextStyle(color: CupertinoColors.white, fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ),
                  ),

                  // Status message at the bottom
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 80,
                    child: CupertinoPopupSurface(
                      isSurfacePainted: true,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          _statusMessage,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),

                  // Re-center on user location button
                  Positioned(
                    bottom: 20,
                    right: 15,
                    child: CupertinoButton(
                      color: CupertinoTheme.of(context).primaryColor.withOpacity(0.9),
                      padding: const EdgeInsets.all(10),
                      borderRadius: BorderRadius.circular(50),
                      onPressed: _determinePosition,
                      child: const Icon(CupertinoIcons.location_fill, color: CupertinoColors.white, size: 24),
                    ),
                  ),

                  // Loading indicator in the center
                  if (_isLoadingPharmacies)
                    const Center(child: CupertinoActivityIndicator(radius: 20)),
                    
                  // This appears on top of everything else when there are suggestions.
                  if (_suggestions.isNotEmpty)
                    Positioned.fill(
                      // We don't need 'top' because it's inside the Expanded Stack,
                      // so it correctly fills the area below the header.
                      child: Container(
                        color: CupertinoColors.white.withOpacity(0.95), // Semi-transparent background
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: _suggestions.length,
                          itemBuilder: (context, index) {
                            final suggestion = _suggestions[index];
                            return CupertinoListTile(
                              title: Text(suggestion, maxLines: 2, overflow: TextOverflow.ellipsis),
                              onTap: () {
                                // We update the controller's text WITHOUT triggering the listener.
                                _searchController.removeListener(_onSearchChanged);
                                _searchController.text = suggestion;
                                _searchController.addListener(_onSearchChanged);
                                
                                // Now we call the geocode function.
                                _geocodeAndSearchAddress(suggestion);
                              },
                            );
                          },
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        color: CupertinoTheme.of(context).barBackgroundColor,
        border: Border(
          bottom: BorderSide(
            color: CupertinoColors.separator.resolveFrom(context),
            width: 0.5,
          ),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Column(
        children: [
          const Text(
            'Farmacie Vicine',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          CupertinoSearchTextField(
            controller: _searchController,
            placeholder: 'Cerca un indirizzo o una città',
            onSubmitted: (value) => _geocodeAndSearchAddress(value),
          ),
        ],
      ),
    );
  }
}
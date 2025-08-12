import 'package:latlong2/latlong.dart' as latlng;

class Pharmacy {
  final int id;
  final String name;
  final String? address;
  final latlng.LatLng position;

  Pharmacy({
    required this.id,
    required this.name,
    this.address,
    required this.position,
  });
}
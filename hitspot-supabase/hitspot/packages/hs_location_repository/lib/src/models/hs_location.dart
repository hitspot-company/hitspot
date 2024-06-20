import 'package:hs_location_repository/hs_location_repository.dart';

class HSLocation {
  final Placemark placemark;
  final double latitude, longitude;
  final String? address;

  const HSLocation({
    required this.placemark,
    required this.latitude,
    required this.longitude,
    this.address,
  });

  String? get name => placemark.name;

  @override
  String toString() {
    return """
Instance of HSLocation
Name: $name,
Address: $address,
Lat: $latitude,
Long: $longitude
""";
  }

  HSLocation copyWith({
    Placemark? placemark,
    double? latitude,
    double? longitude,
    String? address,
  }) {
    return HSLocation(
      placemark: placemark ?? this.placemark,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
    );
  }
}

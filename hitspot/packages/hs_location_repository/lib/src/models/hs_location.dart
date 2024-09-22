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

  Position get position => Position(
        latitude: latitude,
        longitude: longitude,
        timestamp: DateTime.now(),
        accuracy: 0.0,
        altitude: 0.0,
        altitudeAccuracy: 0.0,
        heading: 0.0,
        headingAccuracy: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0,
      );

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

extension HSLocationExtension on Position {
  Position copyWith(double lat, double long) {
    return Position(
      longitude: lat,
      latitude: long,
      timestamp: timestamp,
      accuracy: accuracy,
      altitude: altitude,
      altitudeAccuracy: altitudeAccuracy,
      heading: heading,
      headingAccuracy: headingAccuracy,
      speed: speed,
      speedAccuracy: speedAccuracy,
    );
  }
}

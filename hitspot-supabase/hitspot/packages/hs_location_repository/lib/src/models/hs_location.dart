import 'package:hs_location_repository/hs_location_repository.dart';

class HSLocation {
  final Placemark placemark;
  final double latitude, longitude;

  const HSLocation({
    required this.placemark,
    required this.latitude,
    required this.longitude,
  });

  String? get name => placemark.name;

  @override
  String toString() {
    return """
Instance of HSLocation
Name: $name,
Lat: $latitude,
Long: $longitude
""";
  }
}

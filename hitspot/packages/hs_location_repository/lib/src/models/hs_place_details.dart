import 'package:hs_location_repository/hs_location_repository.dart';

class HSPlaceDetails extends HSPrediction {
  HSPlaceDetails({
    required this.latitude,
    required this.longitude,
    required super.description,
    required super.placeID,
    this.imageUrl,
    super.reference = "",
  });

  final double latitude, longitude;
  final String? imageUrl;

  @override
  String toString() {
    return """
HSPlaceDetails
description: $description,
placeID: $placeID,
reference: $reference,
lat: $latitude,
long: $longitude
img: $imageUrl
""";
  }
}

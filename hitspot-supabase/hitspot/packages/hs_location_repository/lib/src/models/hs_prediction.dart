class HSPrediction {
  final String description, placeID, reference;

  HSPrediction({
    required this.description,
    required this.placeID,
    required this.reference,
  });

  factory HSPrediction.deserialize(Map<String, dynamic> data) {
    return HSPrediction(
        description: data["description"],
        placeID: data["place_id"],
        reference: data["reference"]);
  }

  Map<String, dynamic> serialize() {
    return {
      "description": description,
      "place_id": placeID,
      "reference": reference,
    };
  }

  @override
  String toString() {
    return """
HSPrediction
description: $description
placeID: $placeID
reference: $reference
""";
  }
}

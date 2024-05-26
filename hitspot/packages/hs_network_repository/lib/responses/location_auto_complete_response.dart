import 'dart:convert';

import 'package:hs_network_repository/models/location_complete_prediction.dart';

class LocationAutoCompleteResponse {
  final List<LocationCompletePrediction>? predictions;

  LocationAutoCompleteResponse({this.predictions});

  factory LocationAutoCompleteResponse.fromJson(Map<String, dynamic> json) {
    return LocationAutoCompleteResponse(
      predictions: json['predictions'] != null
          ? (json['predictions'] as List<dynamic>)
              .map((json) => LocationCompletePrediction.fromJson(json))
              .toList()
          : null,
    );
  }

  static LocationAutoCompleteResponse parseLocationQueryResponse(
      String responseBody) {
    final parsed = json.decode(responseBody).cast<String, dynamic>();
    return LocationAutoCompleteResponse.fromJson(parsed);
    // return parsed['predictions'] != null ? parsed['predictions'].map< : null;
  }
}

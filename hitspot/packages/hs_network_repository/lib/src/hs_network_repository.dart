import 'dart:async';
import 'dart:convert';
import 'package:hs_debug_logger/hs_debug_logger.dart';
import 'package:hs_network_repository/responses/location_auto_complete_response.dart';
import 'package:http/http.dart' as http;

class HSNetworkRepository {
  Future<List<String>?> makeLocationQuery(String? query) async {
    Uri uri = Uri.https(
        "maps.googleapis.com",
        "maps/api/place/autocomplete/json",
        {"input": query, "key": "AIzaSyDxNpYTqwsJOoeXdOJ4yN3e4VPU1xwNZlU"});

    try {
      final response = await http.get(uri, headers: {});
      if (response.statusCode == 200) {
        LocationAutoCompleteResponse result =
            LocationAutoCompleteResponse.parseLocationQueryResponse(
                response.body);
        HSDebugLogger.logInfo(response.body);
        if (result.predictions != null) {
          List<String> predictions = result.predictions!
              .map((e) => e.description)
              .where((description) => description != null)
              .map((description) => description!)
              .toList();
          return predictions;
        }
      }
    } catch (e) {
      HSDebugLogger.logError(e.toString());
    }
    return null;
  }
}

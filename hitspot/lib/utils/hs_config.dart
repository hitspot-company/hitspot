import 'package:flutter_config/flutter_config.dart';
import 'package:get/get.dart';

class HSConfig extends GetxService {
  static HSConfig instance = Get.find();

  String get googleMapsKey => FlutterConfig.get("GOOGLE_MAPS_KEY");
  String get algoliaKey => FlutterConfig.get("ALGOLIA_API_KEY");
  String get algoliaAppID => FlutterConfig.get("ALGOLIA_APP_ID");

  @override
  void onReady() {
    print("HSConfig ready!");
    super.onReady();
  }
}

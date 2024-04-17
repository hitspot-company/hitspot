import 'package:get/get.dart';

class HSImages extends GetxService {
  static HSImages instance = Get.find();

  static const _icons = "assets/icons/icon/";
  static const _logos = "assets/icons/side/";

  static const String _iconPath = "$_icons/ZIELONY.png";
  static const String _logoPath = "$_logos/ZIELONY.png";

  String get icon => _iconPath;
  String get logo => _logoPath;

  @override
  void onReady() {
    print("HSImages ready!");
    super.onReady();
  }
}

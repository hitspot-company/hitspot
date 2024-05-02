class HSAssets {
  HSAssets._internal();
  static final HSAssets _instance = HSAssets._internal();
  static HSAssets get instance => _instance;

  static const String _iconsPath = "assets/icons";
  final String textLogo = "$_iconsPath/side/ZIELONY.png";
  final String logo = "$_iconsPath/icon/ZIELONY.png";
}

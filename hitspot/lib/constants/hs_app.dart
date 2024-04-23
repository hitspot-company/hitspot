import 'package:hitspot/constants/hs_assets.dart';
import 'package:hitspot/constants/hs_firestore.dart';
import 'package:hitspot/constants/hs_theming.dart';

class HSApp {
  static const String title = "Hitspot";
  static HSTheming theming = HSTheming.instance;
  static HSAssets assets = HSAssets();
  static HSFirestore firestore = HSFirestore.instance;
}

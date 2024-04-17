import 'package:get/get.dart';
import 'package:hitspot/models/hs_user.dart';

class HSCurrentUser extends GetxService {
  static HSCurrentUser instance = Get.find();

  late HSUser user; // TODO: Assign data

  @override
  void onInit() {
    print("HSCurrentUser ready!");
    super.onInit();
  }
}

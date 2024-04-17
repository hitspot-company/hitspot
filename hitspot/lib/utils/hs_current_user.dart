import 'package:get/get.dart';
import 'package:hitspot/models/hs_user.dart';

class HSCurrentUser extends GetxService {
  static HSCurrentUser instance = Get.find();

  late HSUser? user;

  void initCurrentUser(HSUser cUser) async {
    user = cUser;
    print("User intiialized!");
  }

  void disposeCurrentUser() {
    user = null;
    print("User disposed!");
  }

  @override
  void onReady() {
    // TODO: Implement some listener to keep track of current user changes
    print("HSCurrentUser ready!");
    super.onReady();
  }
}

import 'package:flutter/material.dart';
import 'package:hitspot/user_profile/edit_profile/view/edit_profile_page.dart';

class EditProfileProvider extends StatelessWidget {
  const EditProfileProvider({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(
      builder: (_) => const EditProfileProvider(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const EditProfilePage();
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/features/user_profile/edit_profile/cubit/hs_edit_profile_cubit.dart';
import 'package:hitspot/features/user_profile/edit_profile/view/edit_profile_page.dart';

class EditProfileProvider extends StatelessWidget {
  const EditProfileProvider({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(
      builder: (_) => const EditProfileProvider(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HSEditProfileCubit(app.databaseRepository),
      child: const EditProfilePage(),
    );
  }
}

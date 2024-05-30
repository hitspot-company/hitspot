import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hitspot/features/complete_profile/cubit/hs_complete_profile_cubit.dart';
import 'package:hitspot/features/complete_profile/view/complete_profile_page.dart';

class CompleteProfileProvider extends StatelessWidget {
  const CompleteProfileProvider({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HSCompleteProfileCubit(),
      child: const CompleteProfilePage(),
    );
  }
}

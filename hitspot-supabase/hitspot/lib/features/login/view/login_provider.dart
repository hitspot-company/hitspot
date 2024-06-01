import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hitspot/features/login/cubit/hs_login_cubit.dart';
import 'package:hitspot/features/login/view/login_page.dart';

class LoginProvider extends StatelessWidget {
  const LoginProvider({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HSLoginCubit(),
      child: const LoginPage(),
    );
  }
}

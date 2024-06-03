import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/features/login_1/cubit/login_cubit.dart';
import 'package:hitspot/features/login_1/view/login_page.dart';

class LoginProvider extends StatelessWidget {
  const LoginProvider({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(builder: (_) => const LoginProvider());
  }

  static Page<void> page() => const MaterialPage<void>(child: LoginProvider());

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HSLoginCubit(app.authenticationRepository),
      child: const LoginForm(),
    );
  }
}

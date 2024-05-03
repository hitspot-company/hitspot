import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hitspot/utils/assets/hs_assets.dart';
import 'package:hitspot/login/cubit/login_cubit.dart';
import 'package:hitspot/login/view/login_form.dart';
import 'package:hitspot/widgets/hs_appbar.dart';
import 'package:hitspot/widgets/hs_scaffold.dart';
import 'package:hs_authentication_repository/hs_authentication_repository.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  static Page<void> page() => const MaterialPage<void>(child: LoginPage());

  @override
  Widget build(BuildContext context) {
    return HSScaffold(
      resizeToAvoidBottomInset: false,
      sidePadding: 24.0,
      body: BlocProvider(
        create: (_) => HSLoginCubit(context.read<HSAuthenticationRepository>()),
        child: const LoginForm(),
      ),
    );
  }
}

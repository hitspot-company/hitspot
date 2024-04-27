import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hitspot/constants/hs_assets.dart';
import 'package:hitspot/register/cubit/hs_register_cubit.dart';
import 'package:hitspot/register/view/register_form.dart';
import 'package:hs_authentication_repository/hs_authentication_repository.dart';
import 'package:hitspot/widgets/hs_appbar.dart';
import 'package:hitspot/widgets/hs_scaffold.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(builder: (_) => const RegisterPage());
  }

  @override
  Widget build(BuildContext context) {
    return HSScaffold(
      sidePadding: 16.0,
      appBar: HSAppBar(
        center: Image.asset(HSAssets.instance.textLogo),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: BlocProvider<HSRegisterCubit>(
          create: (_) =>
              HSRegisterCubit(context.read<HSAuthenticationRepository>()),
          child: const RegisterForm(),
        ),
      ),
    );
  }
}

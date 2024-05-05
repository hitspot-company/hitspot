import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hitspot/app/hs_app.dart';
import 'package:hitspot/password_reset/cubit/hs_password_reset_cubit.dart';
import 'package:hitspot/password_reset/view/password_reset_form.dart';
import 'package:hitspot/widgets/hs_appbar.dart';
import 'package:hitspot/widgets/hs_scaffold.dart';

class PasswordResetPage extends StatelessWidget {
  const PasswordResetPage({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(builder: (_) => const PasswordResetPage());
  }

  @override
  Widget build(BuildContext context) {
    final app = HSApp.instance;
    return HSScaffold(
      sidePadding: 16.0,
      appBar: HSAppBar(
        enableDefaultBackButton: true,
        title: "Reset Password",
        titleBold: true,
      ),
      body: BlocProvider(
        create: (context) => HSPasswordResetCubit(app.authRepository),
        child: const PasswordResetForm(),
      ),
    );
  }
}

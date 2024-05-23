import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hitspot/app/hs_app.dart';
import 'package:hitspot/features/authentication/hs_authentication_bloc.dart';
import 'package:hitspot/features/verify_email/cubit/hs_verify_email_cubit.dart';
import 'package:hitspot/features/verify_email/view/verify_email_form.dart';
import 'package:hitspot/widgets/hs_appbar.dart';
import 'package:hitspot/widgets/hs_scaffold.dart';

class VerifyEmailPage extends StatelessWidget {
  const VerifyEmailPage({super.key});

  static Page<void> page() =>
      const MaterialPage<void>(child: VerifyEmailPage());

  static Route<void> route() {
    return MaterialPageRoute<void>(builder: (_) => const VerifyEmailPage());
  }

  @override
  Widget build(BuildContext context) {
    return HSScaffold(
      appBar: HSAppBar(
        title: "Verify Email",
        enableDefaultBackButton: true,
        defaultBackButtonCallback: () =>
            HSApp.instance.authBloc.add(const HSAppLogoutRequested()),
      ),
      body: BlocProvider(
        create: (context) => HSVerifyEmailCubit(HSApp.instance.authRepository),
        child: const VerifyEmailForm(),
      ),
    );
  }
}

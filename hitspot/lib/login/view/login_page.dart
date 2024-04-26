import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hitspot/login/cubit/login_cubit.dart';
import 'package:hitspot/login/view/login_form.dart';
import 'package:hitspot/presentation/widgets/hs_appbar.dart';
import 'package:hitspot/presentation/widgets/hs_scaffold.dart';
import 'package:hitspot/repositories/hs_authentication_repository.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  static Page<void> page() => const MaterialPage<void>(child: LoginPage());

  @override
  Widget build(BuildContext context) {
    return HSScaffold(
      appBar: HSAppBar(title: 'Login'),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: BlocProvider(
          create: (_) => LoginCubit(context.read<HSAuthenticationRepository>()),
          child: const LoginForm(),
        ),
      ),
    );
  }
}

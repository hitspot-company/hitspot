import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/features/login/cubit/hs_login_cubit.dart';
import 'package:hitspot/widgets/hs_appbar.dart';
import 'package:hitspot/widgets/hs_button.dart';
import 'package:hitspot/widgets/hs_scaffold.dart';
import 'package:hitspot/widgets/hs_textfield.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return HSScaffold(
      appBar: HSAppBar(
        title: const Text("Login"),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 80.0,
            child: HSTextField(
              hintText: "Email",
              fillColor: app.textFieldFillColor,
            ),
          ),
          const Gap(16.0),
          HSButton(
            child: const Text("SIGN IN"),
            onPressed: () => BlocProvider.of<HSLoginCubit>(context).signIn(),
          ),
        ],
      ),
    );
  }
}

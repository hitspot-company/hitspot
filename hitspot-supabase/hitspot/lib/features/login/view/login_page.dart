import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:hitspot/features/login/cubit/hs_login_cubit.dart';
import 'package:hitspot/widgets/hs_appbar.dart';
import 'package:hitspot/widgets/hs_button.dart';
import 'package:hitspot/widgets/hs_scaffold.dart';

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
              fillColor: Colors.grey[200],
            ),
          ),
          const Gap(16.0),
          HSButton(
            child: Text("SIGN IN"),
            onPressed: () => BlocProvider.of<HSLoginCubit>(context).signIn(),
          ),
        ],
      ),
    );
  }
}

class HSTextField extends StatelessWidget {
  const HSTextField({super.key, this.hintText, this.fillColor, this.onChanged});

  final String? hintText;
  final Color? fillColor;
  final Function(String?)? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hintText,
        border: OutlineInputBorder(
          borderSide: fillColor != null ? BorderSide.none : const BorderSide(),
          borderRadius: const BorderRadius.all(
            Radius.circular(8.0),
          ),
        ),
        filled: fillColor != null,
        fillColor: fillColor,
      ),
    );
  }
}

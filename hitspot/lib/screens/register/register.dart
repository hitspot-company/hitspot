import 'package:flutter/material.dart';
import 'package:hitspot/widgets/global/hs_appbar.dart';
import 'package:hitspot/widgets/global/hs_scaffold.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return HSScaffold(
      appBar: HSAppBar(
        title: "Register Page",
      ),
    );
  }
}

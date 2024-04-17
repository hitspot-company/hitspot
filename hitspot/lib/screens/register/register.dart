import 'package:flutter/material.dart';
import 'package:hitspot/utils/hs_app.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () =>
              HSApp.auth.register("test_new@gmail.com", "password"),
          child: const Text("Register"),
        ),
      ),
    );
  }
}

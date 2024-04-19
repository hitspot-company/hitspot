import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hitspot/presentation/screens/home/home.dart';
import 'package:hitspot/presentation/screens/register/register.dart';
import 'package:hitspot/presentation/widgets/global/hs_scaffold.dart';

class AuthFlowScreen extends StatelessWidget {
  const AuthFlowScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return HSScaffold(
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            return const HomePage();
          }
          print("Returning register page");
          return RegisterPage();
        },
      ),
    );
  }
}

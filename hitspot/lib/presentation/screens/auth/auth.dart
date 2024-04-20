import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hitspot/presentation/screens/email_validation/email_validation.dart';
import 'package:hitspot/presentation/screens/home/home.dart';
import 'package:hitspot/presentation/screens/profile_completion/profile_completion.dart';
import 'package:hitspot/presentation/screens/register/register.dart';
import 'package:hitspot/presentation/widgets/global/hs_scaffold.dart';

class AuthFlowScreen extends StatelessWidget {
  const AuthFlowScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return HSScaffold(
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
          // if (snapshot.hasData) {
          //   if (snapshot.data!.emailVerified) {
          //     return const HomePage();
          //   } else {
          //     return const EmailValidationPage(
          //       enableBackButton: false,
          //     );
          //   }
          // }
          return const ProfileCompletionPage();
        },
      ),
    );
  }
}

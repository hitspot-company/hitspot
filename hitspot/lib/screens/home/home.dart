import 'package:flutter/material.dart';
import 'package:hitspot/utils/hs_auth.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.green,
      child: Center(
        child: TextButton(
          onPressed: () =>
              HSAuth.instance.signOut().then((value) => print("signed out")),
          child: const Text("Sign Out"),
        ),
      ),
    );
  }
}

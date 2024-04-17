import 'package:flutter/material.dart';
import 'package:hitspot/utils/hs_app.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.green,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              HSApp.currentUser.user!.docID!,
              style: HSApp.textTheme.displayMedium,
            ),
            TextButton(
              onPressed: HSApp.auth.signOut,
              child: const Text("Sign Out"),
            ),
          ],
        ));
  }
}

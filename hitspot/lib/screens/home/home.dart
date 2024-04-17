import 'package:flutter/material.dart';
import 'package:hitspot/utils/hs_app.dart';
import 'package:hitspot/utils/hs_auth.dart';

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
              onPressed: () => HSAuth.instance
                  .signOut()
                  .then((value) => print("signed out")),
              child: const Text("Sign Out"),
            ),
          ],
        ));
  }
}

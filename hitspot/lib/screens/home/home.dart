import 'package:flutter/material.dart';
import 'package:hitspot/utils/hs_app.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  static final app = HSApp.instance;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.green,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            app.currentUser.user!.docID!,
            style: app.textTheme.displayMedium,
          ),
          TextButton(
            onPressed: app.auth.signOut,
            child: const Text("Sign Out"),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hitspot/bloc/authentication/hs_authentication_bloc.dart';

class HomePage extends StatelessWidget {
  static const String id = "home_page";
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.green,
      child: Center(
        child: CupertinoButton(
          onPressed: () => BlocProvider.of<HSAuthenticationBloc>(context)
              .add(HSSignOutEvent()),
          color: Colors.amber,
          child: const Text("Sign Out"),
        ),
      ),
    );
  }
}

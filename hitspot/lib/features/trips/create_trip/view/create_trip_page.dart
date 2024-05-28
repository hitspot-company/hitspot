import 'package:flutter/material.dart';
import 'package:hitspot/widgets/hs_appbar.dart';
import 'package:hitspot/widgets/hs_scaffold.dart';

class CreateTripPage extends StatelessWidget {
  const CreateTripPage({super.key});

  @override
  Widget build(BuildContext context) {
    return HSScaffold(
      appBar: HSAppBar(enableDefaultBackButton: true),
      body: Container(
        color: Colors.teal,
      ),
    );
  }
}

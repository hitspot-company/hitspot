import 'package:flutter/material.dart';
import 'package:hitspot/widgets/hs_appbar.dart';
import 'package:hitspot/widgets/hs_scaffold.dart';

class BoardsPage extends StatelessWidget {
  const BoardsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return HSScaffold(
      appBar: HSAppBar(
        enableDefaultBackButton: true,
        titleText: "Single Board",
      ),
      body: Container(
        color: Colors.teal,
      ),
    );
  }
}

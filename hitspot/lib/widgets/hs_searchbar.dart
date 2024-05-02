import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hitspot/home/view/home_search.dart';
import 'package:hitspot/widgets/hs_textfield.dart';

class HSSearchBar extends StatelessWidget {
  const HSSearchBar({super.key, required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: HSTextField(
        suffixIcon: const Icon(FontAwesomeIcons.magnifyingGlass),
        fillColor: const Color.fromARGB(16, 158, 158, 158),
        hintText: "Search...",
        onTap: () async {
          await showSearch(context: context, delegate: HSHomeSearchDelegate());
        },
      ),
    );
  }
}

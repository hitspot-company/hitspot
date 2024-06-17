import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/features/search/view/search_page.dart';
import 'package:hitspot/widgets/hs_textfield.dart';

class HSSearchBar extends StatelessWidget {
  const HSSearchBar({super.key, required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: HSTextField(
        readOnly: true,
        suffixIcon: const Icon(
          FontAwesomeIcons.magnifyingGlass,
          color: Colors.grey,
        ),
        fillColor: appTheme.textfieldFillColor,
        hintText: "Search...",
        onTap: () => navi.pushPage(page: const SearchPage()),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/features/search/cubit/hs_main_search_cubit.dart';
import 'package:hitspot/features/search/view/main_search_delegate.dart';
import 'package:hitspot/widgets/hs_textfield.dart';

class HSSearchBar extends StatelessWidget {
  const HSSearchBar(
      {super.key,
      required this.initialValue,
      required this.height,
      required this.onChanged});

  final String initialValue;
  final double height;
  final void Function(String) onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: HSTextField(
        initialValue: initialValue,
        readOnly: false,
        suffixIcon: Icon(
          FontAwesomeIcons.magnifyingGlass,
          color: Colors.grey[700],
        ),
        fillColor:
            Theme.of(context).textTheme.bodySmall!.color!.withOpacity(0.1),
        hintText: "Search...",
        onChanged: onChanged,
      ),
    );
  }
}

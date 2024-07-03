import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/features/search/cubit/hs_main_search_cubit.dart';
import 'package:hitspot/features/search/view/main_search_delegate.dart';
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
        onTap: () => showSearch(
            context: context,
            delegate: MainSearchDelegate(
                BlocProvider.of<HSMainSearchCubit>(context))),
      ),
    );
  }
}

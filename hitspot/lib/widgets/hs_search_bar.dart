import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/features/search/cubit/hs_main_search_cubit.dart';
import 'package:hitspot/features/search/view/main_search_delegate.dart';
import 'package:hitspot/widgets/hs_textfield.dart';

class HSSearchBar extends StatefulWidget {
  HSSearchBar(
      {super.key,
      required this.initialValue,
      required this.height,
      required this.onChanged,
      required this.controller});

  final String initialValue;
  final double height;
  final void Function(String) onChanged;
  final TextEditingController controller;

  @override
  State<HSSearchBar> createState() => _HSSearchBarState();
}

class _HSSearchBarState extends State<HSSearchBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextFormField(
        controller: widget.controller,
        onChanged: widget.onChanged,
        decoration: InputDecoration(
          filled: true,
          fillColor: Theme.of(context).colorScheme.surface,
          hintText: "Search...",
          hintStyle: TextStyle(color: Colors.grey[400]),
          prefixIcon: Icon(
            FontAwesomeIcons.magnifyingGlass,
            color: Theme.of(context).colorScheme.primary,
            size: 18,
          ),
          suffixIcon: IconButton(
              icon: Icon(
                Icons.clear,
                color: Colors.grey[600],
                size: 20,
              ),
              onPressed: () {
                widget.controller.clear();
                widget.onChanged('');
              }),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 20),
        ),
        style: TextStyle(
          color: Theme.of(context).textTheme.bodyLarge?.color,
          fontSize: 16,
        ),
      ),
    );
  }
}

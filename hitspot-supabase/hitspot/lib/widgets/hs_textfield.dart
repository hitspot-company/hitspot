import 'package:flutter/material.dart';

class HSTextField extends StatelessWidget {
  const HSTextField({super.key, this.hintText, this.fillColor, this.onChanged});

  final String? hintText;
  final Color? fillColor;
  final Function(String?)? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hintText,
        border: OutlineInputBorder(
          borderSide: fillColor != null ? BorderSide.none : const BorderSide(),
          borderRadius: const BorderRadius.all(
            Radius.circular(8.0),
          ),
        ),
        filled: fillColor != null,
        fillColor: fillColor,
      ),
    );
  }
}

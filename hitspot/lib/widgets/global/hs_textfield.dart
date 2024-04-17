import 'package:flutter/material.dart';

class HSTextField extends StatelessWidget {
  const HSTextField({
    super.key,
    this.hintText,
    this.prefixIcon,
  });

  final String? hintText;
  final Icon? prefixIcon;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
        prefixIcon: prefixIcon,
        hintText: hintText,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(8.0),
          ),
        ),
      ),
    );
  }
}

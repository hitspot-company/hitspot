import 'package:flutter/material.dart';

class HSTextField extends StatelessWidget {
  const HSTextField({
    super.key,
    this.hintText,
    this.prefixIcon,
    this.controller,
    this.validator,
    this.onChanged,
    this.keyboardType,
    this.obscureText = false,
    this.node,
    this.onTap,
    this.readOnly = false,
  });

  final String? hintText;
  final Widget? prefixIcon;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final Function(String)? onChanged;
  final TextInputType? keyboardType;
  final bool obscureText;
  final bool readOnly;
  final FocusNode? node;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      readOnly: readOnly,
      controller: controller,
      focusNode: node,
      validator: validator,
      onChanged: onChanged,
      obscureText: obscureText,
      keyboardType: keyboardType,
      onTap: onTap,
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

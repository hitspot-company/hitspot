import 'package:flutter/material.dart';

class HSTextField extends StatelessWidget {
  const HSTextField({
    super.key,
    this.hintText,
    this.fillColor,
    this.onChanged,
    this.suffixIcon,
    this.autofocus = false,
    this.initialValue,
    this.onTap,
    this.readOnly = false,
    this.maxLines,
    this.maxLength,
    this.scrollPadding = const EdgeInsets.all(20.0),
    this.textInputAction,
    this.errorText,
    this.keyboardType,
    this.obscureText = false,
  });

  final String? hintText;
  final Color? fillColor;
  final Function(String)? onChanged;
  final Widget? suffixIcon;
  final bool autofocus;
  final String? initialValue;
  final bool readOnly;
  final VoidCallback? onTap;
  final int? maxLines;
  final int? maxLength;
  final EdgeInsets scrollPadding;
  final TextInputAction? textInputAction;
  final String? errorText;
  final TextInputType? keyboardType;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: maxLines != 1 ? false : obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      scrollPadding: scrollPadding,
      maxLines: maxLines,
      maxLength: maxLength,
      onTap: onTap,
      readOnly: readOnly,
      autofocus: autofocus,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hintText,
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderSide: fillColor != null ? BorderSide.none : const BorderSide(),
          borderRadius: const BorderRadius.all(
            Radius.circular(8.0),
          ),
        ),
        filled: fillColor != null,
        fillColor: fillColor,
        errorText: errorText,
      ),
    );
  }
}

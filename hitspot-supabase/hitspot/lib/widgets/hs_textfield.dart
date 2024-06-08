import 'package:flutter/material.dart';
import 'package:hitspot/constants/constants.dart';

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
    this.maxLines = 1,
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
  final int maxLines;
  final int? maxLength;
  final EdgeInsets scrollPadding;
  final TextInputAction? textInputAction;
  final String? errorText;
  final TextInputType? keyboardType;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: obscureText,
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

  factory HSTextField.filled({
    Key? key,
    String? hintText,
    Color? fillColor,
    Function(String)? onChanged,
    Widget? suffixIcon,
    bool autofocus = false,
    String? initialValue,
    bool readOnly = false,
    VoidCallback? onTap,
    int maxLines = 1,
    int? maxLength,
    EdgeInsets scrollPadding = const EdgeInsets.all(20.0),
    TextInputAction? textInputAction,
    String? errorText,
    TextInputType? keyboardType,
    bool obscureText = false,
  }) {
    return HSTextField(
      key: key,
      hintText: hintText,
      fillColor: fillColor ?? appTheme.textfieldFillColor,
      onChanged: onChanged,
      suffixIcon: suffixIcon,
      autofocus: autofocus,
      initialValue: initialValue,
      readOnly: readOnly,
      onTap: onTap,
      maxLines: maxLines,
      maxLength: maxLength,
      scrollPadding: scrollPadding,
      textInputAction: textInputAction,
      errorText: errorText,
      keyboardType: keyboardType,
      obscureText: obscureText,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:hitspot/constants/constants.dart';

class HSTextField extends StatelessWidget {
  const HSTextField({
    super.key,
    this.hintText,
    this.controller,
    this.fillColor,
    this.onChanged,
    this.suffixIcon,
    this.autofocus = false,
    this.initialValue,
    this.onTap,
    this.readOnly = false,
    this.autocorrect = true,
    this.maxLines = 1,
    this.maxLength,
    this.scrollPadding = const EdgeInsets.all(20.0),
    this.textInputAction,
    this.errorText,
    this.keyboardType,
    this.obscureText = false,
    this.focusNode,
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
  final bool obscureText, autocorrect;
  final FocusNode? focusNode;
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      autocorrect: autocorrect,
      controller: controller,
      focusNode: focusNode,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      scrollPadding: scrollPadding,
      maxLines: maxLines,
      maxLength: maxLength,
      onTap: onTap,
      readOnly: readOnly,
      autofocus: autofocus,
      initialValue: initialValue,
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

  factory HSTextField.filled(
      {Key? key,
      String? hintText,
      String? initialValue,
      TextEditingController? controller,
      Color? fillColor,
      Function(String)? onChanged,
      Widget? suffixIcon,
      bool autofocus = false,
      bool? autocorrect,
      bool readOnly = false,
      VoidCallback? onTap,
      int maxLines = 1,
      int? maxLength,
      EdgeInsets scrollPadding = const EdgeInsets.all(20.0),
      TextInputAction? textInputAction,
      String? errorText,
      TextInputType? keyboardType,
      bool obscureText = false,
      FocusNode? focusNode}) {
    return HSTextField(
      key: key,
      hintText: hintText,
      focusNode: focusNode,
      controller: controller,
      autocorrect: autocorrect ?? true,
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

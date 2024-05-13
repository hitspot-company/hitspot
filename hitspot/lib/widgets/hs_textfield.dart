import 'package:flutter/material.dart';

class HSTextField extends StatelessWidget {
  const HSTextField({
    super.key,
    this.hintText,
    this.errorText,
    this.prefixIcon,
    this.onTapPrefix,
    this.suffixIcon,
    this.onTapSuffix,
    this.controller,
    this.validator,
    this.onChanged,
    this.keyboardType,
    this.obscureText = false,
    this.node,
    this.onTap,
    this.readOnly = false,
    this.scrollPadding = const EdgeInsets.all(20.0),
    this.textInputAction,
    this.fillColor,
    this.labelText,
    this.initialValue,
    this.floatingLabelBehavior,
    this.autofocus = false,
  });

  final String? hintText;
  final String? labelText;
  final Widget? prefixIcon;
  final VoidCallback? onTapPrefix;
  final Widget? suffixIcon;
  final VoidCallback? onTapSuffix;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final Function(String)? onChanged;
  final TextInputType? keyboardType;
  final bool obscureText;
  final bool readOnly;
  final bool autofocus;
  final FocusNode? node;
  final VoidCallback? onTap;
  final String? errorText;
  final EdgeInsets scrollPadding;
  final TextInputAction? textInputAction;
  final Color? fillColor;
  final FloatingLabelBehavior? floatingLabelBehavior;
  final String? initialValue;

  @override
  Widget build(BuildContext context) {
    assert(!(prefixIcon != null && suffixIcon != null),
        "Suffix and prefix cannot be used at the same time");
    return GestureDetector(
      onTap: onTap,
      child: AbsorbPointer(
        absorbing: readOnly,
        child: TextFormField(
          autofocus: autofocus,
          scrollPadding: scrollPadding,
          // readOnly: readOnly,
          controller: controller,
          focusNode: node,
          validator: validator,
          onChanged: onChanged,
          obscureText: obscureText,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          // onTap: onTap,
          initialValue: initialValue,
          decoration: InputDecoration(
            fillColor: fillColor,
            filled: fillColor != null ? true : false,
            floatingLabelBehavior: floatingLabelBehavior,
            errorText: errorText,
            prefixIcon: suffixIcon != null
                ? null
                : GestureDetector(onTap: onTapPrefix, child: prefixIcon),
            suffixIcon: prefixIcon != null
                ? null
                : GestureDetector(onTap: onTapSuffix, child: suffixIcon),
            hintText: hintText,
            labelText: labelText,
            border: OutlineInputBorder(
              borderSide:
                  fillColor != null ? BorderSide.none : const BorderSide(),
              borderRadius: const BorderRadius.all(
                Radius.circular(8.0),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

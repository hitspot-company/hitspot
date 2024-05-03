import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:toastification/toastification.dart';

enum HSSnackType { success, error, warning }

class HSToasts {
  // SINGLETON
  HSToasts._internal();
  static final HSToasts _instance = HSToasts._internal();
  static HSToasts get instance => _instance;

  void toast(
    BuildContext context, {
    required HSSnackType snackType,
    required String title,
    Widget? description,
    String? descriptionText,
    int autoCloseDurationTime = 5,
    Alignment? alignment,
    int? animationDuration,
    Icon? icon,
    Color? primaryColor,
  }) {
    assert(!(description != null && descriptionText != null),
        "Description and DescriptionText cannot be non-null at the same time");

    ToastificationType toastType;
    Icon toastIcon;
    Color toastColor;

    switch (snackType) {
      case HSSnackType.success:
        toastType = ToastificationType.success;
        toastIcon = icon ?? const Icon(FontAwesomeIcons.check);
        toastColor = primaryColor ?? Colors.green;
        break;
      case HSSnackType.error:
        toastType = ToastificationType.error;
        toastIcon = icon ?? const Icon(FontAwesomeIcons.exclamation);
        toastColor = primaryColor ?? Colors.red;
        break;
      case HSSnackType.warning:
        toastType = ToastificationType.warning;
        toastIcon = icon ?? const Icon(FontAwesomeIcons.triangleExclamation);
        toastColor = primaryColor ?? Colors.yellow;
        break;
    }

    toastification.show(
      context: context,
      type: toastType,
      style: ToastificationStyle.fillColored,
      autoCloseDuration: Duration(seconds: autoCloseDurationTime),
      title: Text(title),
      description: description ?? Text(descriptionText ?? ""),
      alignment: alignment ?? Alignment.topRight,
      animationDuration: Duration(milliseconds: animationDuration ?? 300),
      animationBuilder: (context, animation, alignment, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      icon: toastIcon,
      primaryColor: toastColor,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      borderRadius: BorderRadius.circular(12),
      showProgressBar: true,
      closeButtonShowType: CloseButtonShowType.onHover,
      closeOnClick: false,
      pauseOnHover: true,
      dragToClose: true,
    );
  }
}

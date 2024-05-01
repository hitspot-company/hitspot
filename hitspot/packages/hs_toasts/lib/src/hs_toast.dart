import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:toastification/toastification.dart';

enum HSSnackType { success, error, warning }

class HSToasts {
  static void snack(
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
    assert((!(description != null && descriptionText != null)),
        "Description and DescriptionText cannot be non-null at the same time");
    switch (snackType) {
      case HSSnackType.success:
        _success(
          context,
          title: title,
          description: description,
          descriptionText: descriptionText,
          autoCloseDurationTime: autoCloseDurationTime,
          alignment: alignment,
          animationDuration: animationDuration,
          icon: icon,
          primaryColor: primaryColor,
        );
      case HSSnackType.error:
        _error(
          context,
          title: title,
          description: description,
          descriptionText: descriptionText,
          autoCloseDurationTime: autoCloseDurationTime,
          alignment: alignment,
          animationDuration: animationDuration,
          icon: icon,
          primaryColor: primaryColor,
        );
      case HSSnackType.warning:
        _warning(
          context,
          title: title,
          description: description,
          descriptionText: descriptionText,
          autoCloseDurationTime: autoCloseDurationTime,
          alignment: alignment,
          animationDuration: animationDuration,
          icon: icon,
          primaryColor: primaryColor,
        );
    }
  }

  static void _success(
    BuildContext context, {
    required String title,
    Widget? description,
    String? descriptionText,
    int autoCloseDurationTime = 5,
    Alignment? alignment,
    int? animationDuration,
    Icon? icon,
    Color? primaryColor,
  }) {
    assert((!(description != null && descriptionText != null)),
        "Description and DescriptionText cannot be non-null at the same time");
    toastification.show(
      context: context,
      type: ToastificationType.success,
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
      icon: icon ?? const Icon(FontAwesomeIcons.check),
      primaryColor: primaryColor ?? Colors.green,
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

  static void _error(
    BuildContext context, {
    required String title,
    Widget? description,
    String? descriptionText,
    int autoCloseDurationTime = 5,
    Alignment? alignment,
    int? animationDuration,
    Icon? icon,
    Color? primaryColor,
  }) {
    toastification.show(
      context: context,
      type: ToastificationType.error,
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
      icon: icon ?? const Icon(FontAwesomeIcons.exclamation),
      primaryColor: primaryColor ?? Colors.red,
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

  static void _warning(
    BuildContext context, {
    required String title,
    Widget? description,
    String? descriptionText,
    int autoCloseDurationTime = 5,
    Alignment? alignment,
    int? animationDuration,
    Icon? icon,
    Color? primaryColor,
  }) {
    toastification.show(
      context: context,
      type: ToastificationType.warning,
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
      icon: icon ?? const Icon(FontAwesomeIcons.triangleExclamation),
      primaryColor: primaryColor ?? Colors.yellow,
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

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:toastification/toastification.dart';

enum HSToastType { success, error, warning, pushNotification }

class HSToasts {
  // SINGLETON
  HSToasts._internal();
  static final HSToasts _instance = HSToasts._internal();
  static HSToasts get instance => _instance;

  void toast(
    BuildContext context, {
    required HSToastType toastType,
    required String title,
    Widget? description,
    String? descriptionText,
    int autoCloseDurationTime = 5,
    Alignment? alignment,
    int? animationDuration,
    Icon? icon,
    Color? primaryColor,
    Function()? onTap,
  }) {
    assert(!(description != null && descriptionText != null),
        "Description and DescriptionText cannot be non-null at the same time");

    ToastificationType chosenType;
    Icon toastIcon;
    Color toastColor;

    switch (toastType) {
      case HSToastType.success:
        chosenType = ToastificationType.success;
        toastIcon = icon ?? const Icon(FontAwesomeIcons.check);
        toastColor = primaryColor ?? Colors.green;
        break;
      case HSToastType.error:
        chosenType = ToastificationType.error;
        toastIcon = icon ?? const Icon(FontAwesomeIcons.exclamation);
        toastColor = primaryColor ?? Colors.red;
        break;
      case HSToastType.warning:
        chosenType = ToastificationType.warning;
        toastIcon = icon ?? const Icon(FontAwesomeIcons.triangleExclamation);
        toastColor = primaryColor ?? Colors.yellow;
        break;

      case HSToastType.pushNotification:
        chosenType = ToastificationType.info;
        toastIcon = icon ?? const Icon(FontAwesomeIcons.bell);
        toastColor = primaryColor!;
        break;
    }

    toastification.show(
      context: context,
      type: chosenType,
      style: ToastificationStyle.fillColored,
      autoCloseDuration: Duration(seconds: autoCloseDurationTime),
      title: GestureDetector(
        onTap: onTap,
        child: Text(
          title,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      description: GestureDetector(
        onTap: onTap,
        child: description ??
            Text(descriptionText ?? "",
                style: Theme.of(context).textTheme.titleSmall),
      ),
      alignment: alignment ?? Alignment.topRight,
      animationDuration: Duration(milliseconds: animationDuration ?? 300),
      animationBuilder: (context, animation, alignment, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      icon: GestureDetector(onTap: onTap, child: toastIcon),
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

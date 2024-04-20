import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

class HSNotifications {
  static HSNotifications instance = HSNotifications();
  HSSnackBarService snackbar(snackContext) => HSSnackBarService(snackContext);
}

class HSSnackBarService {
  static HSSnackBarService instance(instanceContext) =>
      HSSnackBarService(instanceContext);
  final Alignment position = Alignment.bottomCenter;
  final ToastificationStyle style = ToastificationStyle.fillColored;
  final Duration autoCloseDuration = const Duration(seconds: 5);
  final BuildContext context;

  const HSSnackBarService(this.context);

  void success({required String title, required String message}) {
    toastification.show(
      context: context,
      type: ToastificationType.success,
      style: style,
      alignment: position,
      title: Text(title),
      description: Text(message),
      autoCloseDuration: autoCloseDuration,
    );
  }

  void warning({required String title, required String message}) {
    toastification.show(
      context: context,
      type: ToastificationType.warning,
      title: Text(title),
      style: style,
      autoCloseDuration: autoCloseDuration,
      alignment: position,
      description: Text(message),
    );
  }

  void error({required String title, required String message}) {
    toastification.show(
      context: context,
      style: style,
      alignment: position,
      autoCloseDuration: autoCloseDuration,
      type: ToastificationType.error,
      title: Text(title),
      description: Text(message),
    );
  }
}

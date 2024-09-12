import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hitspot/constants/constants.dart';

class HSAdaptiveDialog extends StatelessWidget {
  const HSAdaptiveDialog({
    super.key,
    required this.title,
    required this.content,
  });

  final String title, content;

  @override
  Widget build(BuildContext context) {
    return AlertDialog.adaptive(
      title: Text(title),
      content: Text(content),
      actionsAlignment: MainAxisAlignment.spaceAround,
      actions: <Widget>[
        _DialogAction(text: "Cancel", onPressed: () => navi.pop(false)),
        _DialogAction(text: "Delete", onPressed: () => navi.pop(true)),
      ],
    );
  }
}

class _DialogAction extends StatelessWidget {
  const _DialogAction({required this.text, required this.onPressed});

  final String text;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final isAndroid = Platform.isAndroid;
    if (isAndroid) {
      return TextButton(
        onPressed: onPressed,
        child: Text(text),
      );
    } else {
      return CupertinoDialogAction(
        onPressed: onPressed,
        child: Text(text),
      );
    }
  }
}

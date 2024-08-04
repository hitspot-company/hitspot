import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hitspot/constants/constants.dart';

class HSSpotDeleteDialog extends StatelessWidget {
  const HSSpotDeleteDialog({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog.adaptive(
      title: const Text('Delete Spot'),
      content: const Text("This spot will be deleted permanently."),
      actionsAlignment: MainAxisAlignment.spaceAround,
      actions: <Widget>[
        _DialogAction(text: "Cancel", onPressed: () => navi.pop(false)),
        _DialogAction(text: "Delete", onPressed: () => navi.pop(true)),
      ],
    );
  }
}

class _DialogAction extends StatelessWidget {
  const _DialogAction({super.key, required this.text, required this.onPressed});

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

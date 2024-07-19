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
      content: const Text.rich(
        TextSpan(
          text: 'Destructive Action. ',
          style: TextStyle(fontWeight: FontWeight.bold),
          children: [
            TextSpan(
                text: "This spot will be deleted permanently.",
                style: TextStyle(fontWeight: FontWeight.normal))
          ],
        ),
      ),
      actions: <Widget>[
        CupertinoDialogAction(
          onPressed: () => navi.pop(false),
          child: const Text('Cancel'),
        ),
        CupertinoDialogAction(
          onPressed: () => navi.pop(true),
          child: const Text('OK'),
        ),
      ],
    );
  }
}

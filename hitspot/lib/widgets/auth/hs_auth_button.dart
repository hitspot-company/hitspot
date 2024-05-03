import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hitspot/app/hs_app.dart';
import 'package:hitspot/widgets/hs_loading_indicator.dart';

class HSAuthButton extends StatelessWidget {
  const HSAuthButton(
      {super.key,
      required this.buttonText,
      required this.loading,
      required this.valid,
      required this.callback});
  final String buttonText;
  final bool loading;
  final bool valid;
  final VoidCallback callback;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.maxFinite,
      child: CupertinoButton(
        color: HSApp.instance.theme.mainColor,
        onPressed: callback,
        child: loading
            ? const HSLoadingIndicator(
                color: Colors.white,
                size: 24.0,
              )
            : Text(buttonText),
      ),
    );
  }
}

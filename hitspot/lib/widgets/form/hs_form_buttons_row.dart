import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hitspot/widgets/form/hs_form_button.dart';

class HSFormButtonsRow extends StatelessWidget {
  const HSFormButtonsRow({super.key, this.left, required this.right});

  final HSFormButton? left;
  final Widget right;

  @override
  Widget build(BuildContext context) {
    if (left != null) {
      return Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(child: left!),
          const Gap(16.0),
          Expanded(child: right),
        ],
      );
    }
    return Align(
      alignment: Alignment.centerRight,
      child: right,
    );
  }
}

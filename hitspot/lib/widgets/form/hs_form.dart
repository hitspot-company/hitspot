import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/utils/theme/hs_theme.dart';
import 'package:hitspot/widgets/hs_button.dart';

enum HSFormHeadlineType { display, normal, small }

class HSFormCaption extends StatelessWidget {
  const HSFormCaption({super.key, required this.text, this.color});

  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: textTheme.bodyLarge!.hintify.copyWith(color: color));
  }
}

class HSFormHeadline extends StatelessWidget {
  const HSFormHeadline(
      {super.key,
      required this.text,
      this.headlineType = HSFormHeadlineType.small});

  final HSFormHeadlineType headlineType;
  final String text;

  @override
  Widget build(BuildContext context) {
    late final TextStyle? textStyle;
    switch (headlineType) {
      case HSFormHeadlineType.display:
        textStyle = textTheme.headlineLarge;
      case HSFormHeadlineType.normal:
        textStyle = textTheme.headlineMedium;
      case HSFormHeadlineType.small:
        textStyle = textTheme.headlineSmall;
    }
    return Text(text, style: textStyle);
  }
}

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

class HSFormButton extends StatelessWidget {
  const HSFormButton({super.key, this.icon, required this.child, this.onPressed});

  final Icon? icon;
  final Widget child;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    if (icon != null) {
      return HSButton.icon(
        label: child,
        onPressed: onPressed,
        icon: icon!,
      );
    }
    return HSButton(
      onPressed: onPressed,
      child: child,
    );
  }
}

class HSFormPageBody extends StatelessWidget {
  const HSFormPageBody(
      {super.key, this.heading, this.caption, required this.children});

  final String? heading;
  final String? caption;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return ListView(shrinkWrap: true, children: [
      if (heading != null) HSFormHeadline(text: heading!),
      if (caption != null) HSFormCaption(text: caption!),
      Column(children: children),
    ]);
  }
}

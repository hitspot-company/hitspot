import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hitspot/constants/constants.dart';

class HSModalBottomSheetItem extends StatelessWidget {
  const HSModalBottomSheetItem({
    super.key,
    this.onTap,
    this.borderRadius = 8.0,
    this.leftPadding = 16.0,
    this.height = 60.0,
    required this.title,
    this.iconData,
    this.imageUrl,
  });

  final VoidCallback? onTap;
  final double borderRadius, leftPadding, height;
  final String title;
  final IconData? iconData;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(borderRadius),
        onTap: onTap ?? () {},
        child: SizedBox(
          height: height,
          width: screenWidth,
          child: Padding(
            padding: EdgeInsets.only(left: leftPadding),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (iconData != null) ...[
                  Icon(iconData),
                  const Gap(16.0),
                ],
                Text(title, style: const TextStyle(fontSize: 16.0)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

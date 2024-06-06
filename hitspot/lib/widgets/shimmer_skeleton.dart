import 'package:flutter/material.dart';
import 'package:hitspot/constants/constants.dart';

class HSShimmerSkeleton extends StatelessWidget {
  const HSShimmerSkeleton(
      {super.key,
      this.height,
      this.width,
      this.child,
      this.borderRadius = 16.0});

  final double? height, width;
  final Widget? child;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: currentTheme.highlightColor,
        borderRadius: BorderRadius.all(
          Radius.circular(borderRadius),
        ),
      ),
      child: child,
    );
  }
}

class HSShimmerCircleSkeleton extends StatelessWidget {
  const HSShimmerCircleSkeleton({super.key, this.size = 24});

  final double? size;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        color: currentTheme.highlightColor,
        shape: BoxShape.circle,
      ),
    );
  }
}

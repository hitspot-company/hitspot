import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class HSShimmer extends StatelessWidget {
  const HSShimmer({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      enabled: true,
      child: child,
    );
  }
}

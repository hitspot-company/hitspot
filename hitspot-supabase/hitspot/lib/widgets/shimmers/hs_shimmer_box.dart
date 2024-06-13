import 'package:flutter/material.dart';
import 'package:hitspot/widgets/hs_shimmer.dart';
import 'package:hitspot/widgets/shimmer_skeleton.dart';

class HSShimmerBox extends StatelessWidget {
  const HSShimmerBox({super.key, required this.width, required this.height});

  final double width, height;

  @override
  Widget build(BuildContext context) {
    return HSShimmer(
      child: HSShimmerSkeleton(
        height: height,
        width: width,
      ),
    );
  }
}

extension HSSliverToBoxExtension on HSShimmerBox {
  Widget get toSliverBox {
    return SliverToBoxAdapter(
      child: this,
    );
  }

  Widget get toExpanded {
    return Expanded(child: this);
  }
}

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hitspot/widgets/hs_shimmer.dart';
import 'package:hitspot/widgets/shimmer_skeleton.dart';

class HSUserProfileStatsChipSkeleton extends StatelessWidget {
  const HSUserProfileStatsChipSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.0),
      child: HSShimmer(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            HSShimmerSkeleton(
              height: 20.0,
            ),
            Gap(4.0),
            HSShimmerSkeleton(
              height: 20.0,
            ),
          ],
        ),
      ),
    );
  }
}

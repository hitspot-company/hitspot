import 'package:flutter/widgets.dart';
import 'package:hitspot/widgets/hs_shimmer.dart';
import 'package:hitspot/widgets/shimmer_skeleton.dart';

class HSUserProfileUserDataAppBarSkeleton extends StatelessWidget {
  const HSUserProfileUserDataAppBarSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const HSShimmer(
      child: HSShimmerSkeleton(
        height: 100,
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: HSShimmerSkeleton(
                  borderRadius: 4.0,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: HSShimmerSkeleton(
                  borderRadius: 4.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

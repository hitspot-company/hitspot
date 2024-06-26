import 'package:flutter/material.dart';
import 'package:hitspot/widgets/shimmers/hs_shimmer_box.dart';

class HSShimmerGridBuilder extends StatelessWidget {
  const HSShimmerGridBuilder({
    super.key,
    this.isSliver = false,
    this.crossAxisCount = 3,
    this.mainAxisSpacing = 8.0,
    this.crossAxisSpacing = 8.0,
    this.itemCount = 12,
  });

  final bool isSliver;
  final int crossAxisCount, itemCount;
  final double mainAxisSpacing, crossAxisSpacing;

  @override
  Widget build(BuildContext context) {
    if (isSliver) {
      return SliverGrid.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: crossAxisSpacing,
            mainAxisSpacing: mainAxisSpacing),
        itemCount: itemCount,
        itemBuilder: (BuildContext context, int index) {
          return const HSShimmerBox(width: 10.0, height: 10.0);
        },
      );
    }
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: crossAxisSpacing,
          mainAxisSpacing: mainAxisSpacing),
      itemCount: itemCount,
      itemBuilder: (BuildContext context, int index) {
        return const HSShimmerBox(width: 10.0, height: 10.0);
      },
    );
  }
}

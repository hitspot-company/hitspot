import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/widgets/hs_shimmer.dart';
import 'package:hitspot/widgets/hs_spot_tile.dart';
import 'package:hitspot/widgets/shimmer_skeleton.dart';

class HSSpotsGrid extends StatelessWidget {
  const HSSpotsGrid(
      {super.key,
      this.spots,
      this.loading = false,
      this.emptyMessage,
      this.emptyIcon});

  final List? spots;
  final bool loading;
  final String? emptyMessage;
  final Icon? emptyIcon;

  factory HSSpotsGrid.loading() {
    return const HSSpotsGrid(loading: true);
  }

  factory HSSpotsGrid.ready({required List spots}) {
    return HSSpotsGrid(
      spots: spots,
      emptyMessage: "THERE ARE NO SPOTS HERE",
      emptyIcon: const Icon(
        FontAwesomeIcons.mapLocation,
        size: 80.0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      const int childCount = 8;
      return SliverMasonryGrid.count(
        crossAxisCount: 2,
        mainAxisSpacing: 8.0,
        crossAxisSpacing: 8.0,
        childCount: childCount,
        itemBuilder: (context, index) => HSShimmer(
          child: HSShimmerSkeleton(
            height: (index % 3 + 2) * 100,
          ),
        ),
      );
    } else if (spots?.isEmpty ?? true) {
      assert(!(spots == null && (emptyMessage == null || emptyIcon == null)),
          "If spots are null the empty message and icon must be provided.");
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            emptyIcon!,
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Text(
                emptyMessage!,
                style: textTheme.headlineLarge,
              ),
            ),
          ],
        ),
      );
    }
    return SliverMasonryGrid.count(
      crossAxisCount: 2,
      mainAxisSpacing: 8.0,
      crossAxisSpacing: 8.0,
      childCount: spots!.length,
      itemBuilder: (context, index) {
        return HSSpotTile(
          index: index,
          extent: (index % 3 + 2) * 100,
        );
      },
    );
  }
}

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
      this.emptyIcon,
      required this.isSliver});

  final List? spots;
  final bool loading;
  final String? emptyMessage;
  final Icon? emptyIcon;
  final bool isSliver;

  factory HSSpotsGrid.loading({bool isSliver = false}) {
    return HSSpotsGrid(loading: true, isSliver: isSliver);
  }

  factory HSSpotsGrid.ready({required List? spots, bool isSliver = false}) {
    return HSSpotsGrid(
      spots: spots,
      isSliver: isSliver,
      emptyMessage: "THERE ARE NO SPOTS HERE",
      emptyIcon: const Icon(
        FontAwesomeIcons.mapLocation,
        size: 64.0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      const int childCount = 8;
      if (isSliver) {
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
      }
      return MasonryGridView.count(
        crossAxisCount: 2,
        mainAxisSpacing: 8.0,
        crossAxisSpacing: 8.0,
        itemCount: childCount,
        itemBuilder: (context, index) => HSShimmer(
          child: HSShimmerSkeleton(
            height: (index % 3 + 2) * 100,
          ),
        ),
      );
    } else if (spots?.isEmpty ?? true) {
      assert(!(spots == null && (emptyMessage == null || emptyIcon == null)),
          "If spots are null the empty message and icon must be provided.");

      if (isSliver) {
        return SliverToBoxAdapter(
          child: _EmptyMessage(emptyIcon!, emptyMessage!),
        );
      }
      return _EmptyMessage(emptyIcon!, emptyMessage!);
    }
    if (isSliver) {
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
    return MasonryGridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 8.0,
      crossAxisSpacing: 8.0,
      itemCount: spots!.length,
      itemBuilder: (context, index) {
        return HSSpotTile(
          index: index,
          extent: (index % 3 + 2) * 100,
        );
      },
    );
  }
}

class _EmptyMessage extends StatelessWidget {
  const _EmptyMessage(this.emptyIcon, this.emptyMessage);
  final Icon emptyIcon;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          emptyIcon,
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Text(
              emptyMessage,
              style: textTheme.headlineSmall!
                  .copyWith(fontWeight: FontWeight.normal),
            ),
          ),
        ],
      ),
    );
  }
}

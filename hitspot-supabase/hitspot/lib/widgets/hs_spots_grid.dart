import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/widgets/hs_shimmer.dart';
import 'package:hitspot/widgets/hs_spot_tile.dart';
import 'package:hitspot/widgets/shimmer_skeleton.dart';
import 'package:hs_database_repository/hs_database_repository.dart';
import 'package:hs_debug_logger/hs_debug_logger.dart';

class HSSpotsGrid extends StatelessWidget {
  const HSSpotsGrid(
      {super.key,
      this.spots,
      this.loading = false,
      this.emptyMessage,
      this.emptyIcon,
      this.heightFactor = 60.0,
      required this.isSliver,
      this.crossAxisCount = 2,
      this.mainAxisSpacing = 8.0,
      this.fixedHeight = 60.0,
      this.crossAxisSpacing = 8.0});

  final List<HSSpot>? spots;
  final bool loading;
  final String? emptyMessage;
  final Icon? emptyIcon;
  final bool isSliver;
  final double heightFactor;
  final int crossAxisCount;
  final double mainAxisSpacing, crossAxisSpacing, fixedHeight;

  factory HSSpotsGrid.loading({bool isSliver = false}) {
    return HSSpotsGrid(loading: true, isSliver: isSliver);
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      const int childCount = 8;
      if (isSliver) {
        return SliverMasonryGrid.count(
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: mainAxisSpacing,
          crossAxisSpacing: crossAxisSpacing,
          childCount: childCount,
          itemBuilder: (context, index) => HSShimmer(
            child: HSShimmerSkeleton(
              height: (index % 3 + 2) * heightFactor + fixedHeight,
            ),
          ),
        );
      }
      return MasonryGridView.count(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: mainAxisSpacing,
        crossAxisSpacing: crossAxisSpacing,
        itemCount: childCount,
        itemBuilder: (context, index) => HSShimmer(
          child: HSShimmerSkeleton(
            height: (index % 3 + 2) * heightFactor + fixedHeight,
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
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: mainAxisSpacing,
        crossAxisSpacing: crossAxisSpacing,
        childCount: spots!.length,
        itemBuilder: (context, index) {
          return HSSpotTile(
            index: index,
            spot: spots?[index],
            extent: (index % 3 + 2) * heightFactor + fixedHeight,
          );
        },
      );
    }
    return MasonryGridView.count(
      crossAxisCount: crossAxisCount,
      mainAxisSpacing: mainAxisSpacing,
      crossAxisSpacing: crossAxisSpacing,
      itemCount: spots!.length,
      itemBuilder: (context, index) {
        return HSSpotTile(
          index: index,
          spot: spots?[index],
          extent: (index % 3 + 2) * heightFactor + fixedHeight,
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

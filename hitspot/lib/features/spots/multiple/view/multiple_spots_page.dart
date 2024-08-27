import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/features/search/view/main_search_delegate.dart';
import 'package:hitspot/features/spots/multiple/cubit/hs_multiple_spots_cubit.dart';
import 'package:hitspot/widgets/hs_appbar.dart';
import 'package:hitspot/widgets/hs_loading_indicator.dart';
import 'package:hitspot/widgets/hs_scaffold.dart';
import 'package:hitspot/widgets/spot/hs_animated_spot_tile.dart';
import 'package:hs_database_repository/hs_database_repository.dart';

class MultipleSpotsPage extends StatelessWidget {
  const MultipleSpotsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = BlocProvider.of<HsMultipleSpotsCubit>(context);
    return HSScaffold(
      appBar: HSAppBar(
        titleText: cubit.pageTitle,
        enableDefaultBackButton: true,
      ),
      body: BlocSelector<HsMultipleSpotsCubit, HsMultipleSpotsState,
          HsMultipleSpotsStatus>(
        selector: (state) => state.status,
        builder: (context, state) {
          if (state == HsMultipleSpotsStatus.loading) {
            return const HSLoadingIndicator();
          } else if (state == HsMultipleSpotsStatus.error) {
            return const Center(child: Text('Failed to load spots.'));
          }
          return Padding(
            padding: const EdgeInsets.only(bottom: 32.0),
            child: PagedGridView<int, dynamic>(
              pagingController: cubit.pagingController,
              builderDelegate: PagedChildBuilderDelegate<dynamic>(
                newPageProgressIndicatorBuilder: (context) =>
                    const HSLoadingIndicator(),
                firstPageProgressIndicatorBuilder: (context) =>
                    const HSLoadingIndicator(),
                itemBuilder: (context, item, index) {
                  if (cubit.hitsPage.type == HSHitsPageType.spots) {
                    return SizedBox(
                      height: 100,
                      width: screenWidth,
                      child:
                          AnimatedSpotTile(spot: item as HSSpot, index: index),
                    );
                  }
                  return SizedBox(
                    height: 100,
                    width: screenWidth,
                    child: AnimatedBoardTile(board: item, index: index),
                  );
                },
              ),
              gridDelegate: SliverQuiltedGridDelegate(
                crossAxisCount: 2,
                mainAxisSpacing: 8.0,
                crossAxisSpacing: 8.0,
                repeatPattern: QuiltedGridRepeatPattern.inverted,
                pattern: [
                  const QuiltedGridTile(2, 2),
                  const QuiltedGridTile(1, 1),
                  const QuiltedGridTile(1, 1),
                  const QuiltedGridTile(1, 2),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:gap/gap.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/features/search/view/main_search_delegate.dart';
import 'package:hitspot/features/spots/multiple/cubit/hs_multiple_spots_cubit.dart';
import 'package:hitspot/widgets/hs_appbar.dart';
import 'package:hitspot/widgets/hs_loading_indicator.dart';
import 'package:hitspot/widgets/hs_scaffold.dart';
import 'package:hitspot/widgets/shimmers/hs_shimmer_box.dart';
import 'package:hitspot/widgets/spot/hs_animated_spot_tile.dart';
import 'package:hitspot/widgets/user/hs_user_widgets.dart';
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
                    final spot = item as HSSpot;
                    return SizedBox(
                      height: 100,
                      width: screenWidth,
                      child: CachedNetworkImage(
                        imageUrl: spot.getThumbnail,
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                        fit: BoxFit.cover,
                        placeholder: (context, url) =>
                            const HSShimmerBox(width: 100, height: 100),
                        imageBuilder: (context, imageProvider) =>
                            GestureDetector(
                          onTap: () => navi.toSpot(sid: spot.sid!),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20.0),
                                  image: DecorationImage(
                                    image: imageProvider,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.black.withOpacity(0.0),
                                      Colors.black.withOpacity(.99),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                              ),
                              Align(
                                alignment: Alignment.bottomLeft,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    HSUserTileUp(
                                      tileColor: Theme.of(context)
                                          .scaffoldBackgroundColor,
                                      height: 80.0,
                                      textColor: Colors.white,
                                      width: screenWidth,
                                      showLeading: false,
                                      user: spot.author!,
                                      title: spot.title!,
                                      subtitle: "by @${spot.author!.username}",
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
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

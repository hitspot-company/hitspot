import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/features/boards/single/map/cubit/hs_single_board_map_cubit.dart';
import 'package:hitspot/widgets/hs_appbar.dart';
import 'package:hitspot/widgets/hs_loading_indicator.dart';
import 'package:hitspot/widgets/hs_scaffold.dart';
import 'package:hitspot/widgets/map/hs_google_map.dart';
import 'package:hitspot/widgets/spot/hs_spot_card.dart';

class SingleBoardMapPage extends StatelessWidget {
  const SingleBoardMapPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = BlocProvider.of<HSSingleBoardMapCubit>(context);
    const builderSidePadding = 16.0;
    final builderWidth = screenWidth - (builderSidePadding * 2);
    return HSScaffold(
      sidePadding: 0.0,
      appBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: HSAppBar(
          titleText: cubit.board.title,
          enableDefaultBackButton: true,
          right: IconButton(
              onPressed: cubit.resetCamera,
              icon: const Icon(FontAwesomeIcons.magnifyingGlassMinus)),
        ),
      ),
      body: BlocSelector<HSSingleBoardMapCubit, HSSingleBoardMapState,
          HSSingleBoardMapStatus>(
        selector: (state) => state.status,
        builder: (context, status) {
          if (status == HSSingleBoardMapStatus.loading) {
            return const HSLoadingIndicator();
          } else if (status == HSSingleBoardMapStatus.error) {
            return const Center(child: Text('Error loading map'));
          }
          return BlocBuilder<HSSingleBoardMapCubit, HSSingleBoardMapState>(
            buildWhen: (previous, current) =>
                previous.markers != current.markers,
            builder: (context, state) {
              final markers = state.markers;
              return Stack(
                fit: StackFit.expand,
                children: [
                  HSGoogleMap(
                    onMapCreated: cubit.onMapCreated,
                    markers: markers,
                    myLocationEnabled: true,
                  ),
                  Positioned(
                    bottom: 24.0,
                    left: builderSidePadding,
                    right: builderSidePadding,
                    child: SizedBox(
                      width: builderWidth,
                      height: 180.0,
                      child: PageView.builder(
                        controller: cubit.pageController,
                        scrollDirection: Axis.horizontal,
                        itemCount: state.spots.length,
                        itemBuilder: (BuildContext context, int index) {
                          return SizedBox(
                            width: builderWidth,
                            height: 180.0,
                            child: HSSpotCard(
                                spot: state.spots[index], index: index),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

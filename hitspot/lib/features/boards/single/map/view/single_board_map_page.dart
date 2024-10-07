import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/features/boards/single/map/cubit/hs_single_board_map_cubit.dart';
import 'package:hitspot/features/theme/bloc/hs_theme_bloc.dart';
import 'package:hitspot/widgets/hs_appbar.dart';
import 'package:hitspot/widgets/hs_loading_indicator.dart';
import 'package:hitspot/widgets/hs_scaffold.dart';
import 'package:hitspot/widgets/spot/hs_spot_card.dart';
import 'package:hitspot/wrappers/map/cubit/hs_map_wrapper_cubit.dart';
import 'package:hs_location_repository/hs_location_repository.dart';

class SingleBoardMapPage extends StatelessWidget {
  const SingleBoardMapPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = BlocProvider.of<HSSingleBoardMapCubit>(context);
    const builderSidePadding = 16.0;
    final builderWidth = screenWidth - (builderSidePadding * 2);
    return PopScope(
      canPop: false,
      child: HSScaffold(
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
            final spots = cubit.mapWrapper.state.visibleSpots;
            return Stack(
              children: [
                BlocBuilder<HSMapWrapperCubit, HSMapWrapperState>(
                  buildWhen: (previous, current) =>
                      previous.markers != current.markers ||
                      previous.markerLevel != current.markerLevel,
                  builder: (context, state) {
                    return GoogleMap(
                        style: BlocProvider.of<HSThemeBloc>(context)
                            .state
                            .mapStyle,
                        markers: state.markers,
                        onMapCreated: cubit.mapWrapper.onMapCreated,
                        onCameraIdle: cubit.mapWrapper.onCameraIdle,
                        onCameraMove: cubit.mapWrapper.onCameraMove,
                        initialCameraPosition:
                            const CameraPosition(target: LatLng(0.0, 0.0)));
                  },
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
                      itemCount: spots.length,
                      itemBuilder: (BuildContext context, int index) {
                        return SizedBox(
                          width: builderWidth,
                          height: 180.0,
                          child: HSSpotCard(
                            spot: spots[index],
                            index: index,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

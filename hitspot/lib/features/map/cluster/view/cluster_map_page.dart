import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/features/map/cluster/cubit/hs_cluster_map_cubit.dart';
import 'package:hitspot/features/map/search/cubit/hs_map_search_cubit.dart';
import 'package:hitspot/features/map/search/view/map_search_delegate.dart';
import 'package:hitspot/widgets/hs_image.dart';
import 'package:hitspot/widgets/hs_loading_indicator.dart';
import 'package:hitspot/widgets/hs_scaffold.dart';
import 'package:hitspot/widgets/hs_spot_tile.dart';
import 'package:hitspot/widgets/hs_textfield.dart';
import 'package:hitspot/widgets/spot/hs_animated_spot_tile.dart';
import 'package:hitspot/widgets/spot/hs_better_spot_tile.dart';
import 'package:hs_location_repository/hs_location_repository.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ClusterMapPage extends StatelessWidget {
  const ClusterMapPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = BlocProvider.of<HsClusterMapCubit>(context);
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        BlocSelector<HsClusterMapCubit, HsClusterMapState, HSClusterMapStatus>(
          selector: (state) => state.status,
          builder: (context, status) {
            if (status == HSClusterMapStatus.loading) {
              return const HSScaffold(body: HSLoadingIndicator());
            }
            return GoogleMap(
              initialCameraPosition: cubit.initialCameraPosition,
              myLocationButtonEnabled: false,
              myLocationEnabled: true,
              onTap: (argument) => cubit.resetSelectedSpot(),
              onMapCreated: (controller) {
                if (!cubit.mapController.isCompleted) {
                  cubit.mapController.complete(controller);
                }
              },
              markers: cubit.state.markers,
              onCameraIdle: cubit.onCameraIdle,
              onCameraMove: cubit.onCameraMoved,
            );
          },
        ),
        Positioned(
          left: 16.0,
          child: SafeArea(
            child: FloatingActionButton(
              onPressed: navi.pop,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              child: backIcon,
            ),
          ),
        ),
        const AnimatedMapOverlay(),
      ],
    );
  }
}

class AnimatedMapOverlay extends StatelessWidget {
  const AnimatedMapOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<HsClusterMapCubit>();
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      bottom: 0.0,
      left: 0.0,
      right: 0.0,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.95, end: 1.0).animate(
                CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                ),
              ),
              child: child,
            ),
          );
        },
        child: Material(
          key: ValueKey<bool>(context
              .select((HsClusterMapCubit cubit) => cubit.state.isSpotSelected)),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20.0),
                topRight: Radius.circular(20.0),
              ),
            ),
            width: screenWidth,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                BlocSelector<HsClusterMapCubit, HsClusterMapState, bool>(
                  selector: (state) => state.isSpotSelected,
                  builder: (context, isSpotSelected) {
                    if (isSpotSelected) {
                      final spot =
                          context.read<HsClusterMapCubit>().state.selectedSpot;
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: HSSpotTile(
                          index: 0,
                          spot: spot,
                          extent: 120.0,
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 8.0),
                  child: HSTextField.filled(
                    hintText: 'Search...',
                    suffixIcon: const Icon(Icons.search),
                    readOnly: true,
                    onTap: () => showSearch(
                      context: context,
                      delegate: MapSearchDelegate(HSMapSearchCubit()),
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Divider(thickness: .4),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).padding.bottom + 16.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _MapButton(
                        icon: FontAwesomeIcons.map,
                        backgroundColor: Theme.of(context).primaryColor,
                        text: 'Map',
                        onPressed: () {},
                      ),
                      _MapButton(
                        icon: FontAwesomeIcons.arrowsUpDownLeftRight,
                        text: 'Nearby',
                        onPressed: () {
                          // Add your onPressed logic here
                        },
                      ),
                      _MapButton(
                        icon: FontAwesomeIcons.filter,
                        text: 'Filter',
                        onPressed: cubit.fetchFilters,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MapButton extends StatelessWidget {
  const _MapButton({
    required this.icon,
    this.backgroundColor,
    required this.text,
    this.onPressed,
  });

  final IconData icon;
  final Color? backgroundColor;
  final String text;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton.filled(
          style: IconButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            backgroundColor:
                backgroundColor ?? appTheme.mainColor.withOpacity(0.4),
          ),
          onPressed: onPressed,
          icon: Icon(icon),
        ),
        Text(text),
      ],
    );
  }
}

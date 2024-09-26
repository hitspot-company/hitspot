import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/features/map/cluster/cubit/hs_cluster_map_cubit.dart';
import 'package:hitspot/features/map/search/cubit/hs_map_search_cubit.dart';
import 'package:hitspot/features/map/search/view/map_search_delegate.dart';
import 'package:hitspot/widgets/hs_loading_indicator.dart';
import 'package:hitspot/widgets/hs_scaffold.dart';
import 'package:hitspot/widgets/hs_textfield.dart';
import 'package:hs_location_repository/hs_location_repository.dart';

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
              onMapCreated: (controller) {
                if (!cubit.mapController.isCompleted) {
                  cubit.mapController.complete(controller);
                }
              },
              markers: cubit.state.markers,
              onCameraIdle: cubit.onCameraIdle,
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
        Positioned(
          bottom: 0.0,
          child: Material(
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
                children: [
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
                    child: Divider(
                      thickness: .4,
                    ),
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
                          backgroundColor: appTheme.mainColor,
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
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
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

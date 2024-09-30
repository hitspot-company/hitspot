import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/features/map/cluster/cubit/hs_cluster_map_cubit.dart';
import 'package:hitspot/features/theme/bloc/hs_theme_bloc.dart';
import 'package:hitspot/utils/theme/hs_theme.dart';
import 'package:hitspot/widgets/hs_button.dart';
import 'package:hitspot/widgets/hs_image.dart';
import 'package:hitspot/widgets/hs_loading_indicator.dart';
import 'package:hitspot/widgets/hs_scaffold.dart';
import 'package:hitspot/widgets/hs_spot_tile.dart';
import 'package:hitspot/widgets/hs_user_tile.dart';
import 'package:hs_database_repository/hs_database_repository.dart';
import 'package:hs_debug_logger/hs_debug_logger.dart';
import 'package:hs_location_repository/hs_location_repository.dart';

part 'cluster_map_widgets.dart';

class ClusterMapPage extends StatelessWidget {
  const ClusterMapPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = BlocProvider.of<HsClusterMapCubit>(context);
    return Material(
      color: Colors.transparent,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          BlocSelector<HsClusterMapCubit, HsClusterMapState,
              HSClusterMapStatus>(
            selector: (state) => state.status,
            builder: (context, status) {
              if (status == HSClusterMapStatus.loading) {
                return const HSScaffold(body: HSLoadingIndicator());
              }
              return GoogleMap(
                style: context.read<HSThemeBloc>().state.mapStyle,
                initialCameraPosition: cubit.initialCameraPosition,
                myLocationButtonEnabled: false,
                myLocationEnabled: true,
                onTap: (argument) => cubit.closeSheet(),
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
                heroTag: 'back',
                onPressed: navi.pop,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                child: backIcon,
              ),
            ),
          ),
          Positioned(
            right: 16.0,
            child: SafeArea(
              child: FloatingActionButton(
                heroTag: 'myLocation',
                onPressed: cubit.animateToCurrentLocation,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                child: const Icon(Icons.my_location),
              ),
            ),
          ),
          const MapBottomSheet(),
        ],
      ),
    );
  }
}

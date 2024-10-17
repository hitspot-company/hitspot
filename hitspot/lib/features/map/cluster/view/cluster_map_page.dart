import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/features/map/cluster/cubit/hs_cluster_map_cubit.dart';
import 'package:hitspot/features/theme/bloc/hs_theme_bloc.dart';
import 'package:hitspot/utils/theme/hs_theme.dart';
import 'package:hitspot/widgets/hs_button.dart';
import 'package:hitspot/widgets/hs_image.dart';
import 'package:hitspot/widgets/hs_loading_indicator.dart';
import 'package:hitspot/widgets/hs_scaffold.dart';
import 'package:hitspot/widgets/hs_spot_tile.dart';
import 'package:hitspot/widgets/hs_textfield.dart';
import 'package:hitspot/widgets/user/hs_user_widgets.dart';
import 'package:hitspot/wrappers/map/cubit/hs_map_wrapper_cubit.dart';
import 'package:hs_database_repository/hs_database_repository.dart';
import 'package:hs_location_repository/hs_location_repository.dart';
import 'package:rename/commands/rename_command_runner.dart';

part 'cluster_map_widgets.dart';

class ClusterMapPage extends StatelessWidget {
  const ClusterMapPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = BlocProvider.of<HsClusterMapCubit>(context);
    final mapWrapperCubit = cubit.mapWrapper;
    return Material(
      color: Colors.transparent,
      child: BlocSelector<HsClusterMapCubit, HsClusterMapState,
          HSClusterMapStatus>(
        selector: (state) => state.status,
        builder: (context, status) {
          if (status == HSClusterMapStatus.loading) {
            return const HSScaffold(body: HSLoadingIndicator());
          }
          return Stack(
            fit: StackFit.expand,
            children: <Widget>[
              BlocBuilder<HSMapWrapperCubit, HSMapWrapperState>(
                buildWhen: (previous, current) =>
                    previous.markers != current.markers ||
                    previous.markerLevel != current.markerLevel,
                builder: (context, state) {
                  return GoogleMap(
                    fortyFiveDegreeImageryEnabled: true,
                    style: context.read<HSThemeBloc>().state.mapStyle,
                    initialCameraPosition:
                        mapWrapperCubit.getInitialCameraPosition,
                    myLocationButtonEnabled: false,
                    myLocationEnabled: true,
                    mapType: state.mapType,
                    onTap: (argument) => cubit.closeSheet(),
                    onMapCreated: mapWrapperCubit.onMapCreated,
                    markers: state.markers,
                    onCameraIdle: mapWrapperCubit.onCameraIdle,
                    onCameraMove: mapWrapperCubit.onCameraMove,
                  );
                },
              ),
              // BlocSelector<HsClusterMapCubit, HsClusterMapState,
              //     HSClusterMapStatus>(
              //   selector: (state) => state.status,
              //   builder: (context, status) {
              //     if (status == HSClusterMapStatus.loading) {
              //       return const HSScaffold(body: HSLoadingIndicator());
              //     }
              //     return GoogleMap(
              //       fortyFiveDegreeImageryEnabled: true,
              //       style: context.read<HSThemeBloc>().state.mapStyle,
              //       initialCameraPosition: cubit.state.cameraPosition,
              //       myLocationButtonEnabled: false,
              //       myLocationEnabled: true,
              //       mapType: cubit.state.mapType,
              //       onTap: (argument) => cubit.closeSheet(),
              //       onMapCreated: cubit.mapWrapper.onMapCreated,
              //       markers: cubit.state.markers,
              //       onCameraIdle: cubit.onCameraIdle,
              //       onCameraMove: cubit.onCameraMoved,
              //     );
              //   },
              // ),
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
                    heroTag: 'mapType',
                    onPressed: cubit.changeMapType,
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    child: const Icon(Icons.border_all),
                  ),
                ),
              ),
              const MapBottomSheet(),
            ],
          );
        },
      ),
    );
  }
}

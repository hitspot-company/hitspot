import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/features/map/cubit/hs_map_cubit.dart';
import 'package:hitspot/widgets/hs_appbar.dart';
import 'package:hitspot/widgets/hs_scaffold.dart';
import 'package:hitspot/widgets/hs_textfield.dart';
import 'package:hs_location_repository/hs_location_repository.dart';

class MapPage extends StatelessWidget {
  const MapPage({super.key});

  @override
  Widget build(BuildContext context) {
    final mapCubit = BlocProvider.of<HSMapCubit>(context);
    return HSScaffold(
      sidePadding: 0.0,
      topSafe: false,
      bottomSafe: false,
      body: Stack(
        fit: StackFit.expand,
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              zoom: 16.0,
              target: mapCubit.state.cameraPosition!,
            ),
            onMapCreated: mapCubit.onMapCreated,
            myLocationButtonEnabled: false,
            onCameraIdle: mapCubit.onCameraIdle,
          ),
          Positioned(
            top: 0.0,
            child: Container(
              width: screenWidth,
              height: 120,
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: navi.pop,
                    icon: const Icon(
                      FontAwesomeIcons.arrowLeft,
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

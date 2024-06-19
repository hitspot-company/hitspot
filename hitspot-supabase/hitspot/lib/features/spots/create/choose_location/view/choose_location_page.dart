import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_config/flutter_config.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/features/spots/create/choose_location/cubit/hs_choose_location_cubit.dart';
import 'package:hitspot/widgets/hs_scaffold.dart';
import 'package:hitspot/widgets/hs_textfield.dart';
import 'package:hs_debug_logger/hs_debug_logger.dart';
import 'package:hs_location_repository/hs_location_repository.dart';

class ChooseLocationPage extends StatelessWidget {
  const ChooseLocationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final chooseLocationCubit = context.read<HsChooseLocationCubit>();
    return HSScaffold(
      sidePadding: 0.0,
      topSafe: false,
      body: Stack(
        fit: StackFit.expand,
        children: [
          _MapAndSearchBar(),
          const _Pin(),
          Positioned(
            bottom: 0,
            child: BlocBuilder<HsChooseLocationCubit, HsChooseLocationState>(
              buildWhen: (previous, current) =>
                  previous.selectedLocation != current.selectedLocation ||
                  previous.isSearching != current.isSearching,
              builder: (context, state) {
                final String address =
                    state.selectedLocation?.name ?? "Where is your spot?";
                final bool isSearching = state.isSearching;
                final double searchBarHeight =
                    !isSearching ? 180.0 : screenHeight - 80;
                return AnimatedContainer(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    color: currentTheme.scaffoldBackgroundColor,
                  ),
                  width: screenWidth,
                  duration: const Duration(milliseconds: 250),
                  height: searchBarHeight,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: HSTextField.filled(
                          focusNode: chooseLocationCubit.searchNode,
                          hintText: address,
                          controller: chooseLocationCubit.searchController,
                          suffixIcon: const Icon(Icons.location_pin),
                        ),
                      ),
                      if (!isSearching)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            TextButton(
                              onPressed: chooseLocationCubit.backToHome,
                              child: const Text("Cancel"),
                            ),
                            TextButton(
                              onPressed: chooseLocationCubit.submitLocation,
                              child: const Text("Select"),
                            ),
                          ],
                        ),
                      if (isSearching)
                        const Text("Click on one of the predictions below"),
                      if (isSearching)
                        Expanded(
                          child: BlocSelector<HsChooseLocationCubit,
                              HsChooseLocationState, List<HSPrediction>>(
                            selector: (state) => state.predictions,
                            builder: (context, predictions) =>
                                ListView.separated(
                              itemCount: predictions.length,
                              separatorBuilder:
                                  (BuildContext context, int index) {
                                return const SizedBox(
                                  height: 20.0,
                                );
                              },
                              itemBuilder: (BuildContext context, int index) {
                                final HSPrediction prediction =
                                    predictions[index];
                                return ListTile(
                                  title: Text(prediction.description),
                                  onTap: () => chooseLocationCubit
                                      .selectPrediction(prediction),
                                );
                              },
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _MapAndSearchBar extends StatelessWidget {
  _MapAndSearchBar();

  final TextEditingController _searchBarController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final chooseLocationCubit = context.read<HsChooseLocationCubit>();

    return BlocBuilder<HsChooseLocationCubit, HsChooseLocationState>(
      builder: (context, state) {
        Completer<GoogleMapController> mapController =
            chooseLocationCubit.mapController;
        return Stack(
          children: [
            GoogleMap(
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              onMapCreated: (GoogleMapController controller) {
                if (mapController.isCompleted) {
                  mapController = Completer<GoogleMapController>();
                }
                mapController.complete(controller);
              },
              initialCameraPosition: CameraPosition(
                target: state.userLocation.toLatLng,
                zoom: 16.0,
              ),
              onCameraMove: (position) {
                chooseLocationCubit.cameraLocationChanged(
                    location: position.target);
              },
              onCameraIdle: () => chooseLocationCubit.setLocationChanged(
                  location: state.cameraLocation!),
              onTap: (LatLng location) {
                _searchBarController.text = "";
                chooseLocationCubit.searchNode.unfocus();
              },
              mapType: MapType.normal,
            ),
          ],
        );
      },
    );
  }
}

class _Pin extends StatelessWidget {
  const _Pin();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HsChooseLocationCubit, HsChooseLocationState>(
      builder: (context, state) {
        final isIdle = state.cameraLocation == state.selectedLocation;
        return Center(
          child: Padding(
            padding: EdgeInsets.only(bottom: isIdle ? 36.0 : 32.0),
            child: Icon(
              FontAwesomeIcons.mapPin,
              color: appTheme.mainColor,
              size: isIdle ? 28.0 : 36.0,
            ),
          ),
        );
      },
    );
  }
}

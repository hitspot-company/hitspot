import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/features/spots/create/map/cubit/hs_choose_location_cubit.dart';
import 'package:hitspot/widgets/hs_loading_indicator.dart';
import 'package:hitspot/widgets/hs_scaffold.dart';
import 'package:hs_debug_logger/hs_debug_logger.dart';
import 'package:hs_location_repository/hs_location_repository.dart';

import '../../../../../widgets/hs_textfield.dart';

class ChooseLocationPage extends StatelessWidget {
  const ChooseLocationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return HSScaffold(
      resizeToAvoidBottomInset: false,
      sidePadding: 0.0,
      topSafe: false,
      body: Stack(
        fit: StackFit.expand,
        children: [
          _MapAndSearchBar(),
          const _Pin(),
          const _BottomBar(),
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
    final chooseLocationCubit = context.read<HSChooseLocationCubit>();

    return BlocBuilder<HSChooseLocationCubit, HSChooseLocationState>(
      builder: (context, state) {
        Completer<GoogleMapController> mapController =
            chooseLocationCubit.mapController;
        return Stack(
          children: [
            GoogleMap(
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              onMapCreated: (GoogleMapController controller) async {
                if (mapController.isCompleted) {
                  mapController = Completer<GoogleMapController>();
                }
                mapController.complete(controller);
                await app.theme.applyMapDarkStyle(mapController);
              },
              initialCameraPosition: CameraPosition(
                target: state.userLocation.toLatLng,
                zoom: 16.0,
              ),
              onCameraMove: (position) =>
                  chooseLocationCubit.onCameraMovement(position.target),
              onCameraIdle: chooseLocationCubit.onCameraIdle,
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
    return BlocBuilder<HSChooseLocationCubit, HSChooseLocationState>(
      builder: (context, state) {
        final LatLng latlng = LatLng(state.selectedLocation?.latitude ?? 0.0,
            state.selectedLocation?.longitude ?? 0.0);
        final isIdle = state.cameraLocation == latlng;
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

class _BottomBar extends StatelessWidget {
  const _BottomBar({super.key});

  @override
  Widget build(BuildContext context) {
    final chooseLocationCubit = context.read<HSChooseLocationCubit>();
    return Positioned(
      bottom: 0,
      child: BlocBuilder<HSChooseLocationCubit, HSChooseLocationState>(
        buildWhen: (previous, current) =>
            previous.selectedLocation != current.selectedLocation ||
            previous.isSearching != current.isSearching,
        builder: (context, state) {
          final String address =
              state.selectedLocation?.name ?? "Where is your spot?";
          final bool isSearching = state.isSearching;
          final double searchBarHeight =
              !isSearching ? 180.0 : screenHeight - 100.0;
          return AnimatedContainer(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              color: currentTheme.scaffoldBackgroundColor,
            ),
            width: screenWidth,
            curve: Curves.easeIn,
            duration: const Duration(milliseconds: 250),
            height: searchBarHeight,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 16.0),
                  child: HSTextField.filled(
                    focusNode: chooseLocationCubit.searchNode,
                    hintText: address,
                    controller: chooseLocationCubit.searchController,
                    suffixIcon: const Icon(Icons.search),
                  ),
                ),
                if (!isSearching)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: chooseLocationCubit.cancel,
                          child: const Text("Cancel"),
                        ),
                        ElevatedButton(
                          onPressed: chooseLocationCubit.submit,
                          child: const Text("Select"),
                        ),
                      ],
                    ),
                  ),
                if (isSearching)
                  Expanded(
                    child: BlocBuilder<HSChooseLocationCubit,
                        HSChooseLocationState>(
                      buildWhen: (previous, current) =>
                          previous.predictions != current.predictions ||
                          previous.status != current.status,
                      builder: (context, state) {
                        final List<HSPrediction> predictions =
                            state.predictions;
                        final isFetching = state.status ==
                            HSChooseLocationStatus.fetchingPredictions;
                        if (isFetching) {
                          return const Align(
                            alignment: Alignment.topCenter,
                            child: Padding(
                              padding: EdgeInsets.only(top: 16.0),
                              child: HSLoadingIndicator(enableCenter: false),
                            ),
                          );
                        }
                        if (predictions.isEmpty) {
                          return Padding(
                              padding: const EdgeInsets.only(top: 16.0),
                              child: Text(chooseLocationCubit.query.isEmpty
                                  ? "Search for a place..."
                                  : "No predictions found"));
                        }
                        return ListView.separated(
                          itemCount: predictions.length,
                          separatorBuilder: (BuildContext context, int index) {
                            return const SizedBox(
                              height: 10.0,
                            );
                          },
                          itemBuilder: (BuildContext context, int index) {
                            final HSPrediction prediction = predictions[index];
                            return ListTile(
                              leading: const Icon(Icons.place),
                              title: AutoSizeText(prediction.description,
                                  maxLines: 1,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600)),
                              onTap: () => chooseLocationCubit
                                  .onPredictionSelected(prediction),
                            );
                          },
                        );
                      },
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

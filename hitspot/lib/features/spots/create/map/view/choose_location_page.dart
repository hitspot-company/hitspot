import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/features/spots/create/map/cubit/hs_choose_location_cubit.dart';
import 'package:hitspot/widgets/hs_scaffold.dart';
import 'package:hitspot/widgets/hs_textfield.dart';
import 'package:hitspot/widgets/map/hs_google_map.dart';
import 'package:hs_location_repository/hs_location_repository.dart';

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
          const _AnimatedPin(),
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
        return Stack(
          children: [
            HSGoogleMap(
              myLocationButtonEnabled: true,
              myLocationButtonCallback: chooseLocationCubit.resetPosition,
              onMapCreated: chooseLocationCubit.onMapCreated,
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
            ),
          ],
        );
      },
    );
  }
}

class _AnimatedPin extends StatelessWidget {
  const _AnimatedPin();

  @override
  Widget build(BuildContext context) {
    final cubit = BlocProvider.of<HSChooseLocationCubit>(context);
    return BlocBuilder<HSChooseLocationCubit, HSChooseLocationState>(
      builder: (context, state) {
        final LatLng latlng = LatLng(state.selectedLocation?.latitude ?? 0.0,
            state.selectedLocation?.longitude ?? 0.0);
        final isIdle = state.cameraLocation == latlng;

        return Center(
          child: Icon(
            FontAwesomeIcons.mapPin,
            color: appTheme.mainColor,
            size: 32.0,
          )
              .animate()
              .scale(
                begin: const Offset(1, 1),
                end: const Offset(1.2, 1.2),
                duration: const Duration(milliseconds: 300),
              )
              .then()
              .moveY(
                begin: 0,
                end: -10,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              )
              .animate(target: isIdle ? 1.0 : 0.0)
              .scaleXY(
                begin: 1.0,
                end: 0.9,
                duration: const Duration(milliseconds: 150),
              )
              .then()
              .moveY(
                begin: 0,
                end: 5,
                duration: const Duration(milliseconds: 150),
                curve: Curves.bounceOut,
              ),
        );
      },
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar();

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
          final bool canSubmit = state.selectedLocation != null;
          return Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              color: currentTheme.scaffoldBackgroundColor,
            ),
            width: screenWidth,
            height: searchBarHeight,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 16.0),
                  child: HSTextField.filled(
                    hintText: address,
                    suffixIcon: const Icon(Icons.search),
                    readOnly: true,
                    onTap: () => chooseLocationCubit.searchLocation(context),
                  ),
                ),
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
                        onPressed:
                            canSubmit ? chooseLocationCubit.submit : null,
                        child: const Text("Select"),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
              .animate(target: isSearching ? 1 : 0)
              // .slideY(
              //   duration: const Duration(milliseconds: 300),
              //   curve: Curves.easeInOut,
              //   begin: 180.0,
              //   end: screenHeight - 100.0,
              // )
              .slideY(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                begin: 0,
                end: -0.5,
              );
        },
      ),
    );
  }
}

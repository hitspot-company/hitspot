import 'package:flutter/material.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/features/spots/single/cubit/hs_single_spot_cubit.dart';
import 'package:hs_location_repository/hs_location_repository.dart';
import 'package:map_launcher/map_launcher.dart' as ml;

void showMapsChoiceBottomSheet(
    {required BuildContext context,
    required LatLng coords,
    required String description,
    required String title}) {
  showModalBottomSheet(
    context: context,
    builder: (context) => Padding(
      padding:
          const EdgeInsets.only(top: 8.0, bottom: 18.0, left: 8.0, right: 8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
              title: const Text("Open in Google Maps"),
              onTap: () async {
                if (await app.locationRepository.launchMaps(
                  mapType: ml.MapType.google,
                  coords: coords,
                  description: description,
                  title: title,
                )) {
                  app.navigation.pop();
                }
              }),
          ListTile(
              title: const Text("Open in Apple Maps"),
              onTap: () async {
                if (await app.locationRepository.launchMaps(
                  mapType: ml.MapType.apple,
                  coords: coords,
                  description: description,
                  title: title,
                )) {
                  app.navigation.pop();
                }
              }),
        ],
      ),
    ),
  );
}

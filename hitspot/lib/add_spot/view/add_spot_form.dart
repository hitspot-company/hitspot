import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hitspot/add_spot/cubit/hs_add_spot_cubit_cubit.dart';
import 'package:hitspot/app/hs_app.dart';
import 'package:hitspot/authentication/bloc/hs_authentication_bloc.dart';
import 'package:hitspot/utils/theme/hs_theme.dart';
import 'package:hitspot/widgets/hs_searchbar.dart';
import 'package:hitspot/widgets/hs_textfield.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:location/location.dart';
import 'package:path/path.dart';
import 'package:search_map_location/search_map_location.dart';
import 'package:search_map_location/utils/google_search/place.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';

class AddSpotForm extends StatelessWidget {
  AddSpotForm({super.key});

  @override
  Widget build(BuildContext context) {
    final hsApp = HSApp.instance;
    final hsNavigation = hsApp.navigation;
    final addSpotCubit = context.read<HSAddSpotCubit>();

    return BlocBuilder<HSAddSpotCubit, HSAddSpotCubitState>(
        builder: (context, state) {
      switch (state.step) {
        case 0:
          return _LocationSelection();
        default:
          return Container();
      }
    });
  }
}

class _LocationSelection extends StatelessWidget {
  _LocationSelection({super.key});

  @override
  Widget build(BuildContext context) {
    final addSpotCubit = context.read<HSAddSpotCubit>();

    final TextEditingController _searchBarController = TextEditingController();
    late GoogleMapController mapController;

    void _onMapCreated(GoogleMapController controller) {
      mapController = controller;
    }

    void _placeSelected(LatLng place) async {
      addSpotCubit.locationChanged(location: place);
    }

    return BlocBuilder<HSAddSpotCubit, HSAddSpotCubitState>(
      builder: (context, state) {
        if (state.isLoading) {
          addSpotCubit.getCurrentLocation();
          return const Center(child: CircularProgressIndicator());
        }
        return Stack(children: [
          GoogleMap(
            myLocationEnabled: true,
            myLocationButtonEnabled: true,

            onMapCreated: (GoogleMapController controller) async {
              mapController = controller;
            },
            // onTap: (LatLng place) => _placeSelected(place),
            initialCameraPosition: CameraPosition(
              target: state.location,
              zoom: 16.0,
            ),
            onCameraMove: (position) {
              if (state.location !=
                  LatLng(position.target.latitude, position.target.longitude)) {
                addSpotCubit.locationChanged(location: position.target);
              }
            },
            onCameraIdle: () async {
              addSpotCubit.setLocationChanged(location: state.location);
            },
            mapType: MapType.normal,
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              margin: const EdgeInsets.all(16.0),
              child: GooglePlaceAutoCompleteTextField(
                googleAPIKey: "AIzaSyDxNpYTqwsJOoeXdOJ4yN3e4VPU1xwNZlU",
                textEditingController: _searchBarController,
                textStyle: TextStyle(color: Colors.grey[800]),
                inputDecoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "Search your location...",
                    hintStyle: const TextStyle(
                      color: Colors.grey,
                    ),
                    prefixIcon: Padding(
                      padding: EdgeInsets.symmetric(vertical: 12.0),
                      child: Icon(
                        Icons.location_pin,
                        color: Colors.grey[800],
                      ),
                    )),
                isLatLngRequired: true,
                getPlaceDetailWithLatLng: (Prediction prediction) {
                  if (prediction.lat == null || prediction.lng == null) return;

                  double? lat = double.tryParse(prediction.lat!);
                  double? lng = double.tryParse(prediction.lng!);

                  if (lat == null || lng == null) return;

                  LatLng latLng = LatLng(lat, lng);

                  addSpotCubit.locationChanged(location: latLng);
                  mapController
                      .animateCamera(CameraUpdate.newLatLngZoom(latLng, 14));
                },
                itemClick: (Prediction prediction) {
                  _searchBarController.text = prediction.description ?? "";
                  _searchBarController.selection = TextSelection.fromPosition(
                      TextPosition(offset: prediction.description!.length));
                },
                boxDecoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 3,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                itemBuilder: (context, index, Prediction prediction) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8.0),
                    decoration: index == 4
                        ? const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.vertical(
                                bottom: Radius.circular(20)),
                          )
                        : const BoxDecoration(color: Colors.white),
                    child: Text(prediction.description!,
                        style: TextStyle(color: Colors.grey[800])),
                  );
                },
                isCrossBtnShown: true,
              ),
            ),
          ),
          Positioned(
            bottom: 5,
            left: 35,
            right: 35,
            child: Align(
              child: Container(
                  alignment: Alignment.bottomCenter,
                  margin: EdgeInsets.all(20.0),
                  padding:
                      EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
                  decoration: BoxDecoration(
                    color:
                        HSApp.instance.theme.currentTheme(context).primaryColor,
                    borderRadius: BorderRadius.all(Radius.circular(24.0)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.location_pin),
                              Text(
                                "Address",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(state.selectedLocationStreetName,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.right),
                          ),
                        ],
                      ),
                      SizedBox(height: 4.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.arrow_forward_ios),
                              Text("Distance",
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text("${state.selectedLocationDistance}",
                                overflow: TextOverflow.clip,
                                textAlign: TextAlign.right),
                          ),
                        ],
                      ),
                    ],
                  )),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 35.0),
              child: Icon(
                state.location == state.selectedLocation
                    ? Icons.location_pin
                    : Icons.pin_drop,
                color: Colors.grey[800],
                size: 36,
              ),
            ),
          ),
        ]);
      },
    );
  }
}

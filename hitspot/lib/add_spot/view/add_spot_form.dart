import 'dart:async';
import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_config/flutter_config.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hitspot/add_spot/cubit/hs_add_spot_cubit_cubit.dart';
import 'package:hitspot/app/hs_app.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/home/view/home_page.dart';
import 'package:hitspot/utils/theme/hs_theme.dart';
import 'package:hitspot/widgets/hs_appbar.dart';
import 'package:hitspot/widgets/hs_scaffold.dart';
import 'package:hitspot/widgets/hs_searchbar.dart';
import 'package:hitspot/widgets/hs_textfield.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:location/location.dart';
import 'package:path/path.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';

class AddSpotForm extends StatelessWidget {
  const AddSpotForm({super.key});

  @override
  Widget build(BuildContext context) {
    final hsApp = HSApp.instance;
    final hsNavigation = hsApp.navigation;
    final addSpotCubit = context.read<HSAddSpotCubit>();
    final pageController = PageController();

    return PageView(
      controller: pageController,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _LocationSelection(
          pageController: pageController,
        ),
        _ImageSelection(
          pageController: pageController,
        ),
        _TextInput(
          pageController: pageController,
        )
      ],
    );
  }
}

class _TextInput extends StatelessWidget {
  _TextInput({super.key, required this.pageController});
  final PageController pageController;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final _addSpotCubit = context.read<HSAddSpotCubit>();

    return HSScaffold(
        sidePadding: 0,
        appBar: HSAppBar(
            title: "PROVIDE SPOT DETAILS",
            right: IconButton(
              icon: const Icon(Icons.close, size: 28),
              onPressed: () => navi.pop(),
            ),
            fontSize: 16.0,
            titleBold: true,
            enableDefaultBackButton: true,
            defaultBackButtonCallback: () => pageController.previousPage(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut)),
        body: Stack(children: [
          Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      margin: EdgeInsets.all(8.0),
                      child: TextField(
                        enabled: !_addSpotCubit.state.isLoading,
                        onChanged: (value) => _addSpotCubit.titleChanged(
                            title: _titleController.text),
                        controller: _titleController,
                        decoration: const InputDecoration(
                          hintText: 'Title',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.all(8.0),
                      child: TextField(
                        enabled: !_addSpotCubit.state.isLoading,
                        onChanged: (value) => _addSpotCubit.descriptionChanged(
                            description: _descriptionController.text),
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          hintText: 'Description',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 5,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () async {
                    _addSpotCubit.isLoadingChanged(isLoading: true);
                    await _addSpotCubit.createSpot();
                    _addSpotCubit.isLoadingChanged(isLoading: false);
                    HSApp.instance.navigation.pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'SAVE SPOT',
                    style: TextStyle(color: Colors.black, letterSpacing: 0.5),
                  ),
                ),
              ),
              const SizedBox(
                height: 40,
              )
            ],
          ),
          BlocBuilder<HSAddSpotCubit, HSAddSpotCubitState>(
              builder: (context, state) {
            if (state.isLoading) {
              return const Stack(
                children: [
                  Opacity(
                    opacity: 0.8,
                    child:
                        ModalBarrier(dismissible: false, color: Colors.black),
                  ),
                  Center(
                    child: CircularProgressIndicator(),
                  )
                ],
              );
            } else {
              return const SizedBox.shrink();
            }
          })
        ]));
  }
}

class _ImageSelection extends StatelessWidget {
  _ImageSelection({super.key, required this.pageController});
  final PageController pageController;
  final picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    final addSpotCubit = context.read<HSAddSpotCubit>();

    return BlocBuilder<HSAddSpotCubit, HSAddSpotCubitState>(
        builder: (context, state) {
      return HSScaffold(
          sidePadding: 0,
          appBar: HSAppBar(
              title: "SELECT SPOT IMAGES",
              right: IconButton(
                icon: const Icon(Icons.close, size: 28),
                onPressed: () => navi.pop(),
              ),
              fontSize: 16.0,
              titleBold: true,
              enableDefaultBackButton: true,
              defaultBackButtonCallback: () => pageController.previousPage(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOut)),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    final pickedImages = await picker.pickMultiImage(limit: 5);
                    addSpotCubit.imagesChanged(images: pickedImages);
                  },
                  child: state.images.isEmpty
                      ? Container(
                          width: double.infinity,
                          height: 300,
                          color: Colors.grey[300],
                          child: Center(
                            child: Text(
                              'Click to select images',
                              style: textTheme.headlineMedium!.copyWith(
                                color: Colors.black54,
                              ),
                            ),
                          ),
                        )
                      : CarouselSlider(
                          options: CarouselOptions(
                            height: 300,
                            enlargeCenterPage: true,
                            enableInfiniteScroll: false,
                            initialPage: 0,
                          ),
                          items: state.images.map((image) {
                            return Builder(
                              builder: (BuildContext context) {
                                return Image.file(
                                  File(image.path),
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                );
                              },
                            );
                          }).toList(),
                        ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(
                    top: 16.0, bottom: 8.0, left: 8.0, right: 8.0),
                child: ElevatedButton(
                  onPressed: () {
                    pageController.nextPage(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeInOut,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'NEXT',
                    style: TextStyle(color: Colors.black, letterSpacing: 0.5),
                  ),
                ),
              ),
              const SizedBox(height: 40)
            ],
          ));
    });
  }
}

class _LocationSelection extends StatelessWidget {
  const _LocationSelection({super.key, required this.pageController});
  final PageController pageController;

  @override
  Widget build(BuildContext context) {
    final addSpotCubit = context.read<HSAddSpotCubit>();

    return BlocBuilder<HSAddSpotCubit, HSAddSpotCubitState>(
      builder: (context, state) {
        if (state.isLoading) {
          addSpotCubit.getCurrentLocation();
          return const Center(child: CircularProgressIndicator());
        }
        return HSScaffold(
            sidePadding: 0,
            appBar: HSAppBar(
                title: "SELECT LOCATION OF YOUR SPOT",
                right: IconButton(
                  icon: const Icon(Icons.close, size: 28),
                  onPressed: () => navi.pop(),
                ),
                fontSize: 16.0,
                titleBold: true,
                enableDefaultBackButton: true,
                defaultBackButtonCallback: () => navi.pop()),
            body: Stack(children: [
              _MapAndSearchBar(),
              _SelectedSpotTile(
                pageController: pageController,
              ),
              const _Pin(),
            ]));
      },
    );
  }
}

Completer<GoogleMapController> _mapController =
    Completer<GoogleMapController>();

class _MapAndSearchBar extends StatelessWidget {
  _MapAndSearchBar({super.key});

  final TextEditingController _searchBarController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final addSpotCubit = context.read<HSAddSpotCubit>();

    return BlocBuilder<HSAddSpotCubit, HSAddSpotCubitState>(
      builder: (context, state) {
        return Stack(
          children: [
            GoogleMap(
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              onMapCreated: (GoogleMapController controller) {
                if (_mapController.isCompleted) {
                  _mapController = Completer<GoogleMapController>();
                }
                _mapController.complete(controller);
              },
              initialCameraPosition: CameraPosition(
                target: state.usersLocation,
                zoom: 16.0,
              ),
              onCameraMove: (position) {
                addSpotCubit.locationChanged(location: position.target);
              },
              onCameraIdle: () {
                addSpotCubit.setLocationChanged(location: state.location);
              },
              onTap: (LatLng location) {
                _searchBarController.text = "";
              },
              mapType: MapType.normal,
            ),
            Positioned(
              top: 13,
              left: 0,
              right: 0,
              child: Container(
                margin: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: GooglePlaceAutoCompleteTextField(
                  googleAPIKey: FlutterConfig.get('GOOGLE_MAPS_API_KEY') ?? "",
                  textEditingController: _searchBarController,
                  textStyle: const TextStyle(color: Colors.white),
                  inputDecoration: InputDecoration(
                    contentPadding: EdgeInsets.all(11),
                    border: InputBorder.none,
                    hintText: "Search your location...",
                    hintStyle: textTheme.headlineSmall!.copyWith(
                        color: Colors.white, fontWeight: FontWeight.normal),
                    prefixIcon: const Icon(
                      Icons.location_pin,
                      color: Colors.white,
                    ),
                  ),
                  isLatLngRequired: true,
                  getPlaceDetailWithLatLng: (Prediction prediction) async {
                    if (prediction.lat == null || prediction.lng == null) {
                      return;
                    }

                    double? lat = double.tryParse(prediction.lat!);
                    double? lng = double.tryParse(prediction.lng!);

                    if (lat == null || lng == null) {
                      return;
                    }

                    LatLng latLng = LatLng(lat, lng);

                    addSpotCubit.locationChanged(location: latLng);
                    animateCameraToNewLatLng(latLng);
                  },
                  itemClick: (Prediction prediction) {
                    _searchBarController.text = prediction.description ?? "";
                    _searchBarController.selection = TextSelection.fromPosition(
                        TextPosition(offset: prediction.description!.length));
                  },
                  itemBuilder: (context, index, Prediction prediction) {
                    return Container(
                      color: Colors.grey[850],
                      child: ListTile(
                        title: Text(
                          prediction.description ?? "",
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    );
                  },
                  isCrossBtnShown: true,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> animateCameraToNewLatLng(LatLng location) async {
    final GoogleMapController controller = await _mapController.future;
    controller.animateCamera(CameraUpdate.newLatLngZoom(location, 14));
  }
}

class _SelectedSpotTile extends StatelessWidget {
  const _SelectedSpotTile({super.key, required this.pageController});

  final PageController pageController;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HSAddSpotCubit, HSAddSpotCubitState>(
      builder: (context, state) {
        return Positioned(
          bottom: 30,
          left: 20,
          right: 20,
          child: Card(
            color: Colors.grey[900],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Address',
                        style: textTheme.headlineMedium!.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        state.selectedLocationStreetName,
                        style: const TextStyle(fontSize: 15),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Divider(color: Colors.white),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.access_time),
                      const SizedBox(width: 5),
                      const Text(
                          'DUMMY'), // I think we could add something here, what do you think?
                      const Spacer(),
                      const Icon(Icons.location_on),
                      const SizedBox(width: 5),
                      Text(state.selectedLocationDistance),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        pageController.nextPage(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'SELECT',
                        style:
                            TextStyle(color: Colors.black, letterSpacing: 0.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Pin extends StatelessWidget {
  const _Pin({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HSAddSpotCubit, HSAddSpotCubitState>(
        builder: (context, state) {
      return Center(
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
      );
    });
  }
}

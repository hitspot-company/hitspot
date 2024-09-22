import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:exif/exif.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/features/spots/create/map/view/choose_location_provider.dart';
import 'package:hitspot/features/spots/create_2/form/view/create_spot_form_provider.dart';
import 'package:hs_database_repository/hs_database_repository.dart';
import 'package:hs_debug_logger/hs_debug_logger.dart';
import 'package:hs_location_repository/hs_location_repository.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:page_transition/page_transition.dart';
import 'package:permission_handler/permission_handler.dart';

part 'hs_create_spot_location_state.dart';

class HsCreateSpotLocationCubit extends Cubit<HsCreateSpotLocationState> {
  HsCreateSpotLocationCubit({required this.images, this.prototype})
      : super(const HsCreateSpotLocationState()) {
    _chooseLocation();
  }

  final List<XFile> images;
  final HSSpot? prototype;

  Future<void> _chooseLocation() async {
    emit(state.copyWith(status: HsCreateSpotLocationStatus.choosingLocation));
    Position? currentLocation;

    // Handle the prototype check
    if (prototype != null && images.isEmpty) {
      currentLocation = posFromLatLng(
          latitude: prototype?.latitude, longitude: prototype?.longitude);
    }

    // Fallback to images
    if (currentLocation == null) {
      for (final image in images) {
        final gps = await _getGPSCoordinates(File(image.path));
        if (gps != null) {
          currentLocation = posFromLatLng(latLng: gps);
          break;
        }
      }
    }

    // Fallback to app.currentPosition and location permission check
    if (currentLocation == null) {
      currentLocation = app.currentPosition;
      final permissionStatus = await Permission.location.request();
      if ((permissionStatus.isGranted || await Permission.location.isLimited) &&
          currentLocation == null) {
        try {
          final location = await app.locationRepository.getCurrentLocation();
          currentLocation = location; // Default if location is still null
        } catch (e) {
          HSDebugLogger.logInfo("Error while getting current location: $e");
          currentLocation = kDefaultPosition; // Use default location on error
        }
      } else {
        currentLocation = kDefaultPosition;
      }
    }

    await Future.delayed(const Duration(
        seconds: 1)); // DON'T REMOVE THIS - the navigator needs time to build
    final HSLocation? result = await navi.pushTransition(
      PageTransitionType.fade,
      ChooseLocationProvider(initialUserLocation: currentLocation),
    );

    if (result != null) {
      HSDebugLogger.logSuccess("Received location: $result");
      var res = await navi.pushTransition(
        PageTransitionType.fade,
        CreateSpotFormProvider(
          images: images,
          location: result,
          prototype: prototype,
        ),
      );
      if (res == true) {
        _chooseLocation();
      }
    } else {
      HSDebugLogger.logInfo("No location selected");
      navi.pop(true);
      return;
    }
  }

  dynamic dmsToDD(List coords, coordsRef) {
    final d = coords[0] as Ratio;
    final m = coords[1] as Ratio;
    final s = coords[2] as Ratio;
    final dd = (d.numerator / d.denominator) +
        (m.numerator / m.denominator) / 60 +
        (s.numerator / s.denominator) / 3600;
    if (coordsRef.toUpperCase() == 'S' || coordsRef.toUpperCase() == 'W') {
      return -dd;
    } else if (coordsRef.toUpperCase() == 'N' ||
        coordsRef.toUpperCase() == 'E') {
      return dd;
    } else {
      return null;
    }
  }

  Future<LatLng?> _getGPSCoordinates(File file) async {
    final bytes = await file.readAsBytes();
    final image = img.decodeImage(bytes);
    if (image == null) {
      return null;
    }
    final gpsData = await readExifFromBytes(bytes);
    final gpsLatitude = gpsData['GPS GPSLatitude']?.values.toList();
    final gpsLatitudeRef = gpsData['GPS GPSLatitudeRef']?.printable;
    final gpsLongitude = gpsData['GPS GPSLongitude']?.values.toList();
    final gpsLongitudeRef = gpsData['GPS GPSLongitudeRef']?.printable;
    if (gpsLatitude == null ||
        gpsLatitudeRef == null ||
        gpsLongitude == null ||
        gpsLongitudeRef == null) {
      return null;
    }
    final latitude = dmsToDD(gpsLatitude, gpsLatitudeRef);
    final longitude = dmsToDD(gpsLongitude, gpsLongitudeRef);
    return LatLng(latitude, longitude);
  }

  Position posFromLatLng(
      {LatLng? latLng, double? latitude, double? longitude}) {
    final double lat = latitude ?? latLng?.latitude ?? 0.0;
    final double long = longitude ?? latLng?.longitude ?? 0.0;
    return Position(
      latitude: lat,
      longitude: long,
      altitude: 0.0,
      accuracy: 0.0,
      speed: 0.0,
      speedAccuracy: 0.0,
      heading: 0.0,
      timestamp: DateTime.now(),
      altitudeAccuracy: 0.0,
      headingAccuracy: 0.0,
    );
  }
}

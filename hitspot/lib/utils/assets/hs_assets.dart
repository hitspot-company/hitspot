import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hs_database_repository/hs_database_repository.dart';
import 'package:hs_location_repository/hs_location_repository.dart';
import 'dart:ui' as ui;

class HSAssets {
  HSAssets._internal() {
    _initialiseMarkerBitmap();
  }
  static final HSAssets _instance = HSAssets._internal();
  static HSAssets get instance => _instance;

  static const String _iconsPath = "assets/icons";
  final String textLogo = "$_iconsPath/logotype/blue.png";
  final String logo = "$_iconsPath/logo/blue.png";
  static const String mapStyle = "assets/map/map_dark.json";

  // MAP MARKERS
  static const String mapIconsPath = "assets/map";
  static const String mapPin = "$mapIconsPath/pin.svg";
  static const String mapDotRed = "$mapIconsPath/dot_red.svg";
  static const String mapDotYellow = "$mapIconsPath/dot_yellow.svg";
  static const String mapDotGreen = "$mapIconsPath/dot_green.svg";
  static const String mapDotBlue = "$mapIconsPath/dot_blue.svg";
  late final BitmapDescriptor _spotMarker;
  final int markerSizeMedium = 16;

  void _initialiseMarkerBitmap() async {
    await _bitmapDescriptorFromSvgAsset(mapDotBlue, markerSizeMedium)
        .then((value) => _spotMarker = value);
  }

  Future<BitmapDescriptor> _bitmapDescriptorFromSvgAsset(
      String assetName, int size) async {
    // Get the properly scaled image
    try {
      final image = await getImageFromSvg(
          assetName, size.toDouble(), size.toDouble(),
          colorFilter: null);
      final ByteData? bytes =
          await image.toByteData(format: ui.ImageByteFormat.png);
      return BitmapDescriptor.bytes(bytes!.buffer.asUint8List());
    } catch (e) {
      throw Exception('Error loading SVG asset: $e');
    }
  }

  Marker createSpotMarker(HSSpot spot,
      {LatLng? currentPosition, Function(HSSpot spot)? onTap}) {
    late final double dis;
    if (currentPosition != null) {
      dis = calculateDistance(currentPosition.latitude,
          currentPosition.longitude, spot.latitude, spot.longitude);
    } else {
      dis = 0.0;
    }
    return Marker(
      markerId: MarkerId(spot.hashCode.toString()),
      icon: dis < 0.6 ? _spotMarker : _spotMarker, // TODO: Change
      position: LatLng(spot.latitude!, spot.longitude!),
      onTap: () {
        if (onTap != null) onTap(spot);
      },
    );
  }

  List<Marker> generateMarkers(List<HSSpot> spots, LatLng? currentPosition,
      [Function(HSSpot)? onTap]) {
    List<Marker> generatedMapMarkers = [];
    for (var i = 0; i < spots.length; i++) {
      generatedMapMarkers.add(createSpotMarker(spots[i],
          currentPosition: currentPosition, onTap: onTap));
    }
    return generatedMapMarkers;
  }

  static Future<ui.Image> getImageFromSvg(
      String path, double width, double height,
      {ColorFilter? colorFilter}) async {
    String data = await rootBundle.loadString(path);

    // Get the properly scaled image
    final SvgStringLoader svgStringLoader = SvgStringLoader(data);
    final PictureInfo pictureInfo = await vg.loadPicture(svgStringLoader, null);
    final ui.Picture picture = pictureInfo.picture;
    ui.PictureRecorder recorder = ui.PictureRecorder();
    ui.Canvas canvas =
        Canvas(recorder, Rect.fromPoints(Offset.zero, Offset(width, height)));
    canvas.scale(
        width / pictureInfo.size.width, height / pictureInfo.size.height);
    canvas.drawPicture(picture);
    final ui.Image colorlessImage =
        await recorder.endRecording().toImage(width.ceil(), height.ceil());
    pictureInfo.picture.dispose();

    if (colorFilter == null) {
      return colorlessImage;
    }

    // Apply color filter if necessary
    recorder = ui.PictureRecorder();
    canvas =
        Canvas(recorder, Rect.fromPoints(Offset.zero, Offset(width, height)));
    Paint paint = Paint();
    paint.colorFilter = colorFilter;

    ui.Size inputSize = ui.Size(
        colorlessImage.width.toDouble(), colorlessImage.height.toDouble());
    final FittedSizes fittedSizes =
        applyBoxFit(BoxFit.contain, inputSize, inputSize);
    final ui.Size sourceSize = fittedSizes.source;
    final Rect sourceRect =
        Alignment.center.inscribe(sourceSize, Offset.zero & inputSize);
    var rect = Rect.fromPoints(
        const Offset(0.0, 0.0),
        Offset(
            colorlessImage.width.toDouble(), colorlessImage.height.toDouble()));

    canvas.drawImageRect(colorlessImage, sourceRect, rect, paint);
    final ui.Image image =
        await recorder.endRecording().toImage(width.ceil(), height.ceil());
    return image;
  }

  double calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }
}

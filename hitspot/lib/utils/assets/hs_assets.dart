import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hs_database_repository/hs_database_repository.dart';
import 'package:hs_debug_logger/hs_debug_logger.dart';
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
  static const String dotSelected = "$mapIconsPath/dot_selected.svg";
  static const String dotVerified = "$mapIconsPath/dot_verified.svg";
  static const String dotUnverified = "$mapIconsPath/dot_unverified.svg";

  late final BitmapDescriptor _unverifiedMarker,
      _verifiedMarker,
      _selectedMarker;
  final int markerSizeMedium = 20;

  void _initialiseMarkerBitmap() async {
    await _bitmapDescriptorFromSvgAsset(dotVerified, markerSizeMedium)
        .then((value) => _verifiedMarker = value);
    await _bitmapDescriptorFromSvgAsset(dotUnverified, markerSizeMedium)
        .then((value) => _unverifiedMarker = value);
    await _bitmapDescriptorFromSvgAsset(dotSelected, markerSizeMedium)
        .then((value) => _selectedMarker = value);
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

  BitmapDescriptor _getSpotMarker(HSSpot spot, {bool isSelected = false}) {
    if (spot.likesCount! > 10) {
      return _verifiedMarker;
    } else if (isSelected) {
      return _selectedMarker;
    }
    return _unverifiedMarker;
  }

  Marker createSpotMarker(HSSpot spot,
      {LatLng? currentPosition,
      Function(HSSpot spot)? onTap,
      HSSpotMarkerType type = HSSpotMarkerType.unverified}) {
    late final double dis;
    if (currentPosition != null) {
      dis = calculateDistance(currentPosition.latitude,
          currentPosition.longitude, spot.latitude, spot.longitude);
    } else {
      dis = 0.0;
    }
    return Marker(
      markerId: MarkerId(spot.hashCode.toString()),
      icon: _getSpotMarker(spot, isSelected: type == HSSpotMarkerType.selected),
      position: LatLng(spot.latitude!, spot.longitude!),
      onTap: () {
        if (onTap != null) onTap(spot);
      },
    );
  }

  List<Marker> generateMarkers(List<HSSpot> spots, LatLng? currentPosition,
      {Function(HSSpot)? onTap, String? selectedSpotID}) {
    List<Marker> generatedMapMarkers = [];
    for (var i = 0; i < spots.length; i++) {
      final type = selectedSpotID == spots[i].sid
          ? HSSpotMarkerType.selected
          : HSSpotMarkerType.unverified;
      HSDebugLogger.logInfo("Type : $type");
      generatedMapMarkers.add(createSpotMarker(spots[i],
          currentPosition: currentPosition, onTap: onTap, type: type));
    }
    return generatedMapMarkers;
  }

  static Future<ui.Image> getImageFromSvg(
      String path, double width, double height,
      {ColorFilter? colorFilter, double scale = 3.0}) async {
    // Load SVG data from asset
    String data = await rootBundle.loadString(path);

    // Parse the SVG data and get the picture
    final SvgStringLoader svgStringLoader = SvgStringLoader(data);
    final PictureInfo pictureInfo = await vg.loadPicture(svgStringLoader, null);
    final ui.Picture picture = pictureInfo.picture;

    // Create a PictureRecorder and Canvas to draw the SVG
    ui.PictureRecorder recorder = ui.PictureRecorder();
    double scaledWidth = width * scale;
    double scaledHeight = height * scale;
    ui.Canvas canvas = Canvas(recorder,
        Rect.fromPoints(Offset.zero, Offset(scaledWidth, scaledHeight)));

    // Scale the canvas to fit the SVG properly
    canvas.scale(scaledWidth / pictureInfo.size.width,
        scaledHeight / pictureInfo.size.height);
    canvas.drawPicture(picture);

    // Generate the colorless image
    final ui.Image colorlessImage = await recorder
        .endRecording()
        .toImage(scaledWidth.ceil(), scaledHeight.ceil());
    pictureInfo.picture.dispose();

    if (colorFilter == null) {
      // Scale the high-resolution image down to the desired size
      return await _resizeImage(colorlessImage, width, height);
    }

    // Apply color filter if necessary
    recorder = ui.PictureRecorder();
    canvas = Canvas(recorder,
        Rect.fromPoints(Offset.zero, Offset(scaledWidth, scaledHeight)));
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
    final ui.Image filteredImage = await recorder
        .endRecording()
        .toImage(scaledWidth.ceil(), scaledHeight.ceil());

    // Scale the filtered image down to the desired size
    return await _resizeImage(filteredImage, width, height);
  }

  // Helper function to resize an image
  static Future<ui.Image> _resizeImage(
      ui.Image image, double targetWidth, double targetHeight) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint();
    canvas.drawImageRect(
      image,
      Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      Rect.fromLTWH(0, 0, targetWidth, targetHeight),
      paint,
    );
    final picture = recorder.endRecording();
    return await picture.toImage(targetWidth.ceil(), targetHeight.ceil());
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

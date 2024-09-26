import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hs_database_repository/hs_database_repository.dart';
import 'package:hs_location_repository/hs_location_repository.dart';
import 'dart:ui' as ui;

class HSAssets {
  HSAssets._internal();
  static final HSAssets _instance = HSAssets._internal();
  static HSAssets get instance => _instance;

  static const String _iconsPath = "assets/icons";
  final String textLogo = "$_iconsPath/logotype/blue.png";
  final String logo = "$_iconsPath/logo/blue.png";
  final String mapStyleLight = "assets/map/map_blue.json";
  final String mapStyleDark = "assets/map/map_dark.json";

  // MAP MARKERS
  static const String mapIconsPath = "assets/map";
  static const String mapPin = "$mapIconsPath/pin.svg";
  static const String dotSelected = "$mapIconsPath/dot_selected.svg";
  static const String dotVerified = "$mapIconsPath/dot_verified.svg";
  static const String dotUnverified = "$mapIconsPath/dot_unverified.svg";
  static const String generalMarker = "$mapIconsPath/map_general.svg";
  static const String favoriteMarker = "$mapIconsPath/map_favorite.svg";
  static const String barMarker = "$mapIconsPath/map_bar.svg";

  double calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }
}

enum HSSpotMarkerLevel { low, medium, high }

enum HSSpotMarkerType { bar, favorite, general, night }

class HSSpotMarker {
  final HSSpot spot;
  late final BitmapDescriptor icon;
  final String iconPath;
  final LatLng position;
  final Function(HSSpot spot) onTap;
  final HSSpotMarkerLevel level;
  late final HSSpotMarkerType type;

  HSSpotMarker({
    required this.spot,
    required this.iconPath,
    required this.position,
    required this.onTap,
    required this.level,
  }) {
    _init();
  }

  void _init() async {
    icon = await _generateBitmap();
    type = getMarkerType();
  }

  Future<BitmapDescriptor> _generateBitmap() async {
    try {
      const double scaleFactor = 3.0;
      final double size = markerSize;

      final image = await getImageFromSvg(
        iconPath,
        size.toDouble() * scaleFactor,
        size.toDouble() * scaleFactor,
        scale: 12.0,
        colorFilter: null,
      );

      // Convert the image to ByteData format (PNG)
      final ByteData? bytes =
          await image.toByteData(format: ui.ImageByteFormat.png);

      return BitmapDescriptor.bytes(
          bytes!.buffer.asUint8List()); // TOOD: Veridfy (was toBytes)
    } catch (e) {
      throw Exception('Error loading SVG asset: $e');
    }
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

  double get markerSize {
    if (level == HSSpotMarkerLevel.low) {
      return 20.0;
    } else if (level == HSSpotMarkerLevel.medium) {
      return 30.0;
    } else {
      return 40.0;
    }
  }

  HSSpotMarkerType getMarkerType() {
    if (spot.tags!.contains('bar') || spot.tags!.contains('nightlife')) {
      return HSSpotMarkerType.bar;
    } else if (spot.likesCount! > 10) {
      return HSSpotMarkerType.favorite;
    } else {
      return HSSpotMarkerType.general;
    }
  }
}

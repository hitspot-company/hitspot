import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hs_database_repository/hs_database_repository.dart';
import 'package:hs_location_repository/hs_location_repository.dart';
import 'dart:ui' as ui;

class HSAssets {
  HSAssets._internal() {
    _init();
  }
  static final HSAssets _instance = HSAssets._internal();
  static HSAssets get instance => _instance;

  static const String _iconsPath = "assets/icons";
  final String textLogo = "$_iconsPath/logotype/blue.png";
  final String logo = "$_iconsPath/logo/blue.png";
  final String mapStyleLight = "assets/map/map_blue.json";
  final String mapStyleDark = "assets/map/map_dark.json";

  // MAP MARKERS
  static const String mapIconsPath = "assets/map";
  // static const String generalMarkerPath = "$mapIconsPath/marker_general.svg";
  static const String generalMarkerPath = "$mapIconsPath/dot_standard.svg";
  static const String favoriteMarkerPath = "$mapIconsPath/marker_favorite.svg";
  static const String barMarkerPath = "$mapIconsPath/marker_bar.svg";
  // static const String generalMarkerSelectedPath =
  //     "$mapIconsPath/marker_selected_general.svg";
  static const String generalMarkerSelectedPath =
      "$mapIconsPath/dot_selected.svg";
  // static const String favoriteMarkerSelectedPath =
  //     "$mapIconsPath/marker_selected_favorite.svg";
  // static const String barMarkerSelectedPath =
  //     "$mapIconsPath/marker_selected_bar.svg";

  static const markerScaleFactor = .7;
  static const markerLow = 20.0 * markerScaleFactor;
  static const markerMedium = 30.0 * markerScaleFactor;
  static const markerHigh = 40.0 * markerScaleFactor;

  late final HSSpotMarker barMarker;
  late final HSSpotMarker favoriteMarker;
  late final HSSpotMarker generalMarker;

  void _init() async {
    barMarker = HSSpotMarker(type: HSSpotMarkerType.bar);
    favoriteMarker = HSSpotMarker(type: HSSpotMarkerType.favorite);
    generalMarker = HSSpotMarker(type: HSSpotMarkerType.general);
  }

  BitmapDescriptor getMarkerIcon(HSSpot spot,
      {HSSpotMarkerLevel level = HSSpotMarkerLevel.high,
      bool isSelected = false}) {
    switch (HSSpotMarker.getMarkerType(spot)) {
      case HSSpotMarkerType.bar:
        return barMarker.fromLevel(level, isSelected);
      case HSSpotMarkerType.favorite:
        return favoriteMarker.fromLevel(level, isSelected);
      case HSSpotMarkerType.general:
        return generalMarker.fromLevel(level, isSelected);
      default:
        return generalMarker.fromLevel(level, isSelected);
    }
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

enum HSSpotMarkerLevel { low, medium, high }

enum HSSpotMarkerType { bar, favorite, general, night }

class HSSpotMarker {
  final BitmapDescriptor? icon;
  late final HSSpotMarkerType type;
  final Map<HSSpotMarkerLevel, BitmapDescriptor> markers = {};
  final Map<HSSpotMarkerLevel, BitmapDescriptor> selectedMarkers = {};

  HSSpotMarker({
    required this.type,
    this.icon,
  }) {
    _init();
  }

  void _init() async {
    for (var i = 0; i < 3; i++) {
      final level = HSSpotMarkerLevel.values[i];
      final icon = await _generateBitmap(level);
      final selectedIcon = await _generateBitmap(level, true);
      markers.update(level, (value) => icon, ifAbsent: () => icon);
      selectedMarkers.update(level, (value) => selectedIcon,
          ifAbsent: () => selectedIcon);
    }
  }

  Future<BitmapDescriptor> _generateBitmap(HSSpotMarkerLevel level,
      [bool selected = false]) async {
    try {
      const double scaleFactor = 3.0;
      final double size = markerSize(level);

      final image = await getImageFromSvg(
        getIconPath(selected),
        size.toDouble() * scaleFactor,
        size.toDouble() * scaleFactor,
        colorFilter: null,
      );

      // Convert the image to ByteData format (PNG)
      final ByteData? bytes =
          await image.toByteData(format: ui.ImageByteFormat.png);

      return BitmapDescriptor.fromBytes(
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

  double markerSize(HSSpotMarkerLevel level) {
    if (level == HSSpotMarkerLevel.low) {
      return HSAssets.markerLow;
    } else if (level == HSSpotMarkerLevel.medium) {
      return HSAssets.markerMedium;
    } else {
      return HSAssets.markerHigh;
    }
  }

  BitmapDescriptor fromLevel(HSSpotMarkerLevel level,
          [bool isSelected = false]) =>
      isSelected ? selectedMarkers[level]! : markers[level]!;
  BitmapDescriptor get medium => markers[HSSpotMarkerLevel.medium]!;
  BitmapDescriptor get high => markers[HSSpotMarkerLevel.high]!;
  BitmapDescriptor get low => markers[HSSpotMarkerLevel.low]!;

  String getIconPath([bool isSelected = false]) {
    if (isSelected) {
      switch (type) {
        // case HSSpotMarkerType.bar:
        //   return HSAssets.barMarkerSelectedPath;
        // case HSSpotMarkerType.favorite:
        //   return HSAssets.favoriteMarkerSelectedPath;
        // case HSSpotMarkerType.general:
        //   return HSAssets.generalMarkerSelectedPath;
        default:
          return HSAssets.generalMarkerSelectedPath;
      }
    }
    switch (type) {
      // case HSSpotMarkerType.bar:
      //   return HSAssets.barMarkerPath;
      // case HSSpotMarkerType.favorite:
      //   return HSAssets.favoriteMarkerPath;
      // case HSSpotMarkerType.general:
      //   return HSAssets.generalMarkerPath;
      default:
        return HSAssets.generalMarkerPath;
    }
  }

  static getMarkerType(HSSpot spot) {
    final tags = spot.tags ?? [];
    if (tags.contains("bar") || tags.contains("night")) {
      return HSSpotMarkerType.bar;
    } else if (spot.likesCount! > 10) {
      return HSSpotMarkerType.favorite;
    } else {
      return HSSpotMarkerType.general;
    }
  }

  static getMarkerLevel(double zoom) {
    if (zoom >= 18) {
      return HSSpotMarkerLevel.high;
    } else if (zoom >= 15) {
      return HSSpotMarkerLevel.medium;
    } else {
      return HSSpotMarkerLevel.low;
    }
  }
}

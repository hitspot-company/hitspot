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

  List<Marker> generateMarkers(List<HSSpot> spots, LatLng? currentPosition,
      [Function(HSSpot)? onTap]) {
    List<Marker> generatedMapMarkers = [];
    spots.forEach(
      (element) {
        double dis = calculateDistance(currentPosition?.latitude,
            currentPosition?.longitude, element.latitude, element.longitude);
        generatedMapMarkers.add(
          Marker(
            markerId: MarkerId(element.hashCode.toString()),
            icon: dis < 0.6 ? _spotMarker : _spotMarker, // TODO: Change
            position: LatLng(element.latitude!, element.longitude!),
            onTap: () {
              if (onTap != null) onTap(element);
            },
          ),
        );
      },
    );
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

  static const String greenDot = """
<?xml version="1.0" encoding="iso-8859-1"?>
<!-- Uploaded to: SVG Repo, www.svgrepo.com, Generator: SVG Repo Mixer Tools -->
<svg height="800px" width="800px" version="1.1" id="Layer_1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" 
	 viewBox="0 0 512 512" xml:space="preserve">
<g>
	<path style="fill:#507C5C;" d="M255.996,512c-68.38,0-132.667-26.629-181.02-74.98c-5.669-5.669-5.669-14.862,0-20.533
		c5.669-5.669,14.862-5.669,20.533,0c42.867,42.869,99.863,66.476,160.488,66.476s117.62-23.608,160.488-66.476
		C459.351,373.62,482.96,316.624,482.96,256s-23.608-117.62-66.476-160.488c-42.869-42.869-99.863-66.476-160.488-66.476
		S138.376,52.644,95.509,95.512c-57.256,57.256-79.728,141.45-58.65,219.728c2.085,7.742-2.501,15.708-10.244,17.793
		c-7.738,2.085-15.708-2.501-17.793-10.244C-2.68,280.078-2.935,234.853,8.086,192.005C19.44,147.853,42.572,107.387,74.977,74.98
		C123.328,26.629,187.616,0,255.996,0s132.667,26.629,181.02,74.98c48.352,48.352,74.98,112.639,74.98,181.02
		s-26.629,132.667-74.98,181.02C388.663,485.371,324.376,512,255.996,512z"/>
	<path style="fill:#507C5C;" d="M255.996,446.518c-105.052,0-190.518-85.466-190.518-190.518S150.944,65.482,255.996,65.482
		c67.966,0,131.273,36.627,165.218,95.591c4,6.948,1.61,15.825-5.338,19.826c-6.947,4.001-15.825,1.61-19.826-5.338
		c-28.778-49.988-82.443-81.041-140.054-81.041c-89.042,0-161.482,72.44-161.482,161.482s72.44,161.482,161.482,161.482
		S417.478,345.042,417.478,256c0-8.018,6.5-14.518,14.518-14.518s14.518,6.5,14.518,14.518
		C446.514,361.052,361.048,446.518,255.996,446.518z"/>
</g>
<circle style="fill:#CFF09E;" cx="255.995" cy="255.996" r="105.981"/>
<path style="fill:#507C5C;" d="M255.996,376.499c-66.444,0-120.499-54.055-120.499-120.499s54.055-120.499,120.499-120.499
	S376.495,189.556,376.495,256S322.439,376.499,255.996,376.499z M255.996,164.537c-50.433,0-91.463,41.031-91.463,91.463
	s41.031,91.463,91.463,91.463s91.463-41.031,91.463-91.463S306.429,164.537,255.996,164.537z"/>
</svg>
""";
}

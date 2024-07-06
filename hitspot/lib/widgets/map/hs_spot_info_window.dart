import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hs_database_repository/hs_database_repository.dart';
import 'package:hs_location_repository/hs_location_repository.dart';

class HSSpotInfoWindow extends StatefulWidget {
  const HSSpotInfoWindow({super.key, required this.spot});
  final HSSpot spot;
  @override
  _HSSpotInfoWindowState createState() => _HSSpotInfoWindowState();
}

class _HSSpotInfoWindowState extends State<HSSpotInfoWindow> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: screenWidth,
      child: InkWell(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: () {},
          child: Column(children: <Widget>[
            Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.all(Radius.circular(screenWidth / 7)),
                  boxShadow: [
                    BoxShadow(
                        color: widget.spot.likesCount! > 10
                            ? Colors.green
                            : Colors.red,
                        spreadRadius: 5,
                        blurRadius: 8,
                        offset: const Offset(0, 0))
                  ]),
              child: ClipRRect(
                child: CircleAvatar(
                  radius: screenWidth / 7,
                  backgroundImage:
                      CachedNetworkImageProvider(widget.spot.images!.first),
                ),
              ),
            ),
            const Gap(16.0),
            Card(
                margin: EdgeInsets.symmetric(horizontal: 8.0),
                elevation: 8.0,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Text(
                          widget.spot.title!,
                          // style: TextStyle(
                          //     fontWeight: FontSizeConstants.fontWeightBold,
                          //     fontSize: FontSizeConstants.fontSize14,
                          //     color: Colors.blue)
                        ),
                      ),
                      // PharmacyRatingWidget(
                      //     onRatingTap: () {}, initRating: widget.model.rating),
                      // Padding(
                      //     padding: const EdgeInsets.symmetric(
                      //         vertical: SpaceConstants.spacing10,
                      //         horizontal: SpaceConstants.spacing10),
                      //     child: Text(widget.model.vicinity,
                      //         style: TextStyle(
                      //           fontWeight:
                      //               FontSizeConstants.fontWeightSemiBold,
                      //           fontSize: FontSizeConstants.fontSize12,
                      //         )))
                    ])),
            CustomPaint(
                painter: TriangleAnchorShape(),
                child: Container(width: 250, height: 300))
          ])),
    );
  }
}

class HexColor extends Color {
  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    return int.parse(hexColor, radix: 16);
  }

  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));
}

class TriangleAnchorShape extends CustomPainter {
  Paint? painter;

  TriangleAnchorShape() {
    painter = Paint()
      ..color = Colors.white
      ..shader
      ..style = PaintingStyle.fill;
  }

  @override
  void paint(Canvas canvas, Size size) {
    var path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width / 2, size.height);
    path.lineTo(0, 0);
    canvas.drawShadow(path, Colors.lightGreen, 4, true);
    canvas.drawPath(path, painter!);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class InfoWindowProvider extends ChangeNotifier {
  bool showInfoWindow = false;
  bool _tempHidden = false;
  double? leftMargin;
  double? topMargin;
  double? bottomMargin;
  double _infoWindowWidth = 400;
  double _markerOffset = 0;
  LatLng? location;
  double totalHeight = 0;

  void rebuildInfoWindow() {
    notifyListeners();
  }

  void updateWidth(double width) {
    _infoWindowWidth = width;
  }

  void updateHeight(double updateHeight) {
    if (totalHeight == 0) {
      totalHeight = updateHeight;
    }
  }

  void updateOffset(double offset) {
    _markerOffset = offset;
  }

  void updateVisibility(bool visibility) {
    showInfoWindow = visibility;
  }

  void updateInfoWindow(BuildContext context, GoogleMapController controller,
      {LatLng? latLng}) async {
    if (latLng != null) {
      location = latLng;
    }
    if (location != null) {
      ScreenCoordinate screenCoordinate =
          await controller.getScreenCoordinate(location!);
      double devicePixelRatio =
          Platform.isAndroid ? MediaQuery.of(context).devicePixelRatio : 1.0;
      double left = (screenCoordinate.x.toDouble() / devicePixelRatio) -
          (_infoWindowWidth / 2);
      double top =
          (screenCoordinate.y.toDouble() / devicePixelRatio) - _markerOffset;

      bottomMargin = (totalHeight + 10) -
          (screenCoordinate.y.toDouble() / devicePixelRatio);

      debugPrint("===> margin $bottomMargin total height $totalHeight");
      _tempHidden = false;
      leftMargin = left;
      topMargin = top;
    }
  }

  bool get showInfoWindowData =>
      (showInfoWindow == true && _tempHidden == false) ? true : false;

  double? get leftMarginData => leftMargin;

  double? get bottomMarginData => bottomMargin;

  double? get topMarginData => topMargin;

  void resetInfoWindowProvider() {
    showInfoWindow = false;
    _tempHidden = false;
    leftMargin = 0.0;
    topMargin = 0.0;
    bottomMargin = 0.0;
    _infoWindowWidth = 400;
    _markerOffset = 0;
    location = null;
    totalHeight = 0;
  }
}

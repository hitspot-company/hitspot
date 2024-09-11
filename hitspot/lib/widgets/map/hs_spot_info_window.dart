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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
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
                    offset: const Offset(0, 0),
                  )
                ],
              ),
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
              margin: const EdgeInsets.symmetric(horizontal: 8.0),
              elevation: 8.0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Text(widget.spot.title!,
                        style: Theme.of(context).textTheme.headlineSmall),
                  ),
                  Container(
                    height: 100,
                    width: 200,
                    color: Colors.white,
                    child: Center(
                      child: Text("Likes count: ${widget.spot.likesCount}"),
                    ),
                  ),
                  Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 8.0),
                      child: Text(widget.spot.author?.username ?? "",
                          style: Theme.of(context).textTheme.bodyMedium))
                ],
              ),
            ),
            CustomPaint(
                painter: TriangleAnchorShape(),
                child: const SizedBox(width: 25, height: 30))
          ],
        ),
      ),
    );
  }
}

class HexColor extends Color {
  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF$hexColor";
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

class HSInfoWindowProvider {
  final bool showInfoWindow, tempHidden, showOnIdle;
  final double? leftMargin, topMargin, bottomMargin;
  final double infoWindowWidth, markerOffset;
  final LatLng? location;
  final double totalHeight;
  final HSSpot? spot;

  const HSInfoWindowProvider({
    this.showInfoWindow = false,
    this.tempHidden = false,
    this.leftMargin,
    this.topMargin,
    this.bottomMargin,
    this.infoWindowWidth = 400,
    this.markerOffset = 0,
    this.location,
    this.totalHeight = 0,
    this.spot,
    this.showOnIdle = false,
  });

  HSInfoWindowProvider copyWith({
    bool? showInfoWindow,
    bool? tempHidden,
    double? leftMargin,
    double? topMargin,
    double? bottomMargin,
    double? infoWindowWidth,
    double? markerOffset,
    LatLng? location,
    double? totalHeight,
    HSSpot? spot,
    bool? showOnIdle,
  }) {
    return HSInfoWindowProvider(
      showInfoWindow: showInfoWindow ?? this.showInfoWindow,
      tempHidden: tempHidden ?? this.tempHidden,
      leftMargin: leftMargin ?? this.leftMargin,
      topMargin: topMargin ?? this.topMargin,
      bottomMargin: bottomMargin ?? this.bottomMargin,
      infoWindowWidth: infoWindowWidth ?? this.infoWindowWidth,
      markerOffset: markerOffset ?? this.markerOffset,
      location: location ?? this.location,
      totalHeight: totalHeight ?? this.totalHeight,
      spot: spot ?? this.spot,
      showOnIdle: showOnIdle ?? this.showOnIdle,
    );
  }

  HSInfoWindowProvider updateVisibilityOnIdle(bool visibility) {
    return copyWith(showOnIdle: visibility);
  }

  HSInfoWindowProvider updateWidth(double width) {
    return copyWith(infoWindowWidth: width);
  }

  HSInfoWindowProvider updateSpot(HSSpot spot) {
    return copyWith(spot: spot);
  }

  HSInfoWindowProvider updateHeight(double updateHeight) {
    if (totalHeight == 0) {
      return copyWith(totalHeight: updateHeight);
    }
    return this;
  }

  HSInfoWindowProvider updateOffset(double offset) {
    return copyWith(markerOffset: offset);
  }

  HSInfoWindowProvider updateVisibility(bool visibility) {
    return copyWith(showInfoWindow: visibility);
  }

  Future<HSInfoWindowProvider> updateInfoWindow(GoogleMapController controller,
      {LatLng? latLng}) async {
    if (latLng != null) {
      return copyWith(location: latLng);
    }
    if (location != null) {
      ScreenCoordinate screenCoordinate =
          await controller.getScreenCoordinate(location!);
      double devicePixelRatio =
          // Platform.isAndroid ? MediaQuery.of(context).devicePixelRatio :
          1.0;
      double left = (screenCoordinate.x.toDouble() / devicePixelRatio) -
          (infoWindowWidth / 2);
      double top =
          (screenCoordinate.y.toDouble() / devicePixelRatio) - markerOffset;

      final bm = (totalHeight + 10) -
          (screenCoordinate.y.toDouble() / devicePixelRatio);

      debugPrint("===> margin $bottomMargin total height $totalHeight");
      return copyWith(
        tempHidden: false,
        leftMargin: left,
        topMargin: top,
        bottomMargin: bm,
      );
    }
    return this;
  }

  bool get showInfoWindowData =>
      (showInfoWindow == true && tempHidden == false) ? true : false;

  double? get leftMarginData => leftMargin;

  double? get bottomMarginData => bottomMargin;

  double? get topMarginData => topMargin;

  HSInfoWindowProvider resetInfoWindowProvider() {
    return const HSInfoWindowProvider(
      showInfoWindow: false,
      tempHidden: false,
      leftMargin: 0.0,
      topMargin: 0.0,
      bottomMargin: 0.0,
      infoWindowWidth: 400,
      markerOffset: 0,
      location: null,
      totalHeight: 0,
    );
  }
}

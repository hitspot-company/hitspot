import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/widgets/hs_shimmer.dart';

class HSUserAvatar extends StatelessWidget {
  const HSUserAvatar({
    super.key,
    this.imgUrl,
    required this.radius,
    this.iconSize,
    this.loading = false,
    this.isAsset = false,
    this.child,
  });

  final String? imgUrl;
  final double radius;
  final double? iconSize;
  final bool loading;
  final bool isAsset;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    if (child != null) {
      return CircleAvatar(
        backgroundColor: app.theme.highlightColor,
        radius: radius,
        child: child,
      );
    } else if (loading) {
      return HSShimmer(
        child: CircleAvatar(
          backgroundColor: app.theme.highlightColor,
          radius: radius,
        ),
      );
    } else if (imgUrl == null) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: app.theme.highlightColor,
        child: Center(
          child: Icon(
            FontAwesomeIcons.solidUser,
            size: iconSize,
          ),
        ),
      );
    } else {
      late final ImageProvider<Object> image;
      if (isAsset) {
        image = AssetImage(imgUrl!);
      } else {
        image = NetworkImage(imgUrl!);
      }
      return CircleAvatar(
        radius: radius,
        backgroundColor: app.theme.highlightColor,
        backgroundImage: image,
      );
    }
  }
}

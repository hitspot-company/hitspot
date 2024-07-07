import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/widgets/hs_shimmer.dart';

class HSUserAvatar extends StatelessWidget {
  const HSUserAvatar({
    super.key,
    this.imageUrl,
    required this.radius,
    this.iconSize,
    this.loading = false,
    this.isAsset = false,
    this.child,
  });

  final String? imageUrl;
  final double radius;
  final double? iconSize;
  final bool loading;
  final bool isAsset;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    if (child != null) {
      return CircleAvatar(
        backgroundColor: currentTheme.highlightColor,
        radius: radius,
        child: Center(child: child),
      );
    } else if (loading) {
      return HSShimmer(
        child: CircleAvatar(
          backgroundColor: currentTheme.highlightColor,
          radius: radius,
        ),
      );
    } else if (imageUrl == null) {
      return CircleAvatar(
        radius: radius,
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
        image = AssetImage(imageUrl!);
      } else {
        image = NetworkImage(imageUrl!);
      }
      return CircleAvatar(
        radius: radius,
        backgroundColor: currentTheme.highlightColor,
        backgroundImage: image,
      );
    }
  }
}

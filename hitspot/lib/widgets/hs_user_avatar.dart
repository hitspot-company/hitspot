import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hitspot/app/hs_app.dart';
import 'package:hitspot/widgets/hs_shimmer.dart';

class HSUserAvatar extends StatelessWidget {
  const HSUserAvatar(
      {super.key,
      this.imgUrl,
      required this.radius,
      this.iconSize,
      this.loading = false});

  final String? imgUrl;
  final double radius;
  final double? iconSize;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return HSShimmer(
        child: CircleAvatar(
          radius: radius,
          backgroundColor: HSApp.instance.theme.currentTheme.highlightColor,
        ),
      );
    } else if (imgUrl == null) {
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
      return CircleAvatar(
        radius: radius,
        backgroundImage: NetworkImage(imgUrl!),
      );
    }
  }
}

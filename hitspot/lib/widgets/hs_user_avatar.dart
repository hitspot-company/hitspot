import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HSUserAvatar extends StatelessWidget {
  const HSUserAvatar(
      {super.key, this.imgUrl, required this.radius, this.iconSize});

  final String? imgUrl;
  final double radius;
  final double? iconSize;

  @override
  Widget build(BuildContext context) {
    assert(!(imgUrl != null && iconSize != null),
        "The icon size cannot be used when the image is not null.");
    if (imgUrl == null) {
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
        child: Center(child: Image.network(imgUrl!)),
      );
    }
  }
}

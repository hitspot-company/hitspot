import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hitspot/widgets/shimmers/hs_shimmer_box.dart';
import 'package:hs_database_repository/hs_database_repository.dart';

class HSBetterSpotTile extends StatelessWidget {
  const HSBetterSpotTile(
      {super.key, this.spot, this.isLoading = false, this.width, this.height});

  final HSSpot? spot;
  final bool isLoading;
  final double? width, height;

  @override
  Widget build(BuildContext context) {
    if (isLoading || spot == null) {
      return HSShimmerBox(width: width, height: height);
    }
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
          stops: const [0.0, .3, 1.0],
          colors: [
            Colors.black,
            Colors.black.withOpacity(.3),
            Colors.transparent
          ],
        ),
        image: DecorationImage(
          image: CachedNetworkImageProvider(spot!.images!.first),
        ),
      ),
      child: Align(
        alignment: Alignment.bottomLeft,
        child: Text(spot!.title!),
      ),
    );
  }
}

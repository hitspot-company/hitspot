import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hitspot/widgets/hs_shimmer.dart';
import 'package:hitspot/widgets/shimmer_skeleton.dart';

class HSImage extends StatelessWidget {
  const HSImage(
      {super.key,
      required this.imageUrl,
      this.height,
      this.width,
      this.fit,
      this.opacity});

  final String imageUrl;
  final double? height;
  final double? width;
  final BoxFit? fit;
  final double? opacity;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      imageBuilder: (context, imageProvider) => _Container(
          image: imageProvider,
          height: height,
          width: width,
          opacity: opacity,
          fit: fit),
      placeholder: (context, url) => HSShimmer(
        child: HSShimmerSkeleton(height: height, width: width),
      ),
    );
  }
}

class _Container extends StatelessWidget {
  const _Container(
      {required this.image, this.height, this.width, this.fit, this.opacity});

  final ImageProvider<Object> image;
  final double? height;
  final double? width;
  final BoxFit? fit;
  final double? opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        image: DecorationImage(image: image, fit: fit, opacity: opacity ?? 1.0),
      ),
    );
  }
}

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
      this.opacity,
      this.color,
      this.child,
      this.childAlignment = Alignment.center});

  final String? imageUrl;
  final double? height;
  final double? width;
  final BoxFit? fit;
  final double? opacity;
  final Color? color;
  final Widget? child;
  final Alignment childAlignment;

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null) {
      return _Container(
        color: color,
        height: height,
        width: width,
        childAlignment: childAlignment,
        child: child,
      );
    }
    return CachedNetworkImage(
      imageUrl: imageUrl!,
      imageBuilder: (context, imageProvider) => _Container(
          image: imageProvider,
          height: height,
          width: width,
          opacity: opacity,
          color: color,
          childAlignment: childAlignment,
          fit: fit,
          child: child),
      placeholder: (context, url) => HSShimmer(
        child: HSShimmerSkeleton(height: height, width: width),
      ),
    );
  }
}

class _Container extends StatelessWidget {
  const _Container(
      {this.image,
      this.height,
      this.width,
      this.fit,
      this.opacity,
      this.child,
      this.color,
      this.childAlignment = Alignment.center});

  final ImageProvider<Object>? image;
  final double? height;
  final double? width;
  final BoxFit? fit;
  final double? opacity;
  final Widget? child;
  final Color? color;
  final Alignment childAlignment;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: color,
        image: image != null
            ? DecorationImage(image: image!, fit: fit, opacity: opacity ?? 1.0)
            : null,
      ),
      child: Align(alignment: childAlignment, child: child),
    );
  }
}

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hitspot/widgets/hs_shimmer.dart';
import 'package:hitspot/widgets/shimmer_skeleton.dart';

class HSImage extends StatelessWidget {
  const HSImage(
      {super.key,
      this.imageUrl,
      this.height,
      this.width,
      this.fit,
      this.opacity,
      this.color,
      this.child,
      this.childAlignment = Alignment.center,
      this.isNetworkImage = true,
      this.imageProvider,
      this.borderRadius,
      this.onTap});

  final bool isNetworkImage;
  final String? imageUrl;
  final double? height;
  final double? width;
  final BoxFit? fit;
  final double? opacity;
  final Color? color;
  final Widget? child;
  final Alignment childAlignment;
  final ImageProvider<Object>? imageProvider;
  final BorderRadius? borderRadius;
  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: _HSImage(
        imageUrl: imageUrl,
        height: height,
        width: width,
        fit: fit,
        opacity: opacity,
        color: color,
        childAlignment: childAlignment,
        isNetworkImage: isNetworkImage,
        imageProvider: imageProvider,
        borderRadius: borderRadius,
        child: child,
      ),
    );
  }
}

class _HSImage extends StatelessWidget {
  const _HSImage(
      {super.key,
      this.imageUrl,
      this.height,
      this.width,
      this.fit,
      this.opacity,
      this.color,
      this.child,
      this.childAlignment = Alignment.center,
      this.isNetworkImage = true,
      this.imageProvider,
      this.borderRadius});

  final bool isNetworkImage;
  final String? imageUrl;
  final double? height;
  final double? width;
  final BoxFit? fit;
  final double? opacity;
  final Color? color;
  final Widget? child;
  final Alignment childAlignment;
  final ImageProvider<Object>? imageProvider;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null && imageProvider == null) {
      return _Container(
        color: color,
        opacity: opacity,
        height: height,
        width: width,
        borderRadius: borderRadius,
        childAlignment: childAlignment,
        child: child,
      );
    } else if (imageProvider != null) {
      return _Container(
          image: imageProvider,
          height: height,
          width: width,
          borderRadius: borderRadius,
          opacity: opacity,
          color: color,
          childAlignment: childAlignment,
          fit: fit,
          child: child);
    }

    return CachedNetworkImage(
      imageUrl: imageUrl!,
      imageBuilder: (context, imageProvider) => _Container(
          image: imageProvider,
          height: height,
          width: width,
          opacity: opacity,
          borderRadius: borderRadius,
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
      this.childAlignment = Alignment.center,
      this.borderRadius});

  final ImageProvider<Object>? image;
  final double? height;
  final double? width;
  final BoxFit? fit;
  final double? opacity;
  final Widget? child;
  final Color? color;
  final Alignment childAlignment;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        color: image != null ? null : color,
        image: image != null
            ? DecorationImage(
                image: image!,
                fit: fit ?? BoxFit.cover,
                opacity: opacity ?? 1.0)
            : null,
      ),
      child: Align(alignment: childAlignment, child: child),
    );
  }
}

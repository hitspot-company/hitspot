import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hitspot/widgets/shimmers/hs_shimmer_box.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

enum HSImageGalleryType { asset, network }

class HSImageGallery extends StatelessWidget {
  const HSImageGallery(
      {super.key,
      required this.images,
      this.type = HSImageGalleryType.network,
      this.backgroundDecoration,
      this.pageController,
      this.onPageChanged});

  final List<String> images;
  final HSImageGalleryType type;
  final BoxDecoration? backgroundDecoration;
  final PageController? pageController;
  final Function(int)? onPageChanged;

  @override
  Widget build(BuildContext context) {
    return PhotoViewGallery.builder(
      scrollPhysics: const BouncingScrollPhysics(),
      builder: (BuildContext context, int index) {
        return PhotoViewGalleryPageOptions(
          imageProvider: type == HSImageGalleryType.asset
              ? AssetImage(images[index])
              : CachedNetworkImageProvider(images[index]),
          initialScale: PhotoViewComputedScale.contained,
          heroAttributes: PhotoViewHeroAttributes(tag: images[index]),
        );
      },
      itemCount: images.length,
      loadingBuilder: (context, event) => const Center(
        child: SizedBox(
          width: 20.0,
          height: 20.0,
          child: HSShimmerBox(
            width: 20.0,
            height: 20.0,
          ),
        ),
      ),
      backgroundDecoration: backgroundDecoration,
      pageController: pageController,
      onPageChanged: onPageChanged,
    );
  }
}

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/widgets/shimmers/hs_shimmer_box.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

enum HSImageGalleryType { asset, network }

class HSImageGallery extends StatelessWidget {
  const HSImageGallery({
    super.key,
    required this.images,
    this.type = HSImageGalleryType.network,
    this.backgroundDecoration,
    required this.pageController,
    this.onPageChanged,
  });

  final List<String> images;
  final HSImageGalleryType type;
  final BoxDecoration? backgroundDecoration;
  final PageController pageController;
  final Function(int)? onPageChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragEnd: (details) => {navi.pop()},
      child: PhotoViewGallery.builder(
        scrollPhysics: const BouncingScrollPhysics(),
        builder: (BuildContext context, int index) {
          return PhotoViewGalleryPageOptions(
            tightMode: true,
            imageProvider: type == HSImageGalleryType.asset
                ? AssetImage(images[index])
                : CachedNetworkImageProvider(images[index]),
            initialScale: PhotoViewComputedScale.contained,
            heroAttributes: PhotoViewHeroAttributes(tag: images[index]),
            onScaleEnd: (context, details, controllerValue) => {
              if (controllerValue.position.dy > .7) {navi.pop()}
            },
          );
        },
        itemCount: images.length,
        loadingBuilder: (context, event) => HSShimmerBox(
          width: screenWidth,
          height: screenHeight / 1.3,
        ),
        backgroundDecoration: backgroundDecoration,
        pageController: pageController,
        onPageChanged: onPageChanged,
      ),
    );
  }
}

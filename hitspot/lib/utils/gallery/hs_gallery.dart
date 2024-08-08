import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

part 'hs_image_gallery_overlay.dart';

enum HSImageGalleryType { asset, network }

class HSGallery {
  HSGallery._privateConstructor();
  static final HSGallery _instance = HSGallery._privateConstructor();
  factory HSGallery() => _instance;
  static OverlayEntry? _overlayEntry;

  void showImageGallery({
    required List<String> images,
    HSImageGalleryType type = HSImageGalleryType.network,
    BoxDecoration? backgroundDecoration,
    PageController? pageController,
    Function(int)? onPageChanged,
    int initialIndex = 0,
  }) {
    _overlayEntry = OverlayEntry(
      builder: (context) => _ImageGalleryOverlay(
        images: images,
        type: type,
        backgroundDecoration: backgroundDecoration,
        pageController: pageController,
        onPageChanged: onPageChanged,
        initialIndex: initialIndex,
      ),
    );

    Overlay.of(app.context).insert(_overlayEntry!);
  }
}

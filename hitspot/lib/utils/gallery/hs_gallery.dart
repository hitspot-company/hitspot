import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum HSImageGalleryType { asset, network }

class HSGallery {
  HSGallery._privateConstructor();
  static final HSGallery _instance = HSGallery._privateConstructor();
  factory HSGallery() => _instance;

  void showImageGallery({
    required List<String> images,
    HSImageGalleryType type = HSImageGalleryType.network,
    BoxDecoration? backgroundDecoration,
    PageController? pageController,
    Function(int)? onPageChanged,
    int initialIndex = 0,
  }) {
    navi.pushPage(
        page: HSGalleryBuilder(
      images: images,
      initialIndex: initialIndex,
      type: type,
      backgroundDecoration: backgroundDecoration,
    ));
  }
}

class _HSGalleryCubit extends Cubit<int> {
  _HSGalleryCubit(super.initialIndex);

  void changePage(int index) => emit(index);
}

class HSGalleryBuilder extends StatelessWidget {
  final List<String> images;
  final HSImageGalleryType type;
  final BoxDecoration? backgroundDecoration;
  final PageController? pageController;
  final Function(int)? onPageChanged;
  final int initialIndex;

  const HSGalleryBuilder({
    super.key,
    required this.images,
    this.type = HSImageGalleryType.network,
    this.backgroundDecoration,
    this.pageController,
    this.onPageChanged,
    this.initialIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _HSGalleryCubit(initialIndex),
      child: _HSGalleryBuilder(
        images: images,
        type: type,
        backgroundDecoration: backgroundDecoration,
        pageController: pageController,
        onPageChanged: onPageChanged,
        initialIndex: initialIndex,
      ),
    );
  }
}

class _HSGalleryBuilder extends StatelessWidget {
  final List<String> images;
  final HSImageGalleryType type;
  final BoxDecoration? backgroundDecoration;
  final PageController? pageController;
  final Function(int)? onPageChanged;
  final int initialIndex;

  const _HSGalleryBuilder({
    required this.images,
    this.type = HSImageGalleryType.network,
    this.backgroundDecoration,
    this.pageController,
    this.onPageChanged,
    this.initialIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundDecoration?.color ??
          Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(FontAwesomeIcons.xmark),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  BlocBuilder<_HSGalleryCubit, int>(
                    builder: (context, state) {
                      return Text('${state + 1} / ${images.length}');
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: PhotoViewGallery.builder(
                scrollPhysics: const BouncingScrollPhysics(),
                builder: (BuildContext context, int index) {
                  final imageProvider = type == HSImageGalleryType.network
                      ? CachedNetworkImageProvider(images[index])
                      : AssetImage(images[index]) as ImageProvider;

                  return PhotoViewGalleryPageOptions(
                    imageProvider: imageProvider,
                    initialScale: PhotoViewComputedScale.contained,
                    minScale: PhotoViewComputedScale.contained,
                    maxScale: PhotoViewComputedScale.contained,
                    heroAttributes: PhotoViewHeroAttributes(tag: images[index]),
                  );
                },
                itemCount: images.length,
                loadingBuilder: (context, event) => Center(
                  child: SizedBox(
                    width: 20.0,
                    height: 20.0,
                    child: CircularProgressIndicator(
                      value: event == null
                          ? 0
                          : event.cumulativeBytesLoaded /
                              event.expectedTotalBytes!,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(appTheme.mainColor),
                    ),
                  ),
                ),
                backgroundDecoration: backgroundDecoration ??
                    BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor),
                pageController:
                    pageController ?? PageController(initialPage: initialIndex),
                onPageChanged: (index) {
                  context.read<_HSGalleryCubit>().changePage(index);
                  if (onPageChanged != null) {
                    onPageChanged!(index);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

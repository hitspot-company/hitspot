part of 'hs_gallery.dart';

class _ImageGalleryOverlay extends StatefulWidget {
  final List<String> images;
  final HSImageGalleryType type;
  final BoxDecoration? backgroundDecoration;
  final PageController? pageController;
  final Function(int)? onPageChanged;
  final int initialIndex;

  const _ImageGalleryOverlay({
    super.key,
    required this.images,
    required this.type,
    this.backgroundDecoration,
    this.pageController,
    this.onPageChanged,
    this.initialIndex = 0,
  });

  @override
  State<_ImageGalleryOverlay> createState() => _ImageGalleryOverlayState();
}

class _ImageGalleryOverlayState extends State<_ImageGalleryOverlay>
    with SingleTickerProviderStateMixin {
  double _dragOffset = 0.0;
  double _scale = 1.0;

  void close() {
    HSGallery._overlayEntry?.remove();
    HSGallery._overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragUpdate: (details) {
        setState(() {
          _dragOffset += details.delta.dy;
          _scale = 1.0 - (_dragOffset.abs() / 500.0);
        });
      },
      onVerticalDragEnd: (details) {
        if (_dragOffset.abs() > 150) {
          close();
        } else {
          setState(() {
            _dragOffset = 0.0;
            _scale = 1.0;
          });
        }
      },
      child: Stack(
        children: [
          Container(color: Colors.black.withOpacity(.9)),
          Center(
            child: Transform.translate(
              offset: Offset(0, _dragOffset),
              child: Transform.scale(
                scale: _scale,
                child: PhotoViewGallery.builder(
                  itemCount: widget.images.length,
                  builder: (context, index) {
                    return PhotoViewGalleryPageOptions(
                      imageProvider: widget.type == HSImageGalleryType.network
                          ? CachedNetworkImageProvider(widget.images[index])
                          : AssetImage(widget.images[index]) as ImageProvider,
                      initialScale: PhotoViewComputedScale.contained,
                      minScale: PhotoViewComputedScale.contained,
                      maxScale: PhotoViewComputedScale.covered * 2,
                    );
                  },
                  scrollPhysics: const BouncingScrollPhysics(),
                  backgroundDecoration:
                      const BoxDecoration(color: Colors.transparent),
                  pageController: widget.pageController ??
                      PageController(initialPage: widget.initialIndex),
                ),
              ),
            ),
          ),
          Positioned(
            top: 40,
            right: 20,
            child: IconButton(
              icon: const Icon(FontAwesomeIcons.xmark,
                  color: Colors.white, size: 30),
              onPressed: () {
                HSGallery._overlayEntry?.remove();
                HSGallery._overlayEntry = null;
              },
            ),
          ),
        ],
      ),
    );
  }
}

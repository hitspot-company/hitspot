import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class HSSpotTile extends StatelessWidget {
  const HSSpotTile({
    super.key,
    required this.index,
    this.extent,
    this.backgroundColor,
    this.bottomSpace,
  });

  final int index;
  final double? extent;
  final double? bottomSpace;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: _imgUrl(index),
      progressIndicatorBuilder: (context, url, progress) => _loadingWidget(),
      imageBuilder: (context, imageProvider) => ClipRRect(
        borderRadius: BorderRadius.circular(20.0),
        child: Container(
          height: extent,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.0),
            image: DecorationImage(
              image: imageProvider,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }

  Widget _loadingWidget() => ClipRRect(
        borderRadius: BorderRadius.circular(20.0),
        child: Container(
          height: extent,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.0),
            color: Colors.black.withOpacity(.04),
          ),
        ),
      );

  String _imgUrl(int index) {
    return "https://picsum.photos/40$index";
  }
}

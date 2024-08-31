import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/widgets/hs_user_avatar.dart';
import 'package:hitspot/widgets/shimmers/hs_shimmer_box.dart';
import 'package:hs_database_repository/hs_database_repository.dart';

class HSSpotTile extends StatelessWidget {
  const HSSpotTile({
    super.key,
    this.index,
    this.extent,
    this.backgroundColor,
    this.bottomSpace,
    this.spot,
    this.bottom,
    this.onTap,
    this.onLongPress,
  });

  final int? index;
  final double? extent;
  final double? bottomSpace;
  final Color? backgroundColor;
  final HSSpot? spot;
  final Widget? bottom;
  final VoidCallback? onTap;
  final Function(HSSpot spot)? onLongPress;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ??
          (spot?.sid != null ? () => navi.toSpot(sid: spot!.sid!) : null),
      onPanEnd: (drag) => onLongPress != null ? onLongPress!(spot!) : null,
      child: Column(
        children: [
          CachedNetworkImage(
            imageUrl:
                spot != null ? (spot!.thumbnails?[0] ?? spot!.images![0]) : "",
            progressIndicatorBuilder: (context, url, progress) =>
                _loadingWidget(),
            imageBuilder: (context, imageProvider) => Container(
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
          const Gap(16.0),
          if (bottom == null)
            SizedBox(
              child: Row(
                children: [
                  HSUserAvatar(
                    radius: 24.0,
                    iconSize: 16,
                    imageUrl: spot?.author?.avatarUrl,
                  ),
                  const Gap(8.0),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AutoSizeText(
                          spot!.title!,
                          maxLines: 2,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        AutoSizeText(
                          'by @${spot?.author?.username}',
                          maxLines: 1,
                          style: const TextStyle(
                            fontSize: 12.0,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            )
          else
            bottom!,
        ],
      ),
    );
  }

  Widget _loadingWidget() => ClipRRect(
      borderRadius: BorderRadius.circular(20.0),
      child: HSShimmerBox(
        height: extent,
        width: double.infinity,
      ));

  String _imgUrl(int index) {
    return "https://picsum.photos/40$index";
  }
}

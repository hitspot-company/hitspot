import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:hitspot/utils/theme/hs_theme.dart';
import 'package:hitspot/widgets/hs_image.dart';
import 'package:hitspot/widgets/shimmers/hs_shimmer_box.dart';
import 'package:hs_database_repository/hs_database_repository.dart';

class HSBetterSpotTile extends StatelessWidget {
  const HSBetterSpotTile(
      {super.key,
      this.spot,
      this.isLoading = false,
      this.width,
      this.height,
      this.borderRadius,
      this.padding,
      this.onTap,
      this.child,
      this.onLongPress});

  final HSSpot? spot;
  final bool isLoading;
  final double? width, height;
  final BorderRadius? borderRadius;
  final EdgeInsets? padding;
  final Function(HSSpot?)? onTap, onLongPress;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    if (isLoading || spot == null) {
      return HSShimmerBox(width: width, height: height);
    }
    return Padding(
      padding: padding ?? const EdgeInsets.all(0.0),
      child: AbsorbPointer(
        absorbing: onTap == null && onLongPress == null,
        child: GestureDetector(
          onTap: () {
            if (onTap != null) onTap!(spot);
          },
          onLongPress: () {
            if (onLongPress != null) onLongPress!(spot);
          },
          child: SizedBox(
            width: width,
            height: height,
            child: ClipRRect(
              borderRadius: borderRadius ?? BorderRadius.circular(0.0),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  HSImage(imageUrl: spot!.getThumbnail),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomLeft,
                        end: Alignment.topRight,
                        stops: const [0.0, .3, 1.0],
                        colors: [
                          Colors.black,
                          Colors.black.withOpacity(.6),
                          Colors.transparent
                        ],
                      ),
                    ),
                  ),
                  if (child == null)
                    Positioned(
                      bottom: 8.0,
                      right: 8.0,
                      left: 8.0,
                      child: AutoSizeText(
                        spot!.title!,
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge!
                            .colorify(Colors.white),
                        maxLines: 2,
                      ),
                    )
                  else
                    child!
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

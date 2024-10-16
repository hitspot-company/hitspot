import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/widgets/hs_user_avatar.dart';
import 'package:hitspot/widgets/shimmers/hs_shimmer_box.dart';
import 'package:hs_authentication_repository/hs_authentication_repository.dart';

class HSUserTile extends StatelessWidget {
  const HSUserTile(
      {super.key,
      required this.user,
      this.height = 60.0,
      this.avatarRadius = 24.0,
      this.onTap,
      this.contentPadding = const EdgeInsets.all(0.0),
      this.iconSize = 16.0});

  final HSUser user;
  final double height, avatarRadius, iconSize;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry contentPadding;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      // width: 100,
      child: CachedNetworkImage(
          imageUrl: user.avatarUrl ?? "",
          errorWidget: (context, url, error) => _MainTile(
              user: user,
              height: height,
              avatarRadius: avatarRadius,
              contentPadding: contentPadding,
              onTap: onTap,
              iconSize: iconSize),
          placeholder: (context, url) =>
              const HSShimmerBox(width: 60, height: 60),
          imageBuilder: (context, imageProvider) => _MainTile(
              user: user,
              height: height,
              avatarRadius: avatarRadius,
              contentPadding: contentPadding,
              onTap: onTap,
              iconSize: iconSize)),
    );
  }
}

class _MainTile extends StatelessWidget {
  const _MainTile(
      {required this.user,
      this.height = 60.0,
      this.avatarRadius = 24.0,
      this.onTap,
      this.contentPadding = const EdgeInsets.all(0.0),
      this.iconSize = 16.0});

  final HSUser user;
  final double height, avatarRadius, iconSize;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry contentPadding;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: contentPadding,
      onTap: onTap ?? () => navi.toUser(userID: user.uid!),
      leading: HSUserAvatar(
        radius: avatarRadius,
        iconSize: iconSize,
        imageUrl: user.avatarUrl,
      ),
      title: AutoSizeText(
        user.username!,
        maxLines: 1,
        style: const TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: AutoSizeText(
        user.name!,
        maxLines: 1,
        style: const TextStyle(
          fontSize: 12.0,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}

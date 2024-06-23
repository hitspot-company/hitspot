import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/widgets/hs_user_avatar.dart';
import 'package:hs_authentication_repository/hs_authentication_repository.dart';

class HsUserTile extends StatelessWidget {
  const HsUserTile(
      {super.key,
      required this.user,
      this.height = 60.0,
      this.avatarRadius = 24.0,
      this.onTap,
      this.iconSize = 16.0});

  final HSUser user;
  final double height, avatarRadius, iconSize;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: GestureDetector(
        onTap: onTap ?? () => navi.toUser(userID: user.uid!),
        child: Row(
          children: [
            HSUserAvatar(
              radius: avatarRadius,
              iconSize: iconSize,
              imageUrl: user.avatarUrl,
            ),
            const Gap(8.0),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AutoSizeText(
                  user.username!,
                  maxLines: 1,
                  style: const TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                AutoSizeText(
                  user.name!,
                  maxLines: 1,
                  style: const TextStyle(
                    fontSize: 12.0,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

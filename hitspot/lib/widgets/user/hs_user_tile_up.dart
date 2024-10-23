part of 'hs_user_widgets.dart';

class HSUserTileUp extends StatelessWidget {
  const HSUserTileUp(
      {super.key,
      required this.user,
      this.width,
      this.height,
      this.onTap,
      this.tileColor,
      this.textColor,
      this.title,
      this.subtitle,
      this.avatarRadius = 24.0,
      this.showLeading = true,
      this.bottom});

  final HSUser user;
  final double? width, height;
  final double avatarRadius;
  final Function()? onTap;
  final Color? tileColor, textColor;
  final String? title, subtitle;
  final bool showLeading;
  final Widget? bottom;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: CachedNetworkImage(
        imageUrl: user.avatarUrl ?? "",
        errorWidget: (context, url, error) => _Tile(
            user,
            avatarRadius,
            tileColor,
            textColor,
            title,
            subtitle,
            showLeading,
            bottom,
            false,
            onTap),
        placeholder: (context, url) => _Tile(
          user,
          avatarRadius,
          tileColor,
          textColor,
          title,
          subtitle,
          showLeading,
          bottom,
          true,
          onTap,
        ),
        imageBuilder: (context, imageProvider) => _Tile(
            user,
            avatarRadius,
            tileColor,
            textColor,
            title,
            subtitle,
            showLeading,
            bottom,
            false,
            onTap,
            imageProvider),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile(this.user, this.avatarRadius, this.tileColor, this.textColor,
      this.title, this.subtitle, this.showLeading, this.bottom,
      [this.isLoading = false, this.onTap, this.avatar]);

  final HSUser user;
  final ImageProvider? avatar;
  final double avatarRadius;
  final void Function()? onTap;
  final Color? tileColor, textColor;
  final String? title, subtitle;
  final bool showLeading;
  final Widget? bottom;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.all(0.0),
      tileColor: tileColor,
      onTap: onTap ?? () => navi.toUser(userID: user.uid!),
      leading: showLeading ? _buildAvatar(context) : null,
      title: AutoSizeText(
        title ?? user.username!,
        maxLines: 1,
        style: TextStyle(
          color: textColor,
        ),
      ),
      subtitle: AutoSizeText(
        subtitle ?? user.name!,
        maxLines: 1,
        style: TextStyle(
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildAvatar(BuildContext context) {
    if (isLoading) {
      return CircleAvatar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          radius: avatarRadius,
          child: HSShimmerCircleSkeleton(
            size: avatarRadius,
          ));
    }
    if (user.avatarUrl != null) {
      return CircleAvatar(radius: avatarRadius, backgroundImage: avatar);
    } else {
      return CircleAvatar(
        radius: avatarRadius,
        child: const Icon(Icons.person),
      );
    }
  }
}

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
      this.showLeading = true});

  final HSUser user;
  final double? width, height;
  final double avatarRadius;
  final Function()? onTap;
  final Color? tileColor, textColor;
  final String? title, subtitle;
  final bool showLeading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: CachedNetworkImage(
        imageUrl: user.avatarUrl ?? "",
        errorWidget: (context, url, error) => _Tile(user, avatarRadius,
            tileColor, textColor, title, subtitle, showLeading, onTap),
        placeholder: (context, url) =>
            HSShimmerBox(width: width, height: height),
        imageBuilder: (context, imageProvider) => _Tile(
            user,
            avatarRadius,
            tileColor,
            textColor,
            title,
            subtitle,
            showLeading,
            onTap,
            imageProvider),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile(this.user, this.avatarRadius, this.tileColor, this.textColor,
      this.title, this.subtitle, this.showLeading,
      [this.onTap, this.avatar]);

  final HSUser user;
  final ImageProvider? avatar;
  final double avatarRadius;
  final void Function()? onTap;
  final Color? tileColor, textColor;
  final String? title, subtitle;
  final bool showLeading;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      tileColor: tileColor,
      onTap: onTap ?? () => navi.toUser(userID: user.uid!),
      leading: showLeading ? _buildAvatar() : null,
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

  Widget _buildAvatar() {
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

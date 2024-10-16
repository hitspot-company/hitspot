part of 'hs_user_widgets.dart';

class HSUserTileUp extends StatelessWidget {
  const HSUserTileUp(
      {super.key,
      required this.user,
      this.width,
      this.height,
      this.onTap,
      this.avatarRadius = 24.0});

  final HSUser user;
  final double? width, height;
  final double avatarRadius;
  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: CachedNetworkImage(
        imageUrl: user.avatarUrl ?? "",
        errorWidget: (context, url, error) => _Tile(user, avatarRadius, onTap),
        placeholder: (context, url) =>
            HSShimmerBox(width: width, height: height),
        imageBuilder: (context, imageProvider) =>
            _Tile(user, avatarRadius, onTap, imageProvider),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile(this.user, this.avatarRadius, [this.onTap, this.avatar]);

  final HSUser user;
  final ImageProvider? avatar;
  final double avatarRadius;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: _buildAvatar(),
      title: Text(user.username!),
      subtitle: Text(user.name!),
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

part of 'single_spot_page.dart';

class _UserTile extends StatelessWidget {
  final double height;
  final double avatarRadius;
  final double iconSize;
  final HSUser user;

  const _UserTile({
    super.key,
    required this.height,
    required this.avatarRadius,
    required this.iconSize,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Row(
        mainAxisSize: MainAxisSize.max,
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
    );
  }
}

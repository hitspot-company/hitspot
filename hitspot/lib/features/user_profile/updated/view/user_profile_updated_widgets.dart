part of 'user_profile_page_updated.dart';

class _UserProfileUpdatedHeader extends StatelessWidget {
  const _UserProfileUpdatedHeader(this.user);

  final HSUser user;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          HSUserAvatar(radius: 60.0, imageUrl: user.avatarUrl)
              .animate()
              .fade()
              .scale(),
          const SizedBox(height: 16),
          Text(
            '@${user.username}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ).animate().fadeIn(delay: 300.ms),
          Text(
            user.name!,
            style: const TextStyle(fontSize: 16),
          ).animate().fadeIn(delay: 400.ms),
        ],
      ),
    );
  }
}

class _UserProfileUpdatedStatItem extends StatelessWidget {
  const _UserProfileUpdatedStatItem({required this.value, required this.label});

  final String value, label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class _UserProfileUpdatedBoardsBuilder extends StatelessWidget {
  const _UserProfileUpdatedBoardsBuilder(this.boards);

  final List<HSBoard> boards;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(8.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
      ),
      itemCount: boards.length,
      itemBuilder: (context, index) {
        final board = boards[index];
        return Card(
          clipBehavior: Clip.antiAlias,
          margin: EdgeInsets.zero,
          child: InkWell(
            onTap: () => navi.toBoard(boardID: board.id!, title: board.title!),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(4.0)),
                  child: CachedNetworkImage(
                    imageUrl: board.getThumbnail,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        board.title!,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        board.description!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.group, size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            "0 collaborators",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.remove_red_eye_outlined,
                              size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            board.visibility!.name,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ).animate().fadeIn(duration: const Duration(milliseconds: 300));
      },
    );
  }
}

class _UserProfileUpdatedSpotsBuilder extends StatelessWidget {
  const _UserProfileUpdatedSpotsBuilder(this.spots);

  final List<HSSpot> spots;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: spots.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
      ),
      itemBuilder: (context, index) {
        final spot = spots[index];
        return Card(
          clipBehavior: Clip.antiAlias,
          margin: EdgeInsets.zero,
          child: InkWell(
            onTap: () => navi.toSpot(sid: spot.sid!),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(4.0)),
                  child: CachedNetworkImage(
                    imageUrl: spot.getThumbnail,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        spot.title!,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.location_on,
                              size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              spot.address!,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.favorite,
                              size: 14, color: Colors.red),
                          const SizedBox(width: 4),
                          Text(
                            "${spot.likesCount} likes",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ).animate().fadeIn(duration: const Duration(milliseconds: 300));
      },
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}

class _UserProfileUpdatedBiogram extends StatelessWidget {
  const _UserProfileUpdatedBiogram(this.user);

  final HSUser user;

  @override
  Widget build(BuildContext context) {
    if (user.biogram == null || user.biogram!.isEmpty) {
      return const SizedBox.shrink().toSliver;
    }
    return SliverMainAxisGroup(slivers: [
      const SizedBox(height: 8).toSliver,
      Center(
        child: Text(
          user.biogram!,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(color: Colors.grey),
        ).animate().fadeIn(duration: 300.ms),
      ).toSliver,
    ]);
  }
}

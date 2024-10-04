import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/extensions/hs_sliver_extensions.dart';
import 'package:hitspot/features/notifications/cubit/hs_notifications_cubit.dart';
import 'package:hitspot/widgets/hs_appbar.dart';
import 'package:hitspot/widgets/hs_scaffold.dart';
import 'package:hitspot/widgets/hs_user_avatar.dart';
import 'package:badges/badges.dart' as badges;
import 'package:hitspot/widgets/shimmers/hs_shimmer_box.dart';
import 'package:hs_database_repository/hs_database_repository.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return HSScaffold(
      appBar: HSAppBar(
        titleText: "Notifications",
        enableDefaultBackButton: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<HSNotificationsCubit, HSNotificationsState>(
              builder: (context, state) {
                if (state.status == HSNotificationsStatus.loading) {
                  return const _LoadingView();
                } else if (state.status == HSNotificationsStatus.loaded) {
                  return _LoadedView(state: state);
                } else {
                  return const Center(
                    child: Text("Error loading notifications"),
                  );
                }
              },
            ),
          ),
          const Gap(16.0),
        ],
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: HSShimmerBox(width: screenWidth, height: 60.0),
            ),
            childCount: 3,
          ),
        ),
      ],
    );
  }
}

class _LoadedView extends StatelessWidget {
  final HSNotificationsState state;

  const _LoadedView({required this.state});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<HSNotificationsCubit>();
    final announcements = state.announcements;
    final notifications = state.notifications;
    final bool isEmpty = announcements.isEmpty && notifications.isEmpty;
    return CustomScrollView(
      slivers: [
        if (isEmpty)
          const SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(FontAwesomeIcons.bellSlash, size: 64.0),
                  Gap(16.0),
                  Text("No notifications yet"),
                ],
              ),
            ),
          ),
        if (cubit.state.announcements.isNotEmpty)
          SliverMainAxisGroup(
            slivers: [
              SliverList(
                delegate: SliverChildListDelegate([
                  Text("Announcements",
                      style: Theme.of(context).textTheme.headlineMedium),
                  const Gap(16.0),
                ]),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final announcement = state.announcements[index];
                    return ListTile(
                      onTap: () => cubit.openAnnouncement(announcement),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      title: Text(announcement.announcementType!.name,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(announcement.title!),
                      trailing: !announcement.isRead
                          ? const badges.Badge(
                              child: Icon(FontAwesomeIcons.bullhorn))
                          : const Icon(FontAwesomeIcons.bullhorn),
                    );
                  },
                  childCount: state.announcements.length,
                ),
              ),
              const Gap(32.0).toSliver,
            ],
          ),
        if (cubit.state.notifications.isNotEmpty)
          SliverMainAxisGroup(slivers: [
            SliverList(
              delegate: SliverChildListDelegate([
                Text("Notifications",
                    style: Theme.of(context).textTheme.headlineMedium),
                const Gap(16.0),
              ]),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final notification = state.notifications[index];
                  return ListTile(
                    contentPadding: const EdgeInsets.all(0.0),
                    onTap: () => cubit.openNotification(notification),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    leading: HSUserAvatar(
                      onTap: () => navi.toUser(userID: notification.from!),
                      radius: 24,
                      imageUrl: notification.fromUser?.avatarUrl,
                    ),
                    title: Text(notification.title,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: AutoSizeText.rich(
                      TextSpan(
                        children: [
                          TextSpan(text: notification.body),
                          TextSpan(
                              text: "\n• ${notification.createdAt!.timeAgo}",
                              style: const TextStyle(fontSize: 14.0)),
                        ],
                      ),
                      maxLines: 2,
                    ),
                    trailing: !notification.isRead
                        ? badges.Badge(
                            child: Icon(notification.icon, color: Colors.grey))
                        : Icon(notification.icon, color: Colors.grey),
                  );
                },
                childCount: state.notifications.length,
              ),
            ),
          ]),
      ],
    );
  }
}

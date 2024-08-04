import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/features/notifications/cubit/hs_notifications_cubit.dart';
import 'package:hitspot/widgets/hs_appbar.dart';
import 'package:hitspot/widgets/hs_scaffold.dart';
import 'package:hitspot/widgets/hs_user_avatar.dart';
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
      body: const Column(
        children: [
          Gap(16.0),
          _AnnouncementTiles(),
          Gap(16.0),
          Expanded(child: _ReadyTiles()),
        ],
      ),
    );
  }
}

class _AnnouncementTiles extends StatelessWidget {
  const _AnnouncementTiles();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HSNotificationsCubit, HSNotificationsState>(
      buildWhen: (previous, current) =>
          previous.status != current.status ||
          previous.announcements != current.announcements,
      builder: (context, state) {
        final announcements = state.announcements;
        final isLoading = state.status == HSNotificationsStatus.loading;
        if (isLoading) {
          return ListView.separated(
            shrinkWrap: true,
            itemCount: 3,
            separatorBuilder: (BuildContext context, int index) {
              return const Gap(16.0);
            },
            itemBuilder: (BuildContext context, int index) {
              return HSShimmerBox(width: screenWidth, height: 60.0);
            },
          );
        }
        return ListView.separated(
          shrinkWrap: true,
          itemCount: announcements.length,
          separatorBuilder: (BuildContext context, int index) {
            return const Gap(16.0);
          },
          itemBuilder: (BuildContext context, int index) {
            final announcement = announcements[index];
            return ListTile(
              // onTap: () => cubit.openNotification(notification), // TODO Open dialog with more
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              tileColor: Colors.grey.shade900,
              title: Text(announcement.announcementType!.name,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(announcement.title!),
              trailing: const Icon(FontAwesomeIcons.bullhorn),
            );
          },
        );
      },
    );
  }
}

class _ReadyTiles extends StatelessWidget {
  const _ReadyTiles();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<HSNotificationsCubit>();
    return BlocBuilder<HSNotificationsCubit, HSNotificationsState>(
      builder: (context, state) {
        if (state.status == HSNotificationsStatus.loading) {
          return const _LoadingTiles();
        } else if (state.status == HSNotificationsStatus.loaded) {
          final notifications = state.notifications;
          return Column(
            children: [
              Text("Notifications", style: textTheme.headlineMedium),
              const Gap(16.0),
              Expanded(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: notifications.length,
                  separatorBuilder: (BuildContext context, int index) {
                    return const Gap(16.0);
                  },
                  itemBuilder: (BuildContext context, int index) {
                    final notification = notifications[index];
                    return ListTile(
                      onTap: () => cubit.openNotification(notification),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      tileColor: Colors.grey.shade900,
                      leading: HSUserAvatar(
                          onTap: () => navi.toUser(userID: notification.from!),
                          radius: 24,
                          imageUrl: notification.fromUser?.avatarUrl),
                      title: Text(notification.title,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: AutoSizeText.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: notification.body,
                              style: const TextStyle(
                                color: Colors.white,
                              ),
                            ),
                            TextSpan(
                              text: "\n• ${notification.createdAt!.timeAgo}",
                              style: const TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        maxLines: 2,
                      ),
                      trailing: Icon(notification.icon),
                    );
                  },
                ),
              ),
            ],
          );
        } else {
          return const Center(
            child: Text("Error loading notifications"),
          );
        }
      },
    );
  }
}

class _LoadingTiles extends StatelessWidget {
  const _LoadingTiles();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      itemCount: 10,
      separatorBuilder: (BuildContext context, int index) {
        return const Gap(16.0);
      },
      itemBuilder: (BuildContext context, int index) {
        return HSShimmerBox(
          width: screenWidth,
          height: 60.0,
        );
      },
    );
  }
}

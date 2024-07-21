import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/features/notifications/cubit/hs_notifications_cubit.dart';
import 'package:hitspot/widgets/hs_appbar.dart';
import 'package:hitspot/widgets/hs_scaffold.dart';
import 'package:hitspot/widgets/hs_user_avatar.dart';
import 'package:hitspot/widgets/shimmers/hs_shimmer_box.dart';

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
          Expanded(
            child: _ReadyTiles(),
          ),
        ],
      ),
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
          return ListView.separated(
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
                subtitle: Text.rich(TextSpan(
                  children: [
                    TextSpan(
                      text: notification.body,
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    TextSpan(
                      text: "\n• ${notification.timeAgo}",
                      style: const TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                )),
                trailing: Icon(notification.icon),
                isThreeLine: true,
              );
            },
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

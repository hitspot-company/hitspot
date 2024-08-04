part of 'hs_notifications_cubit.dart';

enum HSNotificationsStatus { initial, loading, loaded, error }

final class HSNotificationsState extends Equatable {
  const HSNotificationsState({
    this.notifications = const [],
    this.announcements = const [],
    this.status = HSNotificationsStatus.initial,
  });

  final List<HSNotification> notifications;
  final List<HSAnnouncement> announcements;
  final HSNotificationsStatus status;

  @override
  List<Object> get props => [notifications, status, announcements];

  HSNotificationsState copyWith(
      {List<HSNotification>? notifications,
      List<HSAnnouncement>? announcements,
      HSNotificationsStatus? status}) {
    return HSNotificationsState(
        notifications: notifications ?? this.notifications,
        announcements: announcements ?? this.announcements,
        status: status ?? this.status);
  }
}

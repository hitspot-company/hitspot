part of 'hs_notifications_cubit.dart';

enum HSNotificationsStatus { initial, loading, loaded, error }

final class HSNotificationsState extends Equatable {
  const HSNotificationsState(
      {this.notifications = const [],
      this.status = HSNotificationsStatus.initial});

  final List<HSNotification> notifications;
  final HSNotificationsStatus status;

  @override
  List<Object> get props => [notifications, status];

  HSNotificationsState copyWith(
      {List<HSNotification>? notifications, HSNotificationsStatus? status}) {
    return HSNotificationsState(
        notifications: notifications ?? this.notifications,
        status: status ?? this.status);
  }
}

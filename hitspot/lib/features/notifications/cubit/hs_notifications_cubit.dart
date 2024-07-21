import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hs_database_repository/hs_database_repository.dart';
import 'package:hs_debug_logger/hs_debug_logger.dart';

part 'hs_notifications_state.dart';

class HSNotificationsCubit extends Cubit<HSNotificationsState> {
  HSNotificationsCubit() : super(const HSNotificationsState()) {
    _init();
  }

  final _databaseRepository = app.databaseRepository;

  void _init() {
    try {
      _fetchNotifications();
    } catch (_) {
      emit(state.copyWith(status: HSNotificationsStatus.error));
      HSDebugLogger.logError("HSNotificationsCubit: Error in _init");
    }
  }

  Future<void> _fetchNotifications() async {
    try {
      emit(state.copyWith(status: HSNotificationsStatus.loading));
      List<HSNotification> notifications = await _databaseRepository
          .notificationReadUserNotifications(currentUser: currentUser);
      HSDebugLogger.logSuccess("HSNotificationsCubit: Notifications fetched");
      emit(state.copyWith(
          notifications: notifications, status: HSNotificationsStatus.loaded));
    } catch (_) {
      emit(state.copyWith(status: HSNotificationsStatus.error));
      HSDebugLogger.logError(
          "HSNotificationsCubit: Error in _fetchNotifications");
    }
  }

  void openNotification(HSNotification notification) {
    try {
      final type = notification.type;
      if (type == HSNotificationType.spotlike ||
          type == HSNotificationType.spotcomment) {
        navi.toSpot(sid: notification.spotID!);
      } else if (type == HSNotificationType.boardlike ||
          type == HSNotificationType.boardinvitation) {
        navi.toBoard(boardID: notification.boardID!, title: "");
      } else if (type == HSNotificationType.userfollow) {
        navi.toUser(userID: notification.from!);
      }
    } catch (_) {
      emit(state.copyWith(status: HSNotificationsStatus.error));
      HSDebugLogger.logError("HSNotificationsCubit: Error in openNotification");
    }
  }
}

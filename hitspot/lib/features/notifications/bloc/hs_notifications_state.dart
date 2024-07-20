part of 'hs_notifications_bloc.dart';

sealed class HsNotificationsState extends Equatable {
  const HsNotificationsState();
  
  @override
  List<Object> get props => [];
}

final class HsNotificationsInitial extends HsNotificationsState {}

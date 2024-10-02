part of 'hs_user_profile_multiple_cubit.dart';

enum HSUserProfileMultipleStatus { initial, loading, loaded, error }

enum HSUserProfileMultipleType { follows, likes, collaborators }

final class HsUserProfileMultipleState extends Equatable {
  const HsUserProfileMultipleState(
      {this.status = HSUserProfileMultipleStatus.initial,
      this.users = const []});

  final HSUserProfileMultipleStatus status;
  final List<HSUser> users;

  @override
  List<Object> get props => [status, users];

  HsUserProfileMultipleState copyWith({
    HSUserProfileMultipleStatus? status,
    List<HSUser>? users,
  }) {
    return HsUserProfileMultipleState(
      status: status ?? this.status,
      users: users ?? this.users,
    );
  }
}

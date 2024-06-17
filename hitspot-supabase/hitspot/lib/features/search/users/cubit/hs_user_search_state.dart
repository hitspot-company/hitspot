part of 'hs_user_search_cubit.dart';

enum HSUserSearchStatus { initial, loading, loaded, error }

final class HSUserSearchState extends Equatable {
  const HSUserSearchState(
      {this.status = HSUserSearchStatus.initial, this.users = const []});

  final HSUserSearchStatus status;
  final List<HSUser> users;

  @override
  List<Object> get props => [status, users];

  HSUserSearchState copyWith({
    HSUserSearchStatus? status,
    List<HSUser>? users,
  }) {
    return HSUserSearchState(
      status: status ?? this.status,
      users: users ?? this.users,
    );
  }
}

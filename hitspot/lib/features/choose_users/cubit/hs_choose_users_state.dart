part of 'hs_choose_users_cubit.dart';

enum HSChooseUsersStatus { idle, fetching, error }

final class HSChooseUsersState extends Equatable {
  const HSChooseUsersState(
      {this.query = "",
      this.chooseUsersStatus = HSChooseUsersStatus.idle,
      this.result = const []});

  final String query;
  final HSChooseUsersStatus chooseUsersStatus;
  final List result;

  HSChooseUsersState copyWith({
    String? query,
    HSChooseUsersStatus? chooseUsersStatus,
    List? result,
  }) {
    return HSChooseUsersState(
      query: query ?? this.query,
      chooseUsersStatus: chooseUsersStatus ?? this.chooseUsersStatus,
      result: result ?? this.result,
    );
  }

  @override
  List<Object> get props => [query, chooseUsersStatus, result];
}

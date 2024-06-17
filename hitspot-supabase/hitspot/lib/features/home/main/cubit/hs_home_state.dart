part of 'hs_home_cubit.dart';

enum HSHomeStatus { loading, idle, error, refreshing }

final class HSHomeState extends Equatable {
  const HSHomeState({
    this.status = HSHomeStatus.loading,
    this.tredingBoards = const [],
  });

  final HSHomeStatus status;
  final List<HSBoard> tredingBoards;

  @override
  List<Object> get props => [status, tredingBoards];

  HSHomeState copyWith({
    HSHomeStatus? status,
    List<HSBoard>? tredingBoards,
  }) {
    return HSHomeState(
      status: status ?? this.status,
      tredingBoards: tredingBoards ?? this.tredingBoards,
    );
  }
}

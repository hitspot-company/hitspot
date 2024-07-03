part of 'hs_map_search_cubit.dart';

final class HsMapSearchState extends Equatable {
  const HsMapSearchState({
    this.query = "",
    this.spots = const [],
    this.boards = const [],
    this.users = const [],
  });

  final String query;
  final List<HSSpot> spots;
  final List<HSBoard> boards;
  final List<HSUser> users;

  @override
  List<Object> get props => [query, spots, boards, users];

  HsMapSearchState copyWith({
    String? query,
    List<HSSpot>? spots,
    List<HSBoard>? boards,
    List<HSUser>? users,
  }) {
    return HsMapSearchState(
      query: query ?? this.query,
      spots: spots ?? this.spots,
      boards: boards ?? this.boards,
      users: users ?? this.users,
    );
  }
}

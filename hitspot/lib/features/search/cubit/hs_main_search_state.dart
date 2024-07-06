part of 'hs_main_search_cubit.dart';

final class HSMainSearchState extends Equatable {
  const HSMainSearchState({
    this.query = "",
    this.spots = const [],
    this.boards = const [],
    this.users = const [],
    this.tags = const [],
  });

  final String query;
  final List<HSSpot> spots;
  final List<HSBoard> boards;
  final List<HSUser> users;
  final List<HSTag> tags;

  @override
  List<Object> get props => [query, spots, boards, users, tags];

  HSMainSearchState copyWith({
    String? query,
    List<HSSpot>? spots,
    List<HSBoard>? boards,
    List<HSUser>? users,
    List<HSTag>? tags,
  }) {
    return HSMainSearchState(
      query: query ?? this.query,
      spots: spots ?? this.spots,
      boards: boards ?? this.boards,
      users: users ?? this.users,
      tags: tags ?? this.tags,
    );
  }
}

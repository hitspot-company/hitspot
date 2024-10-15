// part of 'hs_main_search_cubit.dart';

// enum HSMainSearchStatus { initial, loading, loaded, error }

// final class HSMainSearchState extends Equatable {
//   const HSMainSearchState({
//     this.query = "",
//     this.spots = const [],
//     this.trendingSpots = const [],
//     this.boards = const [],
//     this.users = const [],
//     this.tags = const [],
//     this.status = HSMainSearchStatus.initial,
//     this.trendingBoards = const [],
//     this.trendingUsers = const [],
//     this.trendingTags = const [],
//   });

//   final String query;
//   final List<HSSpot> spots, trendingSpots;
//   final List<HSBoard> boards, trendingBoards;
//   final List<HSUser> users, trendingUsers;
//   final List<HSTag> tags, trendingTags;
//   final HSMainSearchStatus status;

//   @override
//   List<Object> get props => [
//         query,
//         spots,
//         boards,
//         users,
//         tags,
//         trendingSpots,
//         status,
//         trendingBoards,
//         trendingUsers,
//         trendingTags
//       ];

//   HSMainSearchState copyWith({
//     String? query,
//     List<HSSpot>? spots,
//     List<HSSpot>? trendingSpots,
//     List<HSBoard>? boards,
//     List<HSUser>? users,
//     List<HSTag>? tags,
//     List<HSBoard>? trendingBoards,
//     List<HSUser>? trendingUsers,
//     List<HSTag>? trendingTags,
//     HSMainSearchStatus? status,
//   }) {
//     return HSMainSearchState(
//       query: query ?? this.query,
//       spots: spots ?? this.spots,
//       boards: boards ?? this.boards,
//       users: users ?? this.users,
//       tags: tags ?? this.tags,
//       status: status ?? this.status,
//       trendingSpots: trendingSpots ?? this.trendingSpots,
//       trendingBoards: trendingBoards ?? this.trendingBoards,
//       trendingUsers: trendingUsers ?? this.trendingUsers,
//       trendingTags: trendingTags ?? this.trendingTags,
//     );
//   }
// }

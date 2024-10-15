// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:gap/gap.dart';
// import 'package:hitspot/constants/constants.dart';
// import 'package:hitspot/features/saved/cubit/hs_saved_cubit.dart';
// import 'package:hitspot/widgets/hs_icon_prompt.dart';
// import 'package:hitspot/widgets/hs_image.dart';
// import 'package:hitspot/widgets/hs_search_bar.dart';
// import 'package:hitspot/widgets/shimmers/hs_shimmer_box.dart';
// import 'package:hitspot/widgets/spot/hs_animated_spot_tile.dart';
// import 'package:hs_database_repository/hs_database_repository.dart';
// import 'package:hs_debug_logger/hs_debug_logger.dart';

// class SavedPage extends StatelessWidget {
//   const SavedPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     HSSavedCubit savedCubit = context.read<HSSavedCubit>();

//     void _onScroll(ScrollNotification scrollNotification) {
//       // Check if we reached the end of any scrollable content
//       if (scrollNotification.metrics.pixels ==
//           scrollNotification.metrics.maxScrollExtent) {
//         savedCubit.fetchMoreContent();
//         HSDebugLogger.logInfo("Fetching more saved content!");
//       }
//     }

//     return DefaultTabController(
//       length: 3,
//       child: Scaffold(
//         appBar: AppBar(
//           title: const Text('Saved'),
//           bottom: const TabBar(
//             indicatorPadding: EdgeInsets.only(bottom: 6.0),
//             tabs: [
//               Tab(text: 'Your Boards'),
//               Tab(text: 'Saved Boards'),
//               Tab(text: 'Saved Spots'),
//             ],
//           ),
//         ),
//         body: NotificationListener<ScrollNotification>(
//           onNotification: (scrollNotification) {
//             if (scrollNotification is ScrollEndNotification) {
//               _onScroll(scrollNotification);
//             }
//             return false;
//           },
//           child: TabBarView(
//             physics: const NeverScrollableScrollPhysics(),
//             children: [
//               _OwnBoardsBuilder(
//                 controller: savedCubit.state.textEditingController,
//               ),
//               _SavedBoardsBuilder(
//                 controller: savedCubit.state.textEditingController,
//               ),
//               _SpotsBuilder(
//                 controller: savedCubit.state.textEditingController,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// enum _LoadingBuilderType { list, grid }

// class _LoadingBuilder extends StatelessWidget {
//   const _LoadingBuilder({this.type = _LoadingBuilderType.list});

//   final _LoadingBuilderType type;

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: type == _LoadingBuilderType.list
//           ? ListView.separated(
//               itemCount: 4,
//               separatorBuilder: (BuildContext context, int index) {
//                 return const Gap(16.0);
//               },
//               itemBuilder: (BuildContext context, int index) {
//                 return HSShimmerBox(height: 80.0, width: screenWidth);
//               },
//             )
//           : GridView.builder(
//               gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: 2,
//                 childAspectRatio: 1.0,
//               ),
//               itemCount: 4,
//               itemBuilder: (BuildContext context, int index) {
//                 return HSShimmerBox(height: 80.0, width: screenWidth);
//               },
//             ),
//     );
//   }
// }

// class _SavedBoardsBuilder extends StatelessWidget {
//   const _SavedBoardsBuilder({required this.controller});

//   final TextEditingController controller;

//   @override
//   Widget build(BuildContext context) {
//     final cubit = context.read<HSSavedCubit>();

//     return RefreshIndicator(
//       onRefresh: cubit.refresh,
//       child: BlocBuilder<HSSavedCubit, HSSavedState>(
//         buildWhen: (previous, current) =>
//             previous.searchedSavedBoardsResults !=
//                 current.searchedSavedBoardsResults ||
//             previous.status != current.status,
//         builder: (context, state) {
//           return Column(
//             children: [
//               _SearchBar(controller: controller),
//               Expanded(
//                 child: _buildBoardsContent(state),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildBoardsContent(HSSavedState state) {
//     if (state.status == HSSavedStatus.loading) {
//       return const _LoadingBuilder();
//     }

//     if (state.savedBoards.isEmpty) {
//       return const HSIconPrompt(
//         useWithRefresh: true,
//         message: "No saved boards",
//         iconData: FontAwesomeIcons.bookmark,
//       );
//     }

//     return _BoardsBuilder(boards: state.searchedSavedBoardsResults);
//   }
// }

// class _OwnBoardsBuilder extends StatelessWidget {
//   const _OwnBoardsBuilder({required this.controller});

//   final TextEditingController controller;

//   @override
//   Widget build(BuildContext context) {
//     final cubit = context.read<HSSavedCubit>();

//     return RefreshIndicator(
//       onRefresh: cubit.refresh,
//       child: BlocBuilder<HSSavedCubit, HSSavedState>(
//         buildWhen: (previous, current) =>
//             previous.searchedBoardsResults != current.searchedBoardsResults ||
//             previous.status != current.status,
//         builder: (context, state) {
//           // Search bar always shown
//           return Column(
//             children: [
//               _SearchBar(controller: controller),
//               Expanded(
//                 child: _buildBoardsContent(state),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildBoardsContent(HSSavedState state) {
//     if (state.status == HSSavedStatus.loading) {
//       return const _LoadingBuilder();
//     }

//     if (state.ownBoards.isEmpty) {
//       return const HSIconPrompt(
//         useWithRefresh: true,
//         message: "You don't have any boards",
//         iconData: FontAwesomeIcons.bookmark,
//       );
//     }

//     return _BoardsBuilder(boards: state.searchedBoardsResults);
//   }
// }

// class _BoardsBuilder extends StatelessWidget {
//   const _BoardsBuilder({
//     required this.boards,
//   });

//   final List<HSBoard> boards;

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(4.0),
//       child: ListView.separated(
//         itemCount: boards.length,
//         separatorBuilder: (BuildContext context, int index) {
//           return const Gap(16.0);
//         },
//         itemBuilder: (BuildContext context, int index) {
//           final board = boards[index];
//           return ListTile(
//             onTap: () => navi.toBoard(boardID: board.id!, title: board.title!),
//             leading: AspectRatio(
//                 aspectRatio: 1.0,
//                 child: HSImage(
//                   imageUrl: boards[index].getThumbnail,
//                   borderRadius: BorderRadius.circular(10.0),
//                 )),
//             title: Text(board.title!),
//             subtitle: Text(board.description!),
//           );
//         },
//       ),
//     );
//   }
// }

// class _SpotsBuilder extends StatelessWidget {
//   const _SpotsBuilder({required this.controller});
//   final TextEditingController controller;

//   @override
//   Widget build(BuildContext context) {
//     final HSSavedCubit cubit = context.read<HSSavedCubit>();
//     return RefreshIndicator(
//       onRefresh: cubit.refresh,
//       child: BlocBuilder<HSSavedCubit, HSSavedState>(
//         buildWhen: (previous, current) =>
//             previous.searchedSavedSpotsResults !=
//                 current.searchedSavedSpotsResults ||
//             previous.status != current.status,
//         builder: (context, state) {
//           return Column(
//             children: [
//               _SearchBar(
//                 controller: controller,
//               ),
//               Expanded(
//                 child: _buildSpotsContent(state),
//               ),
//               if (cubit.state.status == HSSavedStatus.fetchingMoreContent)
//                 const CircularProgressIndicator.adaptive(),
//             ],
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildSpotsContent(HSSavedState state) {
//     if (state.status == HSSavedStatus.loading) {
//       return const _LoadingBuilder(type: _LoadingBuilderType.grid);
//     }

//     if (state.searchedSavedSpotsResults.isEmpty) {
//       return const HSIconPrompt(
//         useWithRefresh: true,
//         message: "No saved spots",
//         iconData: FontAwesomeIcons.bookmark,
//       );
//     }

//     final spots = state.searchedSavedSpotsResults;
//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: GridView.builder(
//         gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//           crossAxisCount: 2,
//           childAspectRatio: 1.0,
//           crossAxisSpacing: 16.0,
//           mainAxisSpacing: 16.0,
//         ),
//         itemCount: spots.length,
//         itemBuilder: (BuildContext context, int index) {
//           final spot = spots[index];
//           return AnimatedSpotTile(spot: spot, index: index);
//         },
//       ),
//     );
//   }
// }

// class _SearchBar extends StatelessWidget {
//   const _SearchBar({required this.controller});
//   final TextEditingController controller;

//   @override
//   Widget build(BuildContext context) {
//     final HSSavedCubit searchCubit = context.read<HSSavedCubit>();

//     return Padding(
//       padding: const EdgeInsets.all(12.0),
//       child: HSSearchBar(
//           initialValue: searchCubit.state.query,
//           height: 50.0,
//           onChanged: (value) => searchCubit.updateQuery(value),
//           controller: controller),
//     );
//   }
// }

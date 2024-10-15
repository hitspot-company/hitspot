part of 'main_search_delegate.dart';

class _FetchedBoardsPage extends StatefulWidget {
  const _FetchedBoardsPage({required this.mapSearchCubit, required this.query});

  final HSMainSearchCubit mapSearchCubit;
  final String query;

  @override
  State<_FetchedBoardsPage> createState() => _FetchedBoardsPageState();
}

class _FetchedBoardsPageState extends State<_FetchedBoardsPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final state = widget.mapSearchCubit.state;

    if (widget.mapSearchCubit.isLoading) {
      return const HSLoadingWidget(
        type: HSLoadingWidgetType.grid,
      );
    }
    final List<HSBoard> boards = state.boards;
    final List<HSBoard> trendingBoards = state.trendingBoards;
    if (widget.query.isEmpty) {
      return _AnimatedBoardsBuilder(boards: trendingBoards);
    }
    if (widget.query.isNotEmpty && state.boards.isEmpty) {
      return CustomScrollView(
        shrinkWrap: true,
        slivers: [
          HSTextPrompt(
                  prompt: "No boards found for ",
                  pressableText: widget.query,
                  promptColor: app.theme.mainColor,
                  onTap: null)
              .toSliver,
          const Gap(16.0).toSliver,
          Text(
            "Maybe you will like these boards instead",
            style: Theme.of(context).textTheme.headlineSmall,
          ).toSliver,
          const Gap(16.0).toSliver,
          SliverFillRemaining(
              child: _AnimatedBoardsBuilder(boards: trendingBoards)),
        ],
      );
    }
    return _AnimatedBoardsBuilder(boards: boards);
  }
}

class _AnimatedBoardsBuilder extends StatelessWidget {
  const _AnimatedBoardsBuilder({
    required this.boards,
  });

  final List<HSBoard> boards;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: boards.length,
      itemBuilder: (BuildContext context, int index) {
        return AnimatedBoardTile(board: boards[index], index: index);
      },
    );
  }
}

class AnimatedBoardTile extends StatelessWidget {
  const AnimatedBoardTile(
      {super.key, required this.board, required this.index});

  final HSBoard board;
  final int index;

  @override
  Widget build(BuildContext context) {
    return HSBoardGridItem(board: board)
        .animate()
        .fadeIn(duration: 300.ms, delay: (50 * index).ms)
        .scale(
            begin: const Offset(0.8, 0.8),
            end: const Offset(1, 1),
            duration: 300.ms,
            curve: Curves.easeOutQuad);
  }
}

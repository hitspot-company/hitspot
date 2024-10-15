part of 'main_search_delegate.dart';

class _FetchedSpotsPage extends StatefulWidget {
  const _FetchedSpotsPage({required this.mapSearchCubit, required this.query});

  final HSMainSearchCubit mapSearchCubit;
  final String query;

  @override
  State<_FetchedSpotsPage> createState() => _FetchedSpotsPageState();
}

class _FetchedSpotsPageState extends State<_FetchedSpotsPage>
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
    final List<HSSpot> trendingSpots = state.trendingSpots;
    if (widget.query.isEmpty) {
      return _AnimatedSpotsBuilder(spots: trendingSpots);
    }
    if (widget.query.isNotEmpty && state.spots.isEmpty) {
      return CustomScrollView(
        shrinkWrap: true,
        slivers: [
          HSTextPrompt(
                  prompt: "No spots found for ",
                  pressableText: widget.query,
                  promptColor: app.theme.mainColor,
                  onTap: null)
              .toSliver,
          const Gap(16.0).toSliver,
          Text(
            "Maybe you will like these spots instead",
            style: Theme.of(context).textTheme.headlineSmall,
          ).toSliver,
          const Gap(16.0).toSliver,
          SliverFillRemaining(
              child: _AnimatedSpotsBuilder(spots: trendingSpots)),
        ],
      );
    }
    final List<HSSpot> spots = state.spots;
    return _AnimatedSpotsBuilder(spots: spots);
  }
}

class _AnimatedSpotsBuilder extends StatelessWidget {
  const _AnimatedSpotsBuilder({
    required this.spots,
  });

  final List<HSSpot> spots;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.85,
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
      ),
      itemCount: spots.length,
      itemBuilder: (BuildContext context, int index) {
        return AnimatedSpotTile(
          spot: spots[index],
          index: index,
        );
      },
    );
  }
}

part of 'main_search_delegate.dart';

class _FetchedTagsPage extends StatefulWidget {
  const _FetchedTagsPage({required this.mapSearchCubit, required this.query});

  final HSMainSearchCubit mapSearchCubit;
  final String query;

  @override
  State<_FetchedTagsPage> createState() => _FetchedTagsPageState();
}

class _FetchedTagsPageState extends State<_FetchedTagsPage>
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
    final List<HSTag> trendingTags = state.trendingTags;
    if (widget.query.isEmpty) {
      return _AnimatedTagsBuilder(tags: trendingTags);
    }
    if (widget.query.isNotEmpty && state.tags.isEmpty) {
      return CustomScrollView(
        shrinkWrap: true,
        slivers: [
          HSTextPrompt(
                  prompt: "No tags found for ",
                  pressableText: widget.query,
                  promptColor: app.theme.mainColor,
                  onTap: null)
              .toSliver,
          const Gap(16.0).toSliver,
          Text(
            "Maybe you will like these tags instead",
            style: Theme.of(context).textTheme.headlineSmall,
          ).toSliver,
          const Gap(16.0).toSliver,
          SliverFillRemaining(child: _AnimatedTagsBuilder(tags: trendingTags)),
        ],
      );
    }
    final List<HSTag> tags = state.tags;
    return _AnimatedTagsBuilder(tags: tags);
  }
}

class _AnimatedTagsBuilder extends StatelessWidget {
  const _AnimatedTagsBuilder({
    required this.tags,
  });

  final List<HSTag> tags;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.5,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
      ),
      itemCount: tags.length,
      itemBuilder: (BuildContext context, int index) {
        return _AnimatedTagTile(tag: tags[index], index: index);
      },
    );
  }
}

class _AnimatedTagTile extends StatelessWidget {
  const _AnimatedTagTile({required this.tag, required this.index});

  final HSTag tag;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: () => navi.toTagsExplore(tag.value!),
        child: Center(
          child: ListTile(
            title: AutoSizeText(tag.value!,
                style: const TextStyle(fontWeight: FontWeight.bold),
                maxLines: 1),
            leading: const Icon(FontAwesomeIcons.hashtag),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms, delay: (50 * index).ms).scale(
        begin: const Offset(0.8, 0.8),
        end: const Offset(1, 1),
        duration: 300.ms,
        curve: Curves.easeOutQuad);
  }
}

part of 'main_search_delegate.dart';

class _FetchedUsersPage extends StatefulWidget {
  const _FetchedUsersPage({required this.mapSearchCubit, required this.query});

  final HSMainSearchCubit mapSearchCubit;
  final String query;

  @override
  State<_FetchedUsersPage> createState() => _FetchedUsersPageState();
}

class _FetchedUsersPageState extends State<_FetchedUsersPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final state = widget.mapSearchCubit.state;

    if (widget.mapSearchCubit.isLoading) {
      return const HSLoadingWidget(type: HSLoadingWidgetType.list);
    }

    if (widget.query.isNotEmpty && state.users.isEmpty) {
      return CustomScrollView(
        shrinkWrap: true,
        slivers: [
          HSTextPrompt(
                  prompt: "No users found for ",
                  pressableText: widget.query,
                  promptColor: app.theme.mainColor,
                  onTap: null)
              .toSliver,
          const Gap(16.0).toSliver,
          Text(
            "Maybe you will like to see these users instead",
            style: Theme.of(context).textTheme.headlineSmall,
          ).toSliver,
          const Gap(16.0).toSliver,
          SliverFillRemaining(
              child: _AnimatedUsersBuilder(users: state.trendingUsers)),
        ],
      );
    }

    final List<HSUser> users =
        state.users.isEmpty ? state.trendingUsers : state.users;

    return _AnimatedUsersBuilder(users: users);
  }
}

class _AnimatedUsersBuilder extends StatelessWidget {
  const _AnimatedUsersBuilder({
    required this.users,
  });

  final List<HSUser> users;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Gap(16.0),
        Expanded(
          child: SizedBox(
            width: screenWidth,
            child: ListView.separated(
              separatorBuilder: (context, index) => const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Divider(thickness: .084, color: Colors.grey),
              ),
              itemCount: users.length,
              itemBuilder: (BuildContext context, int index) {
                final user = users[index];
                return _AnimatedUserTile(user: user, index: index);
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _AnimatedUserTile extends StatelessWidget {
  const _AnimatedUserTile({required this.user, required this.index});

  final HSUser user;
  final int index;

  @override
  Widget build(BuildContext context) {
    return HSUserTile(user: user)
        .animate()
        .fadeIn(duration: 300.ms, delay: (50 * index).ms)
        .slideX(
            begin: -0.2,
            end: 0,
            duration: 300.ms,
            delay: (50 * index).ms,
            curve: Curves.easeOutQuad);
  }
}

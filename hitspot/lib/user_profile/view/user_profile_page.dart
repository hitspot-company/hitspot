import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:hitspot/app/hs_app.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/user_profile/bloc/hs_user_profile_bloc.dart';
import 'package:hitspot/user_profile/edit_profile/view/edit_profile_provider.dart';
import 'package:hitspot/utils/theme/hs_theme.dart';
import 'package:hitspot/widgets/auth/hs_auth_social_buttons.dart';
import 'package:hitspot/widgets/hs_appbar.dart';
import 'package:hitspot/widgets/hs_scaffold.dart';
import 'package:hitspot/widgets/hs_shimmer.dart';
import 'package:hitspot/widgets/hs_user_avatar.dart';
import 'package:hitspot/widgets/hs_user_monitor.dart';
import 'package:hitspot/widgets/shimmer_skeleton.dart';
import 'package:hs_authentication_repository/hs_authentication_repository.dart';

class UserProfilePage extends StatelessWidget {
  const UserProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = ScrollController();
    return BlocBuilder<HSUserProfileBloc, HSUserProfileState>(
      buildWhen: (previous, current) => previous.props != current.props,
      builder: (context, state) {
        final userProfileBloc = context.read<HSUserProfileBloc>();
        if (state is HSUserProfileInitialLoading) {
          return HSScaffold(
            appBar: HSAppBar(
              title: "",
              titleBold: true,
              enableDefaultBackButton: true,
            ),
            body: CustomScrollView(
              controller: controller,
              slivers: [
                _UserDataAppBar.loading(),
                const SliverToBoxAdapter(
                  child: Gap(16.0),
                ),
                const SliverToBoxAdapter(
                  child: Divider(
                    thickness: .1,
                  ),
                ),
                const SliverToBoxAdapter(
                  child: Gap(16.0),
                ),
                _StatsAppBar.loading(),
                const _Headline(title: "SPOTS"),
                const SliverToBoxAdapter(
                  child: Gap(16.0),
                ),
                _SpotsGrid.loading(),
              ],
            ),
          );
        } else if (state is HSUserProfileReady) {
          final user = state.user!;
          return HSScaffold(
            appBar: HSAppBar(
              title: "",
              titleBold: true,
              enableDefaultBackButton: true,
            ),
            body: CustomScrollView(
              controller: controller,
              slivers: [
                _UserDataAppBar.ready(user),
                const SliverToBoxAdapter(
                  child: Gap(16.0),
                ),
                if (user.biogram != null)
                  SliverMainAxisGroup(
                    slivers: [
                      const _Headline(title: "BIO"),
                      SliverToBoxAdapter(
                        child: Text(
                          user.biogram!,
                          style: textTheme.titleSmall,
                        ),
                      )
                    ],
                  ),
                const SliverToBoxAdapter(
                  child: Gap(16.0),
                ),
                _StatsAppBar.ready(
                    user: user, userProfileBloc: userProfileBloc),
                const _Headline(title: "SPOTS"),
                const SliverToBoxAdapter(
                  child: Gap(16.0),
                ),
                _SpotsGrid.ready(
                  spots: user.spots ?? [],
                ),
              ],
            ),
          );
        }
        return HSScaffold(
          appBar: HSAppBar(
            enableDefaultBackButton: true,
            title: "",
          ),
          body: const Center(
            child: Text(
                "An error occured. Please try again later."), // TODO: redirect to error page
          ),
        );
      },
    );
  }
}

class _Headline extends StatelessWidget {
  const _Headline({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Row(
        children: [
          const SizedBox(
            width: 16.0,
            child: Divider(
              thickness: .1,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              title,
              style: HSApp.instance.textTheme.headlineMedium,
            ),
          ),
          const Expanded(
            child: Divider(
              thickness: .1,
            ),
          ),
        ],
      ),
    );
  }
}

class _SpotsGrid extends StatelessWidget {
  const _SpotsGrid({this.spots, this.loading = false});

  final List? spots;
  final bool loading;

  factory _SpotsGrid.loading() {
    return const _SpotsGrid(loading: true);
  }

  factory _SpotsGrid.ready({required List spots}) {
    return _SpotsGrid(
      spots: spots,
    );
  }

  @override
  Widget build(BuildContext context) {
    return _spotsBuilder(loading, spots ?? []);
  }

  Widget _spotsBuilder(bool isLoading, List spots) {
    if (isLoading) {
      const int childCount = 8;
      return SliverMasonryGrid.count(
        crossAxisCount: 2,
        mainAxisSpacing: 8.0,
        crossAxisSpacing: 8.0,
        childCount: childCount,
        itemBuilder: (context, index) => HSShimmer(
          child: HSShimmerSkeleton(
            height: (index % 3 + 2) * 100,
          ),
        ),
      );
    } else if (spots.isEmpty) {
      return SliverFillRemaining(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(FontAwesomeIcons.mapLocation, size: 80.0),
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Text(
                "THERE ARE NO SPOTS HERE",
                style: textTheme.headlineLarge,
              ),
            ),
          ],
        ),
      );
    }
    return SliverMasonryGrid.count(
      crossAxisCount: 2,
      mainAxisSpacing: 8.0,
      crossAxisSpacing: 8.0,
      childCount: spots.length,
      itemBuilder: (context, index) {
        return _SpotTile(
          index: index,
          extent: (index % 3 + 2) * 100,
        );
      },
    );
  }
}

class _StatsAppBar extends StatelessWidget {
  const _StatsAppBar({
    this.user,
    this.loading = false,
    this.userProfileBloc,
  });

  final HSUser? user;
  final bool loading;
  final HSUserProfileBloc? userProfileBloc;

  factory _StatsAppBar.loading() {
    return const _StatsAppBar(
      loading: true,
    );
  }

  factory _StatsAppBar.ready(
      {required HSUser user, required HSUserProfileBloc userProfileBloc}) {
    return _StatsAppBar(
      user: user,
      userProfileBloc: userProfileBloc,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!loading) user!;
    return SliverAppBar(
      surfaceTintColor: Colors.transparent,
      expandedHeight: 150.0,
      floating: true,
      snap: false,
      pinned: false,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
          background: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            children: [
              _StatsChip(
                label: "Followers",
                value: user?.followers?.length,
              ),
              _StatsChip(
                label: "Following",
                value: user?.following?.length,
              ),
              _StatsChip(
                label: "Spots",
                value: user?.spots?.length,
              ),
            ],
          ),
          const SizedBox(
            height: 24.0,
          ),
          _button(loading),
        ],
      )),
    );
  }

  Widget _button(bool isLoading) {
    if (isLoading) {
      return HSShimmer(
        child: HSShimmerSkeleton(
          borderRadius: 8.0,
          child: Opacity(
            opacity: 0.0,
            child: HSSocialLoginButtons.custom(
              labelText: "EDIT PROFILE",
              onPressed: () {},
            ),
          ),
        ),
      );
    }
    if (userProfileBloc!.isOwnProfile) {
      return HSSocialLoginButtons.custom(
        labelText: "EDIT PROFILE",
        onPressed: () => HSApp.instance.navigation.push(
          EditProfileProvider.route(),
        ),
      );
    } else {
      return HSSocialLoginButtons.custom(
        labelText: "FOLLOW",
        onPressed: () {},
      );
    }
  }
}

class _UserDataAppBar extends StatelessWidget {
  const _UserDataAppBar({
    this.user = const HSUser(),
    this.loading = false,
  });

  final HSUser? user;
  final bool loading;

  factory _UserDataAppBar.loading() {
    return const _UserDataAppBar(
      user: HSUser(),
      loading: true,
    );
  }

  factory _UserDataAppBar.ready(HSUser user) {
    return _UserDataAppBar(
      user: user,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!loading) user!;
    return SliverAppBar(
      surfaceTintColor: Colors.transparent,
      expandedHeight: 140.0,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        background: Row(
          children: [
            Expanded(
              child: HSUserMonitor(
                child: HSUserAvatar(
                  loading: loading,
                  radius: 70.0,
                  iconSize: 50,
                  imgUrl: user?.profilePicture,
                ),
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  loading
                      ? const _UserDataAppBarSkeleton()
                      : _UserDataAppBarReady(user: user!),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UserDataAppBarReady extends StatelessWidget {
  const _UserDataAppBarReady({required this.user});

  final HSUser user;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          "${user.fullName}",
          style: textTheme.headlineSmall!.hintify(),
        ),
        Text("@${user.username}", style: textTheme.headlineLarge),
      ],
    );
  }
}

class _UserDataAppBarSkeleton extends StatelessWidget {
  const _UserDataAppBarSkeleton();

  @override
  Widget build(BuildContext context) {
    return const HSShimmer(
      child: HSShimmerSkeleton(
        height: 100,
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: HSShimmerSkeleton(
                  borderRadius: 4.0,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: HSShimmerSkeleton(
                  borderRadius: 4.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatsChip extends StatelessWidget {
  const _StatsChip({
    this.label,
    this.value,
    this.loading = false,
  });

  final String? label;
  final int? value;
  final bool loading;

  factory _StatsChip.loading() {
    return const _StatsChip(loading: true);
  }

  factory _StatsChip.ready({required String label, required int value}) {
    return _StatsChip(
      label: label,
      value: value,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: loading
          ? const _StatsChipSkeleton()
          : _StatsChipReady(label: label!, value: value),
    );
  }
}

class _StatsChipReady extends StatelessWidget {
  const _StatsChipReady({required this.label, this.value});

  final String label;
  final int? value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        children: [
          Text(label, style: textTheme.headlineSmall),
          Text('${value ?? 0}', style: textTheme.headlineSmall),
        ],
      ),
    );
  }
}

class _StatsChipSkeleton extends StatelessWidget {
  const _StatsChipSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.0),
      child: HSShimmer(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            HSShimmerSkeleton(
              height: 20.0,
            ),
            Gap(4.0),
            HSShimmerSkeleton(
              height: 20.0,
            ),
          ],
        ),
      ),
    );
  }
}

class _SpotTile extends StatelessWidget {
  const _SpotTile({
    Key? key,
    required this.index,
    this.extent,
    this.backgroundColor,
    this.bottomSpace,
  }) : super(key: key);

  final int index;
  final double? extent;
  final double? bottomSpace;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: _imgUrl(index),
      progressIndicatorBuilder: (context, url, progress) => _loadingWidget(),
      imageBuilder: (context, imageProvider) => ClipRRect(
        borderRadius: BorderRadius.circular(20.0),
        child: Container(
          height: extent,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.0),
            image: DecorationImage(
              image: imageProvider,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }

  Widget _loadingWidget() => ClipRRect(
        borderRadius: BorderRadius.circular(20.0),
        child: Container(
          height: extent,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.0),
            color: Colors.black.withOpacity(.04),
          ),
        ),
      );

  String _imgUrl(int index) {
    return "https://picsum.photos/40$index";
  }
}

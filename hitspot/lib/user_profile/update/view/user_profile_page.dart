import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/user_profile/edit_profile/edit_value/view/edit_value_provider.dart';
import 'package:hitspot/user_profile/edit_profile/view/edit_profile_provider.dart';
import 'package:hitspot/user_profile/update/bloc/user_profile_bloc.dart';
import 'package:hitspot/utils/theme/hs_theme.dart';
import 'package:hitspot/widgets/hs_appbar.dart';
import 'package:hitspot/widgets/hs_loading_indicator.dart';
import 'package:hitspot/widgets/hs_scaffold.dart';
import 'package:hs_authentication_repository/hs_authentication_repository.dart';
import 'package:hs_debug_logger/hs_debug_logger.dart';

class UserProfilePage extends StatelessWidget {
  const UserProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return HSScaffold(
      topSafe: false,
      sidePadding: 0.0,
      body: BlocBuilder<UserProfileBloc, UserProfileState>(
        builder: (context, state) {
          if (state is UserProfileLoaded || state is UserProfileUpdating) {
            late final HSUser user;
            if (state is UserProfileLoaded) {
              user = state.user;
            } else if (state is UserProfileUpdating) {
              user = state.user;
            }
            return _LoadedPage(user);
          } else if (state is UserProfileLoading) {
            return const Center(child: HSLoadingIndicator());
          } else if (state is UserProfileError) {
            return Center(child: Text("Error: ${state.message}"));
          }
          HSDebugLogger.logInfo("State: ${state.toString()}");
          return const SizedBox();
        },
      ),
    );
  }
}

class _LoadedPage extends StatelessWidget {
  const _LoadedPage(this.user);
  final HSUser user;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 260.0,
          bottom: PreferredSize(
            preferredSize: const Size(0, 20),
            child: Container(),
          ),
          pinned: false,
          flexibleSpace: Stack(
            children: [
              Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: _MainAppBarBackground(user: user, loading: false)),
              Positioned(
                bottom: -1,
                left: 0,
                right: 0,
                child: Container(
                  height: 30.0,
                  decoration: BoxDecoration(
                    color: currentTheme.currentTheme.scaffoldBackgroundColor,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(50),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          sliver: SliverMainAxisGroup(
            slivers: [
              _ElementSliverAppBar(
                expandedHeight: 60.0,
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    user.username!,
                    style: textTheme.displayMedium,
                  ),
                ),
              ),
              _ElementSliverAppBar(
                expandedHeight: 40.0,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _StatsChip(
                            label: "following", value: user.following?.length),
                        _StatsChip(
                            label: "followers", value: user.followers?.length),
                        _StatsChip(label: "spots", value: user.spots?.length),
                      ],
                    ),
                  ],
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 32.0),
                  child: _ActionButton(user),
                ),
              ),
              if (user.biogram != null && user.biogram!.isNotEmpty)
                SliverMainAxisGroup(
                  slivers: [
                    SliverToBoxAdapter(
                        child:
                            Text("about me", style: textTheme.headlineLarge)),
                    SliverToBoxAdapter(
                      child: Text(user.biogram!),
                    ),
                    const SliverToBoxAdapter(
                      child: Gap(16.0),
                    )
                  ],
                ),
              SliverToBoxAdapter(
                child: Text("my spots", style: textTheme.headlineLarge),
              ),
              SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(FontAwesomeIcons.mapLocation, size: 80.0),
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Text(
                          "THERE ARE NO SPOTS HERE",
                          style: textTheme.headlineLarge!.hintify(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton(this.user);

  final HSUser user;

  @override
  Widget build(BuildContext context) {
    final userProfileBloc = context.read<UserProfileBloc>();
    final bool isOwnProfile = userProfileBloc.isOwnProfile;
    late final String label;
    if (!isOwnProfile) {
      final bool isUserFollowed = userProfileBloc.isUserFollowed(user);
      label = isUserFollowed ? "unfollow" : "follow";
      return OutlinedButton(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith(
            (states) {
              if (isUserFollowed) return currentTheme.mainColor;
              return null;
            },
          ),
          shape: MaterialStateProperty.all(
            ContinuousRectangleBorder(
              borderRadius: BorderRadius.circular(14.0),
            ),
          ),
        ),
        child: Text(
          label,
          style: textTheme.headlineLarge,
        ),
        onPressed: () => userProfileBloc..add(UserProfileFollowUser(user)),
      );
    }
    label = "edit profile";
    return OutlinedButton(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.resolveWith((states) => null),
        shape: MaterialStateProperty.all(
          ContinuousRectangleBorder(
            borderRadius: BorderRadius.circular(14.0),
          ),
        ),
      ),
      child: Text(
        label,
        style: textTheme.headlineLarge,
      ),
      onPressed: () => navi.push(EditProfileProvider.route()),
    );
  }
}

class _ElementSliverAppBar extends StatelessWidget {
  const _ElementSliverAppBar(
      {required this.expandedHeight, required this.child});

  final double expandedHeight;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      toolbarHeight: 0.0,
      automaticallyImplyLeading: false,
      expandedHeight: expandedHeight,
      flexibleSpace: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: FlexibleSpaceBar(
          background: child,
        ),
      ),
    );
  }
}

class _StatsChip extends StatelessWidget {
  const _StatsChip({required this.label, this.value});

  final String label;
  final int? value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text("${value ?? 0}", style: textTheme.headlineSmall),
        Text(label, style: textTheme.bodyMedium!.hintify()),
      ],
    );
  }
}

class _MainAppBarBackground extends StatelessWidget {
  const _MainAppBarBackground({required this.user, required this.loading});

  final HSUser user;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    if (loading || user.profilePicture == null) {
      return Container(color: currentTheme.mainColor);
    }
    return CachedNetworkImage(
      imageUrl: user.profilePicture!,
      imageBuilder: (context, imageProvider) => Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Colors.black54, Colors.black54],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          image: DecorationImage(
              image: imageProvider, fit: BoxFit.cover, opacity: .3),
        ),
      ),
    );
  }
}

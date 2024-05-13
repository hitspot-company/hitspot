import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:gap/gap.dart';
import 'package:hitspot/app/hs_app.dart';
import 'package:hitspot/user_profile/bloc/hs_user_profile_bloc.dart';
import 'package:hitspot/user_profile/edit_profile/view/edit_profile_provider.dart';
import 'package:hitspot/utils/assets/hs_assets.dart';
import 'package:hitspot/utils/theme/hs_theme.dart';
import 'package:hitspot/widgets/auth/hs_auth_social_buttons.dart';
import 'package:hitspot/widgets/hs_appbar.dart';
import 'package:hitspot/widgets/hs_loading_indicator.dart';
import 'package:hitspot/widgets/hs_scaffold.dart';
import 'package:hitspot/widgets/hs_user_avatar.dart';
import 'package:hs_authentication_repository/hs_authentication_repository.dart';

class UserProfilePage extends StatelessWidget {
  const UserProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = ScrollController();
    final app = HSApp.instance;
    return BlocBuilder<HSUserProfileBloc, HSUserProfileState>(
      buildWhen: (previous, current) => previous.props != current.props,
      builder: (context, state) {
        switch (state) {
          case HSUserProfileInitialLoading():
            return Material(
              color: app.currentTheme.scaffoldBackgroundColor,
              child: const Center(
                child: HSLoadingIndicator(),
              ),
            );
          case HSUserProfileReady():
            final user =
                state.user!.copyWith(spots: List.generate(16, (index) => null));
            return HSScaffold(
              appBar: HSAppBar(
                title: "",
                titleBold: true,
                enableDefaultBackButton: true,
              ),
              body: CustomScrollView(
                controller: controller,
                slivers: [
                  _UserDataAppBar(user: user),
                  const SliverToBoxAdapter(
                    child: Gap(16.0),
                  ),
                  const SliverToBoxAdapter(
                    child: Divider(
                      thickness: .1,
                    ),
                  ),
                  if (user.biogram != null)
                    SliverAppBar(
                      flexibleSpace: FlexibleSpaceBar(
                        background: Text(user.biogram!),
                      ),
                      expandedHeight: 200.0, // initial height
                      automaticallyImplyLeading: false,
                      surfaceTintColor: Colors.transparent,
                    ),
                  const SliverToBoxAdapter(
                    child: Gap(16.0),
                  ),
                  _StatsAppBar(user: user),
                  SliverToBoxAdapter(
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
                          "Spots",
                          style: HSApp.instance.textTheme.headlineSmall,
                        ),
                      ),
                      const Expanded(
                        child: Divider(
                          thickness: .1,
                        ),
                      )
                    ],
                  )),
                  const SliverToBoxAdapter(
                    child: Gap(16.0),
                  ),
                  SliverMasonryGrid.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 8.0,
                    crossAxisSpacing: 8.0,
                    childCount: user.spots?.length ?? 0,
                    itemBuilder: (context, index) {
                      return _SpotTile(
                        index: index,
                        extent: (index % 3 + 2) * 100,
                      );
                    },
                  ),
                ],
              ),
            );
          default:
            return HSScaffold(
              body: Container(),
            );
        }
      },
    );
  }

  Offset _calculateTiltOffset() {
    final random = Random();
    const double factor = 2.5;
    final double rx =
        random.nextDouble() * factor * (random.nextInt(2) % 2 == 0 ? 1 : -1);
    final double ry =
        random.nextDouble() * factor * (random.nextInt(2) % 2 == 0 ? 1 : -1);
    return Offset(rx, ry);
  }
}

class _StatsAppBar extends StatelessWidget {
  const _StatsAppBar({
    required this.user,
  });

  final HSUser user;

  @override
  Widget build(BuildContext context) {
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
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _StatsChip(
                label: "Followers",
                value: user.followers?.length,
              ),
              _StatsChip(
                label: "Following",
                value: user.following?.length,
              ),
              _StatsChip(
                label: "Spots",
                value: user.spots?.length,
              ),
            ],
          ),
          const SizedBox(
            height: 24.0,
          ),
          HSSocialLoginButtons.custom(
            labelText: "EDIT PROFILE",
            onPressed: () => HSApp.instance.navigation.push(
              EditProfileProvider.route(),
            ),
          ),
        ],
      )),
    );
  }
}

class _UserDataAppBar extends StatelessWidget {
  const _UserDataAppBar({
    required this.user,
  });

  final HSUser user;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      surfaceTintColor: Colors.transparent,
      expandedHeight: 140.0,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        background: Row(
          children: [
            Expanded(
              child: HSUserAvatar(
                radius: 70.0,
                imgUrl: user.profilePicture,
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("@${user.username!}"),
                  Text(
                    user.fullName!,
                    style: const TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  AutoSizeText.rich(
                    TextSpan(
                      text: "Member since: ",
                      children: [
                        TextSpan(
                            text: user.createdAt
                                ?.toDate()
                                .toString()
                                .split(" ")
                                .elementAt(0),
                            style: const TextStyle(
                                fontWeight: FontWeight.normal,
                                color: Colors.grey)),
                      ],
                    ),
                    textAlign: TextAlign.center,
                    style: const TextStyle().boldify(),
                    maxLines: 1,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Image _getImage(HSUser user) {
    if (user.profilePicture == null) {
      return Image.asset(
        HSAssets.instance.logo,
      );
    }
    return Image.network(
      user.profilePicture!,
    );
  }
}

class _StatsChip extends StatelessWidget {
  const _StatsChip({
    required this.label,
    required this.value,
  });

  final String label;
  final int? value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            children: [
              Text(label),
              Text(
                '${value ?? 0}',
                style: const TextStyle().boldify(),
              ),
            ],
          ),
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
      // placeholder: (context, url) => _loadingWidget(),
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

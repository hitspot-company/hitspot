import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/features/app/hs_app.dart';
import 'package:hitspot/widgets/hs_scaffold.dart';
import 'package:hitspot/widgets/hs_user_avatar.dart';
import 'package:hitspot/widgets/shimmers/hs_shimmer_box.dart';
import 'package:hitspot/widgets/spot/hs_animated_spot_tile.dart';
import 'package:hitspot/features/user_profile/main/cubit/hs_user_profile_cubit.dart';
import 'package:hitspot/widgets/hs_button.dart';
import 'package:hs_authentication_repository/hs_authentication_repository.dart';

import '../../../../home/main/view/home_page.dart';

class UserProfileInfo extends StatelessWidget {
  const UserProfileInfo({
    required this.context,
    required this.loading,
    required this.user,
  });

  final BuildContext context;
  final bool loading;
  final HSUser? user;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (loading)
          const HSShimmerBox(width: 200, height: 30)
        else
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: HSUserAvatar(
              imageUrl: user?.avatarUrl,
              radius: 54,
            ).animate().fadeIn(duration: 300.ms),
          ),
        const SizedBox(height: 12),
        if (loading)
          const HSShimmerBox(width: 200, height: 30)
        else
          Text(
            user?.name ?? '',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.2, end: 0),
        const SizedBox(height: 4),
        if (loading)
          const HSShimmerBox(width: 150, height: 20)
        else
          Text(
            '@${user?.username ?? ''}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey,
                ),
          ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.2, end: 0),
      ],
    );
  }
}

class UserDataBar extends StatelessWidget {
  const UserDataBar({
    required this.loading,
    required this.user,
  });

  final bool loading;
  final HSUser? user;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: const HSShimmerBox(
          width: double.infinity,
          height: 60,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 12.0),
      child: Column(
        children: [
          Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: [
                Expanded(
                    child: Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 32.0),
                          child: _buildDataItem('${user?.spots}', 'spots'),
                        ))),
                Expanded(
                    child: Align(
                        alignment: Alignment.center,
                        child:
                            _buildDataItem('${user?.followers}', 'followers'))),
                Expanded(
                    child: Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 32.0),
                          child:
                              _buildDataItem('${user?.following}', 'following'),
                        ))),
              ],
            ),
          ),
          Divider(),
        ],
      ),
    );
  }

  Widget _buildDataItem(String value, String label) {
    return Column(
      children: [
        Text(value, style: textTheme.headlineSmall),
        Text(label, style: textTheme.bodySmall),
      ],
    );
  }
}

class UserProfileActionButton extends StatelessWidget {
  const UserProfileActionButton({
    required this.isLoading,
  });

  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(25)),
        child: HSShimmerBox(
          width: 50.0,
          height: 50,
        ),
      );
    }

    final bool ownProfile = context.read<HSUserProfileCubit>().isOwnProfile;
    final bool isFollowed =
        context.read<HSUserProfileCubit>().state.isFollowed == true;

    return SizedBox(
      height: 50.0,
      child: HSButton(
        onPressed: ownProfile
            ? navi.toEditProfile
            : context.read<HSUserProfileCubit>().followUser,
        child: Text(
          ownProfile ? 'Edit Profile' : (isFollowed ? 'Unfollow' : 'Follow'),
        ),
      ).animate().fadeIn(duration: 300.ms).scale(
            begin: const Offset(0.95, 0.95),
            end: const Offset(1.0, 1.0),
          ),
    );
  }
}

class TabContent extends StatelessWidget {
  const TabContent({
    required this.context,
    required this.isLoading,
    required this.elements,
    required this.title,
  });

  final BuildContext context;
  final bool isLoading;
  final List elements;
  final String title;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (elements.isEmpty) {
      return Center(child: Text('No ${title.toLowerCase()} available'));
    }

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12.0,
        mainAxisSpacing: 12.0,
      ),
      itemCount: elements.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: title == 'Boards'
              ? HSBoardGridItem(board: elements[index])
              : AnimatedSpotTile(spot: elements[index], index: index),
        );
      },
    );
  }
}

class TabBarWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const TabBar(
      labelStyle: TextStyle(
        fontSize: 16.0,
        fontWeight: FontWeight.bold,
      ),
      unselectedLabelStyle: TextStyle(
        fontSize: 15.0,
        fontWeight: FontWeight.normal,
      ),
      labelColor: Colors.blue,
      indicatorPadding: EdgeInsets.zero,
      indicator: UnderlineTabIndicator(
        borderSide: BorderSide(width: 2.0, color: Colors.blue),
      ),
      unselectedLabelColor: Colors.grey,
      tabs: [
        Tab(text: 'Spots'),
        Tab(text: 'Boards'),
      ],
      dividerHeight: 0,
    );
  }
}

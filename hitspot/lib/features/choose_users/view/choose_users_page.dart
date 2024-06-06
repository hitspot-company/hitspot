import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/features/choose_users/cubit/hs_choose_users_cubit.dart';
import 'package:hitspot/utils/theme/hs_theme.dart';
import 'package:hitspot/widgets/hs_appbar.dart';
import 'package:hitspot/widgets/hs_loading_indicator.dart';
import 'package:hitspot/widgets/hs_scaffold.dart';
import 'package:hitspot/widgets/hs_textfield.dart';
import 'package:hitspot/widgets/hs_user_avatar.dart';
import 'package:hs_authentication_repository/hs_authentication_repository.dart';
import 'package:hs_search_repository/hs_search.dart';

class ChooseUsersPage extends StatelessWidget {
  const ChooseUsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final chooseUsersCubit = context.read<HSChooseUsersCubit>();
    return HSScaffold(
      appBar: HSAppBar(
        title: Text(chooseUsersCubit.title, style: textTheme.headlineSmall),
        enableDefaultBackButton: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HSTextField(
            hintText: "Search...",
            onChanged: chooseUsersCubit.updateQuery,
            suffixIcon: const Icon(FontAwesomeIcons.magnifyingGlass),
          ),
          const Gap(16.0),
          _SuggestionsBuilder(chooseUsersCubit: chooseUsersCubit),
          const Gap(16.0),
          Text(
            chooseUsersCubit.description,
            style: textTheme.bodyMedium!.hintify,
          ),
        ],
      ),
    );
  }
}

class _SuggestionsBuilder extends StatelessWidget {
  const _SuggestionsBuilder({required this.chooseUsersCubit});

  final HSChooseUsersCubit chooseUsersCubit;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UsersHitsPage>(
      stream: chooseUsersCubit.usersSearcher.searchPage,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const HSLoadingIndicator();
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData) {
          return const Center(child: Text('No results found.'));
        }
        final List<HSUser> users = snapshot.data?.items ?? [];
        return ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount:
              users.length > 5 ? 5 : users.length, // TODO: Fix to limit queries
          separatorBuilder: (BuildContext context, int index) {
            return const Gap(16.0);
          },
          itemBuilder: (BuildContext context, int index) {
            final user = users[index];
            return ListTile(
              leading: HSUserAvatar(imgUrl: user.profilePicture, radius: 30.0),
              title: Text("@${user.username}"),
              subtitle: Text("${user.fullName}"),
            );
          },
        );
      },
    );
  }
}

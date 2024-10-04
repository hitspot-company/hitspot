import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/features/spots/multiple/cubit/hs_multiple_spots_cubit.dart';
import 'package:hitspot/features/user_profile/multiple/cubit/hs_user_profile_multiple_cubit.dart';
import 'package:hitspot/widgets/hs_appbar.dart';
import 'package:hitspot/widgets/hs_loading_indicator.dart';
import 'package:hitspot/widgets/hs_scaffold.dart';
import 'package:hitspot/widgets/hs_textfield.dart';
import 'package:hitspot/widgets/hs_user_tile.dart';
import 'package:hs_authentication_repository/hs_authentication_repository.dart';
import 'package:hs_database_repository/hs_database_repository.dart';
import 'package:hs_debug_logger/hs_debug_logger.dart';

class UserProfileMultiplePage extends StatelessWidget {
  const UserProfileMultiplePage({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = BlocProvider.of<HsUserProfileMultipleCubit>(context);
    return HSScaffold(
      appBar: HSAppBar(
        titleText: cubit.pageTitle,
        enableDefaultBackButton: true,
      ),
      body: const Column(
        children: [
          // _SearchBar(),
          Expanded(child: _Builder()),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    return HSTextField.filled(
      hintText: 'Search...',
      onChanged: (value) {},
    );
  }
}

class _Builder extends StatelessWidget {
  const _Builder();

  @override
  Widget build(BuildContext context) {
    final cubit = BlocProvider.of<HsUserProfileMultipleCubit>(context);
    return BlocBuilder<HsUserProfileMultipleCubit, HsUserProfileMultipleState>(
      buildWhen: (previous, current) => previous.status != current.status,
      builder: (context, state) {
        if (state.status == HSUserProfileMultipleStatus.loading) {
          return const HSLoadingIndicator();
        }
        return PagedListView.separated(
          pagingController: cubit.pagingController,
          builderDelegate: PagedChildBuilderDelegate<dynamic>(
            newPageProgressIndicatorBuilder: (context) =>
                const HSLoadingIndicator(),
            firstPageProgressIndicatorBuilder: (context) =>
                const HSLoadingIndicator(),
            itemBuilder: (context, item, index) {
              final user = item as HSUser;
              return InkWell(
                onTap: () => navi.toUser(userID: user.uid!),
                child: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: HSUserTile(user: user),
                ),
              );
            },
          ),
          separatorBuilder: (context, index) => const Divider(thickness: .2),
        );
      },
    );
  }
}

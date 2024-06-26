import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/features/search/users/cubit/hs_user_search_cubit.dart';
import 'package:hitspot/widgets/hs_loading_indicator.dart';
import 'package:hitspot/widgets/hs_textfield.dart';
import 'package:hitspot/widgets/hs_user_avatar.dart';

class UserSearchPage extends StatelessWidget {
  const UserSearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    final userSearchCubit = context.read<HSUserSearchCubit>();
    return Column(
      children: [
        const Gap(8.0),
        HSTextField.filled(
          hintText: "Search for users",
          suffixIcon: const Icon(Icons.search),
          onChanged: userSearchCubit.searchUsers,
        ),
        const Gap(16.0),
        Expanded(
          child: BlocBuilder<HSUserSearchCubit, HSUserSearchState>(
            buildWhen: (previous, current) =>
                previous.status != current.status ||
                previous.users != current.users,
            builder: (context, state) {
              switch (state.status) {
                case HSUserSearchStatus.initial:
                  // TODO: add recently searched users
                  return const Text("...");
                case HSUserSearchStatus.loading:
                  return const HSLoadingIndicator();
                case HSUserSearchStatus.error:
                  return const Center(child: Text("Error"));
                case HSUserSearchStatus.loaded:
                  return ListView.separated(
                    itemCount: state.users.length,
                    separatorBuilder: (context, index) => const Gap(16.0),
                    itemBuilder: (context, index) {
                      final user = state.users[index];
                      return ListTile(
                        onTap: () => navi.toUser(userID: user.uid!),
                        shape: ContinuousRectangleBorder(
                          borderRadius: BorderRadius.circular(14.0),
                        ),
                        tileColor: appTheme.highlightColor,
                        leading:
                            HSUserAvatar(radius: 30, imageUrl: user.avatarUrl),
                        title: Text(user.username!),
                        subtitle: Text(user.name!),
                      );
                    },
                  );
              }
            },
          ),
        ),
      ],
    );
  }
}

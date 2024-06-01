import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:hitspot/app/hs_app.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/features/bloc/hs_authentication_bloc.dart';
import 'package:hitspot/features/user_profile/edit_profile/cubit/edit_profile_cubit.dart';
import 'package:hitspot/features/user_profile/edit_value/view/edit_value_provider.dart';
import 'package:hitspot/widgets/hs_appbar.dart';
import 'package:hitspot/widgets/hs_scaffold.dart';
import 'package:hitspot/widgets/hs_textfield.dart';
import 'package:hitspot/widgets/hs_user_avatar.dart';
import 'package:hitspot/widgets/hs_user_monitor.dart';
import 'package:hs_authentication_repository/hs_authentication_repository.dart';

class EditProfilePage extends StatelessWidget {
  const EditProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final editProfileCubit = context.read<EditProfileCubit>();
    return HSScaffold(
      appBar: HSAppBar(
        title: "EDIT PROFILE",
        fontSize: 16.0,
        titleBold: true,
        enableDefaultBackButton: true,
        defaultBackButtonCallback: () =>
            navi.pop(editProfileCubit.shouldUpdate ?? false),
      ),
      body: BlocSelector<HSAuthenticationBloc, HSAuthenticationState, HSUser>(
        selector: (state) => state.user,
        builder: (context, state) {
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                surfaceTintColor: Colors.transparent,
                expandedHeight: 240.0,
                automaticallyImplyLeading: false,
                flexibleSpace: FlexibleSpaceBar(
                  background: Column(
                    children: [
                      BlocBuilder<EditProfileCubit, EditProfileState>(
                        builder: (context, state) {
                          final HSImageChangeState imageChangeState =
                              state.imageChangeState;
                          late final Widget child;
                          switch (imageChangeState) {
                            case HSImageChangeState.choosing ||
                                  HSImageChangeState.setting ||
                                  HSImageChangeState.uploading:
                              child = const HSUserAvatar(
                                radius: 80.0,
                                loading: true,
                              );
                            default:
                              child = InkWell(
                                radius: 60.0,
                                onTap: editProfileCubit.chooseImage,
                                child: HSUserMonitor(
                                  child: HSUserAvatar(
                                    imgUrl: app.currentUser.profilePicture,
                                    radius: 80,
                                    iconSize: 50,
                                  ),
                                ),
                              );
                          }
                          return child;
                        },
                      ),
                      const Gap(8.0),
                      CupertinoButton(
                        onPressed: editProfileCubit.chooseImage,
                        child: const Text("Edit profile picture"),
                      ),
                      const Divider(),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: Gap(24.0)),
              SliverToBoxAdapter(
                child: _TextEditPrompt(
                  fieldName: 'Full name',
                  fieldDescription:
                      "Your full name is used to make it easier for your friends to find your profile.",
                  initialValue: app.currentUser.fullName ?? "",
                  field: HSUserField.fullName.name,
                ),
              ),
              const SliverToBoxAdapter(child: Gap(24.0)),
              SliverToBoxAdapter(
                child: _TextEditPrompt(
                  fieldName: 'Username',
                  fieldDescription:
                      "Your username is your unique identifier among other users. Make it stand out!",
                  initialValue: app.currentUser.username ?? "",
                  field: HSUserField.username.name,
                ),
              ),
              const SliverToBoxAdapter(child: Gap(24.0)),
              SliverToBoxAdapter(
                child: _TextEditPrompt(
                  fieldName: 'Biogram',
                  fieldDescription:
                      "Your biogram is here for you to tell your story. Let other users know what kind of a traveller you are!",
                  initialValue: app.currentUser.biogram ?? "Your biogram...",
                  field: HSUserField.biogram.name,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _TextEditPrompt extends StatelessWidget {
  const _TextEditPrompt({
    required this.fieldName,
    required this.fieldDescription,
    required this.initialValue,
    required this.field,
  });

  final String fieldName;
  final String fieldDescription;
  final String initialValue;
  final String field;

  @override
  Widget build(BuildContext context) {
    return HSTextField(
      onTap: () => _toEdit(context.read<EditProfileCubit>()),
      labelText: fieldName,
      suffixIcon: const Opacity(
        opacity: 0.0,
        child: Icon(FontAwesomeIcons.user),
      ),
      readOnly: true,
      floatingLabelBehavior: FloatingLabelBehavior.always,
      hintText: initialValue,
    );
  }

  Future<void> _toEdit(EditProfileCubit editProfileCubit) async {
    final bool shouldUpdate = await app.navigation.push(EditValueProvider.route(
      field: field,
      initialValue: initialValue,
      fieldName: fieldName,
      fieldDescription: fieldDescription,
    ));
    if (shouldUpdate) {
      editProfileCubit.shouldUpdate = true;
    }
  }
}

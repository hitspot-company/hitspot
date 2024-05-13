import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:hitspot/app/hs_app.dart';
import 'package:hitspot/authentication/bloc/hs_authentication_bloc.dart';
import 'package:hitspot/user_profile/edit_profile/edit_value/view/edit_value_provider.dart';
import 'package:hitspot/widgets/hs_appbar.dart';
import 'package:hitspot/widgets/hs_scaffold.dart';
import 'package:hitspot/widgets/hs_textfield.dart';
import 'package:hitspot/widgets/hs_user_avatar.dart';
import 'package:hs_authentication_repository/hs_authentication_repository.dart';

class EditProfilePage extends StatelessWidget {
  const EditProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final app = HSApp.instance;
    return HSScaffold(
      appBar: HSAppBar(
        title: "EDIT PROFILE",
        fontSize: 16.0,
        titleBold: true,
        enableDefaultBackButton: true,
      ),
      body: BlocSelector<HSAuthenticationBloc, HSAuthenticationState, HSUser>(
        selector: (state) => state.user,
        builder: (context, state) {
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                surfaceTintColor: Colors.transparent,
                expandedHeight: 200.0,
                automaticallyImplyLeading: false,
                flexibleSpace: FlexibleSpaceBar(
                    background: Column(
                  children: [
                    InkWell(
                      radius: 60.0,
                      onTap: () => print("edit picture"),
                      child: HSUserAvatar(
                        imgUrl: app.currentUser.profilePicture,
                        radius: 60,
                        iconSize: 40,
                      ),
                    ),
                    const Gap(8.0),
                    CupertinoButton(
                      onPressed: () => print("edit picture"),
                      child: const Text("Edit profile picture"),
                    ),
                    const Divider(),
                  ],
                )),
              ),
              const SliverToBoxAdapter(child: Gap(24.0)),
              SliverToBoxAdapter(
                child: _TextEditPrompt(
                  fieldName: 'Full name',
                  fieldDescription:
                      "Your full name is used to make it easier fo your friends to find your profile.",
                  initialValue: app.currentUser.fullName ?? "",
                  field: HSUserField.fullName.name,
                ),
              ),
              const SliverToBoxAdapter(child: Gap(24.0)),
              SliverToBoxAdapter(
                child: _TextEditPrompt(
                  fieldName: 'Username',
                  fieldDescription:
                      "Your username is your unique identifier amongs other users. Make it stand out!",
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
    final HSApp app = HSApp.instance;
    return HSTextField(
      onTap: () => app.navigation.push(EditValueProvider.route(
        field: field,
        initialValue: initialValue,
        fieldName: fieldName,
        fieldDescription: fieldDescription,
      )),
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
}

import 'package:hitspot/constants/constants.dart';
import 'package:flutter/widgets.dart';
import 'package:hitspot/features/user_profile/main/bloc/hs_user_profile_bloc.dart';
import 'package:hitspot/features/user_profile/edit_profile/view/edit_profile_provider.dart';
import 'package:hitspot/widgets/auth/hs_auth_social_buttons.dart';
import 'package:hs_debug_logger/hs_debug_logger.dart';

class HSUserProfileActionButton extends StatelessWidget {
  const HSUserProfileActionButton(
      {super.key,
      required this.onPressed,
      required this.labelText,
      this.userProfileBloc,
      this.backgroundColor});

  final String labelText;
  final VoidCallback onPressed;
  final HSUserProfileBloc? userProfileBloc;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return HSSocialLoginButtons.custom(
      labelText: labelText,
      onPressed: onPressed,
      backgroundColor: backgroundColor,
    );
  }

  factory HSUserProfileActionButton.follow(HSUserProfileBloc userProfileBloc) {
    return HSUserProfileActionButton(
      labelText: "FOLLOW",
      onPressed: () => userProfileBloc.add(
        HSUserProfileFollowUnfollowUserEvent(),
      ),
    );
  }

  factory HSUserProfileActionButton.unfollow(
      HSUserProfileBloc userProfileBloc) {
    return HSUserProfileActionButton(
      labelText: "UNFOLLOW",
      onPressed: () => userProfileBloc.add(
        HSUserProfileFollowUnfollowUserEvent(),
      ),
      backgroundColor: currentTheme.mainColor,
    );
  }

  factory HSUserProfileActionButton.editProfile(bool isLoading,
      [HSUserProfileBloc? userProfileBloc]) {
    return HSUserProfileActionButton(
        labelText: "EDIT PROFILE",
        onPressed: isLoading ? () {} : () => _determineUpdate(userProfileBloc));
  }

  static Future<void> _determineUpdate(
      HSUserProfileBloc? userProfileBloc) async {
    bool shouldUpdate = await app.navigation.push(EditProfileProvider.route());
    if (shouldUpdate) {
      userProfileBloc?.add(HSUserProfileRequestUpdateEvent());
    }
  }
}

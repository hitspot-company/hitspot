import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/features/complete_profile/cubit/hs_complete_profile_cubit.dart';
import 'package:hitspot/widgets/form/hs_form.dart';
import 'package:hitspot/widgets/hs_appbar.dart';
import 'package:hitspot/widgets/hs_loading_indicator.dart';
import 'package:hitspot/widgets/hs_scaffold.dart';
import 'package:hitspot/widgets/hs_textfield.dart';
import 'package:hitspot/widgets/hs_user_avatar.dart';
import 'package:hs_form_inputs/hs_form_inputs.dart';

class CompleteProfilePage extends StatelessWidget {
  const CompleteProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final HSCompleteProfileCubit completeProfileCubit =
        context.read<HSCompleteProfileCubit>();
    return HSScaffold(
      appBar: HSAppBar(
        enableDefaultBackButton: true,
        defaultBackButtonCallback: app.logout,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: PageView(
              physics: const NeverScrollableScrollPhysics(),
              controller: completeProfileCubit.pageController,
              children: [
                _FirstPage(completeProfileCubit),
                _SecondPage(completeProfileCubit),
                _ThirdPage(completeProfileCubit),
                _FourthPage(completeProfileCubit),
                _FifthPage(completeProfileCubit),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FirstPage extends StatelessWidget {
  const _FirstPage(this._completeProfileCubit);

  final HSCompleteProfileCubit _completeProfileCubit;

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      children: [
        const HSFormHeadline(
            text: "Welcome to Hitspot!",
            headlineType: HSFormHeadlineType.display),
        HSFormCaption(
            text: "Hi ${currentUser.email}!\nPlease complete your profile."),
        const Gap(16.0),
        const HSFormHeadline(text: "Birthday"),
        const HSFormCaption(text: "You have to be at least 16 to use Hitspot"),
        const Gap(8.0),
        _BirthdayInput(_completeProfileCubit),
        const Gap(8.0),
        HSFormButtonsRow(
          right: BlocSelector<HSCompleteProfileCubit, HSCompleteProfileState,
              bool>(
            selector: (state) =>
                state.birthday.error == null && state.birthday.isValid,
            builder: (context, isValid) {
              return HSFormButton(
                icon: const Icon(FontAwesomeIcons.arrowRight),
                onPressed: isValid ? _completeProfileCubit.nextPage : null,
                child: const Text("Next"),
              );
            },
          ),
        )
      ],
    );
  }
}

class _SecondPage extends StatelessWidget {
  const _SecondPage(this._completeProfileCubit);

  final HSCompleteProfileCubit _completeProfileCubit;

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      children: [
        const HSFormHeadline(text: "Name"),
        const HSFormCaption(
            text: "Make it easier for your friends to find you in the app."),
        const Gap(8.0),
        HSTextField(
          autofocus: true,
          onChanged: _completeProfileCubit.updateName,
          fillColor: currentTheme.textfieldFillColor,
          suffixIcon: const Icon(FontAwesomeIcons.a, color: Colors.transparent),
          hintText: "Your name",
          initialValue: _completeProfileCubit.state.fullnameVal,
        ),
        const Gap(16.0),
        BlocSelector<HSCompleteProfileCubit, HSCompleteProfileState, bool>(
          selector: (state) =>
              state.fullname.error == null && state.fullname.isValid,
          builder: (context, isValid) => HSFormButtonsRow(
            right: HSFormButton(
              icon: nextIcon,
              onPressed: isValid ? _completeProfileCubit.nextPage : null,
              child: const Text("Next"),
            ),
            left: HSFormButton(
              onPressed: _completeProfileCubit.prevPage,
              child: const Text("Back"),
            ),
          ),
        ),
      ],
    );
  }
}

class _ThirdPage extends StatelessWidget {
  const _ThirdPage(this._completeProfileCubit);

  final HSCompleteProfileCubit _completeProfileCubit;

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      children: [
        const HSFormHeadline(text: "Username"),
        const Gap(8.0),
        _UsernameInput(_completeProfileCubit),
        const Gap(8.0),
        const HSFormCaption(
            text:
                "Your username has to be unique, between 5 and 16 characters long and can only contain alphanumeric characters plus the '_'."),
        const Gap(32.0),
        _UsernameNextButton(_completeProfileCubit),
      ],
    );
  }
}

class _FourthPage extends StatelessWidget {
  const _FourthPage(this._completeProfileCubit);
  final HSCompleteProfileCubit _completeProfileCubit;

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      children: [
        const HSFormHeadline(text: "Biogram"),
        const HSFormCaption(text: "Tell the world more about yourself!"),
        const Gap(8.0),
        HSTextField(
          onChanged: _completeProfileCubit.updateBiogram,
          maxLines: 6,
          maxLength: 256,
          initialValue: _completeProfileCubit.state.biogramVal,
          fillColor: currentTheme.textfieldFillColor,
          suffixIcon: const Icon(
            FontAwesomeIcons.a,
            color: Colors.transparent,
          ),
        ),
        const Gap(8.0),
        const HSFormCaption(
            text:
                "This section is completely optional. You can leave it empty."),
        const Gap(16.0),
        HSFormButtonsRow(
          left: HSFormButton(
              onPressed: _completeProfileCubit.prevPage,
              child: const Text("Back")),
          right: HSFormButton(
            icon: nextIcon,
            onPressed: _completeProfileCubit.nextPage,
            child: const Text("Next"),
          ),
        ),
      ],
    );
  }
}

class _FifthPage extends StatelessWidget {
  const _FifthPage(this._completeProfileCubit);

  final HSCompleteProfileCubit _completeProfileCubit;

  @override
  Widget build(BuildContext context) {
    return HSFormPageBody(
      heading: "Avatar",
      caption: "Choose your avatar.\nThis section is also optional.",
      children: [
        const Gap(16.0),
        GestureDetector(
          onTap: _completeProfileCubit.changeAvatar,
          child: BlocSelector<HSCompleteProfileCubit, HSCompleteProfileState,
              String?>(
            selector: (state) => state.avatar.isNotEmpty ? state.avatar : null,
            builder: (context, avatar) => HSUserAvatar(
                radius: 64.0, iconSize: 64.0, isAsset: true, imgUrl: avatar),
          ),
        ),
        const Gap(8.0),
        TextButton(
          onPressed: _completeProfileCubit.changeAvatar,
          child: Text(
            "Choose Avatar",
            style: TextStyle(color: currentTheme.mainColor),
          ),
        ),
        const Gap(32.0),
        const HSFormCaption(
            text:
                "Once you are done cusomizing your profile, submit changes using the button below"),
        const Gap(8.0),
        HSFormButtonsRow(
          left: HSFormButton(
            onPressed: _completeProfileCubit.prevPage,
            child: const Text("Back"),
          ),
          right: BlocSelector<HSCompleteProfileCubit, HSCompleteProfileState,
              HSCompleteProfileStatus>(
            selector: (state) => state.completeProfileStatus,
            builder: (context, status) {
              switch (status) {
                case HSCompleteProfileStatus.idle:
                  return HSFormButton(
                    onPressed: _completeProfileCubit.submit,
                    icon: const Icon(FontAwesomeIcons.check),
                    child: const Text("Submit"),
                  );
                case HSCompleteProfileStatus.error:
                  return const HSFormButton(
                    icon: Icon(FontAwesomeIcons.xmark),
                    child: Text("Error"),
                  );
                case HSCompleteProfileStatus.loading:
                  return const HSFormButton(
                    child: HSLoadingIndicator(
                      size: 24.0,
                    ),
                  );
              }
            },
          ),
        ),
      ],
    );
  }
}

class _UsernameInput extends StatelessWidget {
  const _UsernameInput(this._completeProfileCubit);
  final HSCompleteProfileCubit _completeProfileCubit;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HSCompleteProfileCubit, HSCompleteProfileState>(
      buildWhen: (previous, current) =>
          previous.username != current.username ||
          previous.usernameValidationState != current.usernameValidationState,
      builder: (context, state) => HSTextField(
        autofocus: true,
        textInputAction: TextInputAction.next,
        scrollPadding: const EdgeInsets.all(84.0),
        onChanged: _completeProfileCubit.updateUsername,
        fillColor: currentTheme.textfieldFillColor,
        hintText: "Your username",
        initialValue: state.usernameVal,
        prefixIcon: _getPrefixIcon,
        errorText: _errorText,
      ),
    );
  }

  Icon get _getPrefixIcon {
    final usernameValidationState =
        _completeProfileCubit.state.usernameValidationState;
    switch (usernameValidationState) {
      case UsernameValidationState.available:
        return const Icon(FontAwesomeIcons.check, color: Colors.green);
      case UsernameValidationState.unavailable:
        return const Icon(FontAwesomeIcons.xmark, color: Colors.red);
      default:
        return const Icon(FontAwesomeIcons.question);
    }
  }

  String? get _errorText {
    final state = _completeProfileCubit.state;
    UsernameValidationError? error = state.username.displayError;
    if (state.usernameValidationState == UsernameValidationState.unavailable) {
      error = UsernameValidationError.unavailable;
    } else if (state.usernameValidationState == UsernameValidationState.empty) {
      error = UsernameValidationError.invalid;
    }
    if (error == null) return null;
    switch (error) {
      case UsernameValidationError.notLowerCase:
        return "No uppercase letters.";
      case UsernameValidationError.short:
        return "At least 5 characters.";
      case UsernameValidationError.long:
        return "More than 16 characters.";
      case UsernameValidationError.unavailable:
        return "The username is already taken.";
      default:
        return "Invalid username";
    }
  }
}

class _UsernameNextButton extends StatelessWidget {
  const _UsernameNextButton(this._completeProfileCubit);

  final HSCompleteProfileCubit _completeProfileCubit;

  @override
  Widget build(BuildContext context) {
    return HSFormButtonsRow(
      left: HSFormButton(
          onPressed: _completeProfileCubit.prevPage, child: const Text("Back")),
      right: BlocSelector<HSCompleteProfileCubit, HSCompleteProfileState,
          UsernameValidationState>(
        selector: (state) => state.usernameValidationState,
        builder: (context, usernameValidationState) {
          switch (usernameValidationState) {
            case UsernameValidationState.unknown:
              return HSFormButton(
                onPressed: _completeProfileCubit.isUsernameValid,
                child: const Text('VERIFY'),
              );
            case UsernameValidationState.verifying:
              return const HSFormButton(
                onPressed: null,
                child: HSLoadingIndicator(
                  size: 32.0,
                ),
              );
            case UsernameValidationState.unavailable ||
                  UsernameValidationState.empty:
              return const HSFormButton(
                onPressed: null,
                child: Text("NEXT"),
              );
            case UsernameValidationState.available:
              return HSFormButton(
                onPressed: _completeProfileCubit.nextPage,
                child: const Text("NEXT"),
              );
          }
        },
      ),
    );
  }
}

class _BirthdayInput extends StatelessWidget {
  const _BirthdayInput(this._completeProfileCubit);

  final HSCompleteProfileCubit _completeProfileCubit;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HSCompleteProfileCubit, HSCompleteProfileState>(
      buildWhen: (previous, current) =>
          previous.birthday != current.birthday ||
          previous.error != current.error,
      builder: (context, state) => HSTextField(
        fillColor: currentTheme.textfieldFillColor,
        prefixIcon: const Icon(FontAwesomeIcons.cakeCandles),
        readOnly: true,
        onTap: _completeProfileCubit.updateBirthday,
        hintText: _hintText,
        errorText: _errorText,
      ),
    );
  }

  String get _hintText {
    if (!_completeProfileCubit.state.birthday.isPure) {
      return _completeProfileCubit.state.birthday.value
          .dateTimeToReadableString();
    }
    return "Date of Birth";
  }

  String? get _errorText {
    if (_completeProfileCubit.state.error.isNotEmpty) {
      return _completeProfileCubit.state.error;
    }
    return null;
  }
}

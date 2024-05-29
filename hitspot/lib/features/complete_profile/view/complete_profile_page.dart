import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/features/complete_profile/cubit/hs_complete_profile_cubit.dart';
import 'package:hitspot/widgets/form/hs_form.dart';
import 'package:hitspot/widgets/hs_appbar.dart';
import 'package:hitspot/widgets/hs_scaffold.dart';
import 'package:hitspot/widgets/hs_textfield.dart';
import 'package:hs_form_inputs/hs_form_inputs.dart';

class CompleteProfilePage extends StatelessWidget {
  const CompleteProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final HsCompleteProfileCubit completeProfileCubit =
        context.read<HsCompleteProfileCubit>();
    return HSScaffold(
      appBar: HSAppBar(
        enableDefaultBackButton: true,
      ),
      body: PageView(
        children: [
          _FirstPage(completeProfileCubit),
        ],
      ),
    );
  }
}

class _FirstPage extends StatelessWidget {
  const _FirstPage(this._completeProfileCubit);

  final HsCompleteProfileCubit _completeProfileCubit;

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
      ],
    );
  }
}

class _BirthdayInput extends StatelessWidget {
  const _BirthdayInput(this._completeProfileCubit);

  final HsCompleteProfileCubit _completeProfileCubit;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HsCompleteProfileCubit, HSCompleteProfileState>(
      buildWhen: (previous, current) =>
          previous.birthday != current.birthday ||
          previous.error != current.error,
      builder: (context, state) => HSTextField(
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

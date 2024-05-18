import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:hitspot/app/hs_app.dart';
import 'package:hitspot/user_profile/edit_profile/edit_value/cubit/hs_edit_value_cubit.dart';
import 'package:hitspot/widgets/hs_appbar.dart';
import 'package:hitspot/widgets/hs_loading_indicator.dart';
import 'package:hitspot/widgets/hs_scaffold.dart';
import 'package:hitspot/widgets/hs_textfield.dart';

class EditValuePage extends StatelessWidget {
  const EditValuePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HSEditValueCubit, HSEditValueState>(
      builder: (context, state) {
        final editValueCubit = context.read<HSEditValueCubit>();
        return HSScaffold(
          appBar: HSAppBar(
            enableDefaultBackButton: true,
            title: state.fieldName ?? "Edit",
            right: _DoneButton(editValueCubit),
          ),
          body: Column(
            children: [
              const Gap(16.0),
              HSTextField(
                maxLines: state.fieldName == "biogram" ? 5 : 1,
                autofocus: true,
                onChanged: editValueCubit.changeValue,
                suffixIcon: const Opacity(
                  opacity: 0,
                  child: Icon(FontAwesomeIcons.pen),
                ),
                initialValue: state.value,
                errorText: state.errorText,
              ),
              const Gap(16.0),
              Text(state.fieldDescription ?? ""),
            ],
          ),
        );
      },
    );
  }
}

class _DoneButton extends StatelessWidget {
  const _DoneButton(this._editValueCubit);

  final HSEditValueCubit _editValueCubit;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<HSEditValueCubit, HSEditValueState, HSEditValueStatus>(
      selector: (state) => state.status,
      builder: (context, currentStatus) {
        final isDisabled = currentStatus != HSEditValueStatus.idle;
        return TextButton(
          onPressed: isDisabled
              ? null
              : () => _editValueCubit.updateUser(HSApp.instance.currentUser),
          child: _getChild(currentStatus),
        );
      },
    );
  }

  Widget _getChild(HSEditValueStatus status) {
    switch (status) {
      case HSEditValueStatus.idle ||
            HSEditValueStatus.updated ||
            HSEditValueStatus.failed:
        return const Text("Done");
      case HSEditValueStatus.loading:
        return const HSLoadingIndicator(
          size: 24.0,
          enableCenter: false,
        );
    }
  }
}

// class _Biogram extends EditValuePage {
//   const _Biogram({
//     this.maxLines = 5,
//     this.maxCharacters = 128,
//   });

//   final int maxLines;
//   final int maxCharacters;

//   @override
//   Widget build(BuildContext context) {
//     return EditValuePage();
//   }
// }

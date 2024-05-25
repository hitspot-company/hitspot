import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/features/boards/add_board/cubit/hs_add_board_cubit.dart';
import 'package:hitspot/widgets/hs_appbar.dart';
import 'package:hitspot/widgets/hs_button.dart';
import 'package:hitspot/widgets/hs_scaffold.dart';
import 'package:hitspot/widgets/hs_textfield.dart';

class AddBoardPage extends StatelessWidget {
  const AddBoardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final addBoardCubit = context.read<HSAddBoardCubit>();
    return HSScaffold(
        appBar: HSAppBar(
          enableDefaultBackButton: true,
          title: "New Board",
        ),
        body: Padding(
          padding: const EdgeInsets.only(top: 32.0),
          child: PageView(
            physics: const NeverScrollableScrollPhysics(),
            controller: addBoardCubit.state.pageController,
            children: [
              _FirstPage(addBoardCubit),
              Container(
                color: Colors.orange,
              )
            ],
          ),
        ));
  }
}

class _FirstPage extends StatelessWidget {
  const _FirstPage(this._addBoardCubit);
  final HSAddBoardCubit _addBoardCubit;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Text(
          "Step 1/5: basic information",
          style: textTheme.headlineMedium,
        ),
        Text(
          "Tell us more about your board.",
          style: textTheme.titleMedium,
        ),
        const SizedBox(
          height: 32.0,
        ),
        HSTextField(
          onChanged: _addBoardCubit.updateTitle,
          suffixIcon: const Icon(FontAwesomeIcons.a, color: Colors.transparent),
          hintText: "Title",
        ),
        const Gap(32.0),
        HSTextField(
          maxLines: 5,
          onChanged: _addBoardCubit.updateDescription,
          suffixIcon: const Icon(FontAwesomeIcons.a, color: Colors.transparent),
          hintText: "Description",
        ),
        const Gap(32.0),
        Align(
          alignment: Alignment.topRight,
          child: HSButton.icon(
            label: const Text("Customize"),
            onPressed: _addBoardCubit.nextPage,
            icon: const Icon(FontAwesomeIcons.arrowRight),
          ),
        )
      ],
    );
  }
}

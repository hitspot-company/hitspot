import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/widgets/hs_appbar.dart';
import 'package:hitspot/widgets/hs_button.dart';
import 'package:hitspot/widgets/hs_scaffold.dart';
import 'package:hitspot/widgets/hs_textfield.dart';
import 'package:hs_debug_logger/hs_debug_logger.dart';

class AddBoardPage extends StatelessWidget {
  const AddBoardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return HSScaffold(
        appBar: HSAppBar(
          enableDefaultBackButton: true,
          title: "New Board",
        ),
        body: Padding(
          padding: const EdgeInsets.only(top: 32.0),
          child: PageView(
            children: const [_FirstPage()],
          ),
        ));
  }
}

class _FirstPage extends StatelessWidget {
  const _FirstPage({super.key});

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
        const HSTextField(
          suffixIcon: Icon(FontAwesomeIcons.a, color: Colors.transparent),
          hintText: "Title",
        ),
        const Gap(32.0),
        const HSTextField(
          maxLines: 5,
          suffixIcon: Icon(FontAwesomeIcons.a, color: Colors.transparent),
          hintText: "Description",
        ),
        const Gap(32.0),
        Align(
          alignment: Alignment.topRight,
          child: HSButton.icon(
            label: const Text("Customize"),
            onPressed: () => HSDebugLogger.logInfo("customize"),
            icon: const Icon(FontAwesomeIcons.arrowRight),
          ),
        )
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/features/home/main/cubit/hs_home_cubit.dart';
import 'package:hitspot/features/spots/create/form/cubit/hs_spot_upload_cubit.dart';
import 'package:hitspot/widgets/hs_button.dart';

class HSUploadProgressWidget extends StatelessWidget {
  const HSUploadProgressWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HSSpotUploadCubit, HSSpotUploadState>(
      builder: (context, state) {
        if (state.status == HSUploadStatus.initial) {
          return const SizedBox.shrink();
        }
        final status = state.status;
        late final Color color;
        switch (status) {
          case HSUploadStatus.success:
            color = Colors.green;
            break;
          case HSUploadStatus.failure:
            color = Colors.red;
            break;
          default:
            color = app.theme.mainColor;
        }
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              LinearProgressIndicator(value: state.progress, color: color),
              const SizedBox(height: 8),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (state.status == HSUploadStatus.success)
                    IconButton(
                        onPressed: () =>
                            context.read<HSHomeCubit>().hideUploadBar(),
                        icon: const Icon(FontAwesomeIcons.xmark)),
                  Align(
                      alignment: Alignment.centerRight, child: button(status)),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  HSButton button(HSUploadStatus status) {
    final cubit = app.context.read<HSSpotUploadCubit>();
    late final String label;
    late final IconData icon;
    late final Function()? onPressed;

    switch (status) {
      case HSUploadStatus.success:
        label = 'View Spot';
        icon = Icons.visibility;
        onPressed = () => navi.toSpot(sid: cubit.state.spotId!);
        break;
      case HSUploadStatus.failure:
        label = 'Try Again';
        icon = Icons.refresh;
        onPressed = () => cubit.reset(); // TODO: Verify
        break;
      case HSUploadStatus.inProgress:
        label = 'Uploading';
        icon = Icons.timer;
        onPressed = null;
      default:
        label = '';
        icon = Icons.refresh;
        onPressed = () {};
    }
    return HSButton.icon(
      icon: Icon(icon),
      label: Text(label),
      onPressed: onPressed,
    );
  }
}

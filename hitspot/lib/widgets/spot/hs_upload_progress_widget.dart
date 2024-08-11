import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/features/spots/create/cubit/hs_spot_upload_cubit.dart';
import 'package:hitspot/widgets/hs_button.dart';

class HSUploadProgressWidget extends StatelessWidget {
  const HSUploadProgressWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<HSSpotUploadCubit>();
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
              if (state.status == HSUploadStatus.success)
                HSButton.icon(
                    icon: const Icon(Icons.visibility),
                    label: const Text('View Spot'),
                    onPressed: () {
                      navi.toSpot(sid: state.spotId!);
                      cubit.reset();
                    }),
              if (state.status == HSUploadStatus.failure)
                ElevatedButton(
                  onPressed: cubit.reset,
                  child: const Text('Try Again'),
                ),
            ],
          ),
        );
      },
    );
  }
}

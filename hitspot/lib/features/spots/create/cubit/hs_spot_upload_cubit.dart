import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/features/home/main/cubit/hs_home_cubit.dart';

part 'hs_spot_upload_state.dart';

class HSSpotUploadCubit extends Cubit<HSSpotUploadState> {
  HSSpotUploadCubit() : super(const HSSpotUploadState());

  void startUpload() {
    emit(state.copyWith(
        status: HSUploadStatus.inProgress, message: 'Starting upload...'));
  }

  void updateProgress(String message, double progress) {
    emit(state.copyWith(message: message, progress: progress));
  }

  void setSuccess(String spotId) {
    emit(state.copyWith(
      status: HSUploadStatus.success,
      message: 'Upload completed successfully',
      progress: 1.0,
      spotId: spotId,
    ));
  }

  void setFailure(String errorMessage) {
    emit(state.copyWith(
      status: HSUploadStatus.failure,
      message: 'Upload failed: $errorMessage',
    ));
  }

  void reset() {
    emit(const HSSpotUploadState());
  }
}

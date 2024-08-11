part of 'hs_spot_upload_cubit.dart';

enum HSUploadStatus { initial, inProgress, success, failure }

class HSSpotUploadState extends Equatable {
  final HSUploadStatus status;
  final String message;
  final double progress;
  final String? spotId;

  const HSSpotUploadState({
    this.status = HSUploadStatus.initial,
    this.message = '',
    this.progress = 0.0,
    this.spotId,
  });

  HSSpotUploadState copyWith({
    HSUploadStatus? status,
    String? message,
    double? progress,
    String? spotId,
  }) {
    return HSSpotUploadState(
      status: status ?? this.status,
      message: message ?? this.message,
      progress: progress ?? this.progress,
      spotId: spotId ?? this.spotId,
    );
  }

  @override
  List<Object?> get props => [status, message, progress, spotId];
}

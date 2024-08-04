part of 'hs_edit_profile_cubit.dart';

enum HSImageChangeState { idle, choosing, uploading, setting, done }

class HSEditProfileState extends Equatable {
  const HSEditProfileState(
      {this.imageChangeState = HSImageChangeState.idle,
      this.changeProgress = 0.0});

  final HSImageChangeState imageChangeState;
  final double changeProgress;

  @override
  List<Object> get props => [imageChangeState, changeProgress];

  HSEditProfileState copy({
    HSImageChangeState? imageChangeState,
    double? changeProgress,
  }) {
    return HSEditProfileState(
      imageChangeState: imageChangeState ?? this.imageChangeState,
      changeProgress: changeProgress ?? this.changeProgress,
    );
  }
}

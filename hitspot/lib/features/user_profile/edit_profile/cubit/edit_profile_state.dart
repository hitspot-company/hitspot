part of 'edit_profile_cubit.dart';

enum HSImageChangeState { idle, choosing, uploading, setting, done }

class EditProfileState extends Equatable {
  const EditProfileState(
      {this.imageChangeState = HSImageChangeState.idle,
      this.changeProgress = 0.0});

  final HSImageChangeState imageChangeState;
  final double changeProgress;

  @override
  List<Object> get props => [imageChangeState, changeProgress];

  EditProfileState copy({
    HSImageChangeState? imageChangeState,
    double? changeProgress,
  }) {
    return EditProfileState(
      imageChangeState: imageChangeState ?? this.imageChangeState,
      changeProgress: changeProgress ?? this.changeProgress,
    );
  }
}

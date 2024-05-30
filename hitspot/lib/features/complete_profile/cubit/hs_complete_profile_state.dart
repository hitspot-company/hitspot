part of 'hs_complete_profile_cubit.dart';

enum HSCompleteProfileStatus { idle, loading, error }

final class HSCompleteProfileState extends Equatable {
  const HSCompleteProfileState({
    this.completeProfileStatus = HSCompleteProfileStatus.idle,
    this.biogram = "",
    this.username = const Username.pure(),
    this.fullname = const Fullname.pure(),
    this.usernameValidationState = UsernameValidationState.empty,
    this.birthday = const Birthdate.pure(),
    this.error = "",
    this.avatar = "",
    this.loading = false,
  });

  final Username username;
  final Fullname fullname;
  final UsernameValidationState usernameValidationState;
  final Birthdate birthday;
  final String error;
  final String biogram;
  final String avatar;
  final bool loading;
  final HSCompleteProfileStatus completeProfileStatus;

  String? get usernameVal => username.value.isEmpty ? null : username.value;
  String? get fullnameVal => fullname.value.isEmpty ? null : fullname.value;
  String? get avatarVal => avatar.isEmpty ? null : avatar;
  String? get biogramVal => biogram.isEmpty ? null : biogram;
  Timestamp? get birthdayVal => birthday.value.dateTimeStringToTimestamp();

  @override
  List<Object?> get props => [
        username,
        fullname,
        biogram,
        birthday,
        usernameValidationState,
        error,
        loading,
        avatar,
        completeProfileStatus,
      ];

  HSCompleteProfileState copyWith({
    Username? username,
    Fullname? fullname,
    UsernameValidationState? usernameValidationState,
    Birthdate? birthday,
    String? error,
    String? biogram,
    String? avatar,
    bool? loading,
    HSCompleteProfileStatus? completeProfileStatus,
  }) {
    return HSCompleteProfileState(
      username: username ?? this.username,
      fullname: fullname ?? this.fullname,
      usernameValidationState:
          usernameValidationState ?? this.usernameValidationState,
      birthday: birthday ?? this.birthday,
      error: error ?? this.error,
      loading: loading ?? this.loading,
      biogram: biogram ?? this.biogram,
      avatar: avatar ?? this.avatar,
      completeProfileStatus:
          completeProfileStatus ?? this.completeProfileStatus,
    );
  }
}

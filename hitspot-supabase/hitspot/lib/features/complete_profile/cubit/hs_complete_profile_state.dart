part of 'hs_complete_profile_cubit.dart';

enum HSCompleteProfileStatus { idle, loading, error }

final class HSCompleteProfileState extends Equatable {
  const HSCompleteProfileState({
    this.completeProfileStatus = HSCompleteProfileStatus.idle,
    this.biogram = "",
    this.username = const HSUsername.pure(),
    this.fullname = const HSFullname.pure(),
    this.usernameValidationState = HSUsernameValidationState.empty,
    this.birthday = const HSBirthdate.pure(),
    this.error = "",
    this.avatar = "",
    this.loading = false,
  });

  final HSUsername username;
  final HSFullname fullname;
  final HSUsernameValidationState usernameValidationState;
  final HSBirthdate birthday;
  final String error;
  final String biogram;
  final String avatar;
  final bool loading;
  final HSCompleteProfileStatus completeProfileStatus;

  String? get usernameVal => username.value.isEmpty ? null : username.value;
  String? get fullnameVal => fullname.value.isEmpty ? null : fullname.value;
  String? get avatarVal => avatar.isEmpty ? null : avatar;
  String? get biogramVal => biogram.isEmpty ? null : biogram;
  DateTime? get birthdayVal => birthday.value.stringToDateTime();

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
    HSUsername? username,
    HSFullname? fullname,
    HSUsernameValidationState? usernameValidationState,
    HSBirthdate? birthday,
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

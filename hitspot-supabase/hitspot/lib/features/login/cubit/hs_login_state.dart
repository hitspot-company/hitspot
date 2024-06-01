part of 'hs_login_cubit.dart';

enum HSLoginStatus { idle, loading, error }

final class HSLoginState extends Equatable {
  const HSLoginState({
    this.email = const HSEmail.pure(),
    this.password = const HSPassword.pure(),
    this.loginStatus = HSLoginStatus.idle,
  });

  final HSLoginStatus loginStatus;
  final HSEmail email;
  final HSPassword password;

  HSLoginState copyWith({
    HSLoginStatus? loginStatus,
    HSEmail? email,
    HSPassword? password,
  }) {
    return HSLoginState(
      loginStatus: loginStatus ?? this.loginStatus,
      email: email ?? this.email,
      password: password ?? this.password,
    );
  }

  @override
  List<Object> get props => [loginStatus, email, password];
}

part of 'hs_board_invitation_cubit.dart';

class HSBoardInvitationState extends Equatable {
  final bool isLoading;
  final String? error;
  final bool isAccepted;

  const HSBoardInvitationState({
    this.isLoading = false,
    this.error,
    this.isAccepted = false,
  });

  HSBoardInvitationState copyWith({
    bool? isLoading,
    String? error,
    bool? isAccepted,
  }) {
    return HSBoardInvitationState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isAccepted: isAccepted ?? this.isAccepted,
    );
  }

  @override
  List<Object?> get props => [isLoading, error, isAccepted];
}

part of 'hs_board_invitation_cubit.dart';

class HSBoardInvitationState extends Equatable {
  final bool isLoading;
  final String? error;
  final bool isAccepted;
  final Image? boardImage;
  final String? boardAuthor;
  final String? boardTitle;

  const HSBoardInvitationState({
    this.isLoading = false,
    this.error,
    this.isAccepted = false,
    this.boardImage,
    this.boardAuthor,
    this.boardTitle,
  });

  HSBoardInvitationState copyWith({
    bool? isLoading,
    String? error,
    bool? isAccepted,
    Image? boardImage,
    String? boardAuthor,
    String? boardTitle,
  }) {
    return HSBoardInvitationState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isAccepted: isAccepted ?? this.isAccepted,
      boardImage: boardImage ?? this.boardImage,
      boardAuthor: boardAuthor ?? this.boardAuthor,
      boardTitle: boardTitle ?? this.boardTitle,
    );
  }

  @override
  List<Object?> get props =>
      [isLoading, error, isAccepted, boardImage, boardAuthor, boardTitle];
}

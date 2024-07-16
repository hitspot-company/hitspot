part of 'hs_board_invitation_cubit.dart';

class HSBoardInvitationState extends Equatable {
  final bool isLoading;
  final String? error;
  final bool isAccepted;
  final HSBoard? board;
  final Image? boardImage;
  final String? boardAuthor;

  const HSBoardInvitationState({
    this.isLoading = false,
    this.error,
    this.isAccepted = false,
    this.board,
    this.boardImage,
    this.boardAuthor,
  });

  HSBoardInvitationState copyWith({
    bool? isLoading,
    String? error,
    bool? isAccepted,
    HSBoard? board,
    Image? boardImage,
    String? boardAuthor,
  }) {
    return HSBoardInvitationState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isAccepted: isAccepted ?? this.isAccepted,
      board: board ?? this.board,
      boardImage: boardImage ?? this.boardImage,
      boardAuthor: boardAuthor ?? this.boardAuthor,
    );
  }

  @override
  List<Object?> get props =>
      [isLoading, error, isAccepted, board, boardImage, boardAuthor];
}

part of 'hs_single_board_cubit.dart';

enum HSSingleBoardStatus { loading, idle, error, updating }

final class HSSingleBoardState extends Equatable {
  const HSSingleBoardState({
    this.status = HSSingleBoardStatus.loading,
    this.board,
    this.author,
    this.isBoardSaved = false,
    this.isEditor = false,
  });

  final HSSingleBoardStatus status;
  final HSBoard? board;
  final HSUser? author;
  final bool isBoardSaved;
  final bool isEditor;

  @override
  List<Object?> get props => [status, board, author, isBoardSaved, isEditor];

  HSSingleBoardState copyWith({
    HSSingleBoardStatus? status,
    HSBoard? board,
    HSUser? author,
    bool? isBoardSaved,
    bool? isEditor,
  }) {
    return HSSingleBoardState(
      status: status ?? this.status,
      board: board ?? this.board,
      author: author ?? this.author,
      isEditor: isEditor ?? this.isEditor,
      isBoardSaved: isBoardSaved ?? this.isBoardSaved,
    );
  }
}

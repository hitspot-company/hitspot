part of 'hs_single_board_cubit.dart';

enum HSSingleBoardStatus { loading, idle, error }

final class HSSingleBoardState extends Equatable {
  const HSSingleBoardState({
    this.status = HSSingleBoardStatus.loading,
    this.board,
    this.author,
  });

  final HSSingleBoardStatus status;
  final HSBoard? board;
  final HSUser? author;

  @override
  List<Object?> get props => [status, board, author];

  HSSingleBoardState copyWith({
    HSSingleBoardStatus? status,
    HSBoard? board,
    HSUser? author,
  }) {
    return HSSingleBoardState(
      status: status ?? this.status,
      board: board ?? this.board,
      author: author ?? this.author,
    );
  }
}

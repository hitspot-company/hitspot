part of 'hs_single_board_cubit.dart';

enum HSSingleBoardStatus { loading, idle, error, updating, editing }

final class HSSingleBoardState extends Equatable {
  const HSSingleBoardState({
    this.status = HSSingleBoardStatus.loading,
    this.board,
    this.author,
    this.isBoardSaved = false,
    this.isEditor = false,
    this.isOwner = false,
    this.spots = const [],
  });

  final HSSingleBoardStatus status;
  final HSBoard? board;
  final HSUser? author;
  final bool isBoardSaved;
  final bool isEditor;
  final bool isOwner;

  final List<HSSpot> spots;

  @override
  List<Object?> get props =>
      [status, board, author, isBoardSaved, isEditor, spots];

  HSSingleBoardState copyWith({
    HSSingleBoardStatus? status,
    HSBoard? board,
    HSUser? author,
    bool? isBoardSaved,
    bool? isEditor,
    bool? isOwner,
    List<HSSpot>? spots,
  }) {
    return HSSingleBoardState(
      status: status ?? this.status,
      board: board ?? this.board,
      author: author ?? this.author,
      isEditor: isEditor ?? this.isEditor,
      isOwner: isOwner ?? this.isOwner,
      isBoardSaved: isBoardSaved ?? this.isBoardSaved,
      spots: spots ?? this.spots,
    );
  }
}

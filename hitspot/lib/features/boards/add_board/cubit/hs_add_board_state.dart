part of 'hs_add_board_cubit.dart';

enum HSAddBoardUploadState { initial, uploading, error }

final class HSAddBoardState extends Equatable {
  const HSAddBoardState({
    this.title = "",
    this.description = "",
    this.color,
    this.image = "",
    this.boardVisibility = HSBoardVisibility.private,
    this.uploadState = HSAddBoardUploadState.initial,
    this.errorText,
  });

  final String title;
  final String description;
  final Color? color;
  final String image;
  final HSBoardVisibility boardVisibility;
  final HSAddBoardUploadState uploadState;
  final String? errorText;

  @override
  List<Object?> get props => [
        title,
        description,
        color,
        image,
        boardVisibility,
        uploadState,
        errorText,
      ];

  HSAddBoardState copyWith({
    int? page,
    String? title,
    String? description,
    Color? color,
    String? image,
    HSBoardVisibility? boardVisibility,
    HSAddBoardUploadState? uploadState,
    String? errorText,
  }) {
    return HSAddBoardState(
      title: title ?? this.title,
      description: description ?? this.description,
      color: color == Colors.transparent ? null : color ?? this.color,
      image: image ?? this.image,
      boardVisibility: boardVisibility ?? this.boardVisibility,
      uploadState: uploadState ?? this.uploadState,
      errorText: errorText,
    );
  }

  factory HSAddBoardState.update(HSBoard board) {
    return HSAddBoardState(
      title: board.title!,
      description: board.description!,
      color: board.color,
      image: board.image ?? "",
      boardVisibility: board.boardVisibility!,
    );
  }
}

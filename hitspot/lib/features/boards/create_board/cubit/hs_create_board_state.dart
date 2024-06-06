part of 'hs_create_board_cubit.dart';

enum HSAddBoardUploadState { initial, uploading, error }

final class HSCreateBoardState extends Equatable {
  const HSCreateBoardState({
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

  HSCreateBoardState copyWith({
    int? page,
    String? title,
    String? description,
    Color? color,
    String? image,
    HSBoardVisibility? boardVisibility,
    HSAddBoardUploadState? uploadState,
    String? errorText,
  }) {
    return HSCreateBoardState(
      title: title ?? this.title,
      description: description ?? this.description,
      color: color == Colors.transparent ? null : color ?? this.color,
      image: image ?? this.image,
      boardVisibility: boardVisibility ?? this.boardVisibility,
      uploadState: uploadState ?? this.uploadState,
      errorText: errorText,
    );
  }

  factory HSCreateBoardState.update(HSBoard board) {
    return HSCreateBoardState(
      title: board.title!,
      description: board.description!,
      color: board.color,
      image: board.image ?? "",
      boardVisibility: board.boardVisibility!,
    );
  }
}

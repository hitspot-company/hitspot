part of 'hs_add_board_cubit.dart';

enum HSAddBoardUploadState { initial, uploading, error }

final class HSAddBoardState extends Equatable {
  const HSAddBoardState({
    this.title = "",
    this.description = "",
    this.tripBudget = 0.0,
    this.tripDate = "",
    this.color,
    this.image,
    this.boardVisibility = HSBoardVisibility.private,
    this.uploadState = HSAddBoardUploadState.initial,
  });

  final String title;
  final String description;
  final double tripBudget;
  final String tripDate;
  final Color? color;
  final String? image;
  final HSBoardVisibility boardVisibility;
  final HSAddBoardUploadState uploadState;

  @override
  List<Object?> get props => [
        title,
        description,
        tripBudget,
        tripDate,
        color,
        image,
        boardVisibility,
        uploadState,
      ];

  HSAddBoardState copyWith({
    int? page,
    String? title,
    String? description,
    double? tripBudget,
    String? tripDate,
    Color? color,
    String? image,
    HSBoardVisibility? boardVisibility,
    HSAddBoardUploadState? uploadState,
  }) {
    return HSAddBoardState(
      title: title ?? this.title,
      description: description ?? this.description,
      tripBudget: tripBudget ?? this.tripBudget,
      tripDate: tripDate ?? this.tripDate,
      color: color ?? this.color,
      image: image ?? this.image,
      boardVisibility: boardVisibility ?? this.boardVisibility,
      uploadState: uploadState ?? this.uploadState,
    );
  }
}

part of 'hs_add_board_cubit.dart';

final class HSAddBoardState extends Equatable {
  HSAddBoardState({
    this.title = "",
    this.description = "",
    this.tripBudget = 0.0,
    this.tripDate = "",
    this.color = "",
    this.image = "",
  });

  final String title;
  final String description;
  final double tripBudget;
  final String tripDate;
  final String color;
  final String image;
  final PageController pageController = PageController();

  @override
  List<Object> get props => [
        title,
        description,
        tripBudget,
        tripDate,
        color,
        image,
      ];

  HSAddBoardState copyWith({
    int? page,
    String? title,
    String? description,
    double? tripBudget,
    String? tripDate,
    String? color,
    String? image,
  }) {
    return HSAddBoardState(
      title: title ?? this.title,
      description: description ?? this.description,
      tripBudget: tripBudget ?? this.tripBudget,
      tripDate: tripDate ?? this.tripDate,
      color: color ?? this.color,
      image: image ?? this.image,
    );
  }
}

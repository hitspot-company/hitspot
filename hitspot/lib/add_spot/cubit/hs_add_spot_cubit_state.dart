part of 'hs_add_spot_cubit_cubit.dart';

final class HSAddSpotCubitState extends Equatable {
  const HSAddSpotCubitState({this.title = ""});
  final String title;

  @override
  List<Object> get props => [
        title,
      ];

  HSAddSpotCubitState copyWith({String? title}) {
    return HSAddSpotCubitState(title: title ?? this.title);
  }
}

final class HsAddSpotCubitInitial extends HSAddSpotCubitState {}

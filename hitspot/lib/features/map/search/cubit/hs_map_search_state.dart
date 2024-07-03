part of 'hs_map_search_cubit.dart';

final class HSMapSearchState extends Equatable {
  const HSMapSearchState({this.predictions = const [], this.query = ""});

  final List<HSPrediction> predictions;
  final String query;

  @override
  List<Object> get props => [predictions, query];

  HSMapSearchState copyWith({
    List<HSPrediction>? predictions,
    String? query,
  }) {
    return HSMapSearchState(
      predictions: predictions ?? this.predictions,
      query: query ?? this.query,
    );
  }
}

part of 'hs_map_search_cubit.dart';

enum HSMapSearchStatus { initial, loading, success, failure }

class HSMapSearchState extends Equatable {
  const HSMapSearchState({
    this.query = '',
    this.predictions = const [],
    this.status = HSMapSearchStatus.initial,
  });

  final String query;
  final List<HSPrediction> predictions;
  final HSMapSearchStatus status;

  HSMapSearchState copyWith({
    String? query,
    List<HSPrediction>? predictions,
    HSMapSearchStatus? status,
  }) {
    return HSMapSearchState(
      query: query ?? this.query,
      predictions: predictions ?? this.predictions,
      status: status ?? this.status,
    );
  }

  @override
  List<Object> get props => [query, predictions, status];
}

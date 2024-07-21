part of 'hs_single_spot_comments_cubit.dart';

enum HSSingleSpotCommentsStatus {
  loading,
  loaded,
  error,
  commenting,
  finishedCommenting,
}

class HSSingleSpotCommentsCubitState extends Equatable {
  const HSSingleSpotCommentsCubitState({
    this.status = HSSingleSpotCommentsStatus.loading,
    this.comment = "",
  });

  final HSSingleSpotCommentsStatus status;
  final String comment;

  @override
  List<Object> get props => [status, comment];

  HSSingleSpotCommentsCubitState copyWith({
    HSSingleSpotCommentsStatus? status,
    String? comment,
  }) {
    return HSSingleSpotCommentsCubitState(
      status: status ?? this.status,
      comment: comment ?? this.comment,
    );
  }
}

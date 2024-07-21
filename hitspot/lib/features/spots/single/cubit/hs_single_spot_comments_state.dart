part of 'hs_single_spot_comments_cubit.dart';

enum HSSingleSpotCommentsStatus {
  loading,
  loaded,
  error,
  commenting,
  finishedCommenting,
  loadingMoreComments,
}

class HSSingleSpotCommentsCubitState extends Equatable {
  const HSSingleSpotCommentsCubitState({
    this.status = HSSingleSpotCommentsStatus.loading,
    this.fetchedComments = const [],
    this.comment = "",
  });

  final HSSingleSpotCommentsStatus status;
  final List<HSComment> fetchedComments;
  final String comment;

  @override
  List<Object> get props => [status, comment, fetchedComments];

  HSSingleSpotCommentsCubitState copyWith({
    HSSingleSpotCommentsStatus? status,
    List<HSComment>? fetchedComments,
    String? comment,
  }) {
    return HSSingleSpotCommentsCubitState(
      status: status ?? this.status,
      fetchedComments: fetchedComments ?? this.fetchedComments,
      comment: comment ?? this.comment,
    );
  }
}

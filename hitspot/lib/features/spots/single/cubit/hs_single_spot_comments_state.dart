part of 'hs_single_spot_comments_cubit.dart';

enum HSSingleSpotCommentsPageStatus {
  comments,
  replies,
}

enum HsSingleSpotCommentsCommentingStatus {
  idle,
  commenting,
  finishedCommenting,
}

enum HSSingleSpotCommentsStatus {
  loading,
  loadingMoreComments,
  loadingReplies,
  loaded,
  error,
}

class HSSingleSpotCommentsCubitState extends Equatable {
  const HSSingleSpotCommentsCubitState({
    this.pageStatus = HSSingleSpotCommentsPageStatus.comments,
    this.status = HSSingleSpotCommentsStatus.loading,
    this.commentingStatus = HsSingleSpotCommentsCommentingStatus.idle,
    this.fetchedComments = const [],
    this.comment = "",
    this.indexOfCommentUnderReply = -1,
    this.fetchedReplies = const [],
  });

  final HSSingleSpotCommentsPageStatus pageStatus;
  final HSSingleSpotCommentsStatus status;
  final HsSingleSpotCommentsCommentingStatus commentingStatus;
  final List<HSComment> fetchedComments;
  final String comment;
  final int indexOfCommentUnderReply;
  final List<HSComment> fetchedReplies;

  @override
  List<Object> get props => [
        pageStatus,
        status,
        commentingStatus,
        comment,
        fetchedComments,
        indexOfCommentUnderReply,
        fetchedReplies,
      ];

  HSSingleSpotCommentsCubitState copyWith({
    HSSingleSpotCommentsPageStatus? pageStatus,
    HSSingleSpotCommentsStatus? status,
    HsSingleSpotCommentsCommentingStatus? commentingStatus,
    List<HSComment>? fetchedComments,
    String? comment,
    int? indexOfCommentUnderReply,
    List<HSComment>? fetchedReplies,
  }) {
    return HSSingleSpotCommentsCubitState(
      pageStatus: pageStatus ?? this.pageStatus,
      status: status ?? this.status,
      commentingStatus: commentingStatus ?? this.commentingStatus,
      fetchedComments: fetchedComments ?? this.fetchedComments,
      comment: comment ?? this.comment,
      indexOfCommentUnderReply:
          indexOfCommentUnderReply ?? this.indexOfCommentUnderReply,
      fetchedReplies: fetchedReplies ?? this.fetchedReplies,
    );
  }
}

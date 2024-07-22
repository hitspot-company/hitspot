part of 'hs_single_spot_comments_cubit.dart';

enum HSSingleSpotCommentsPageType {
  comments,
  replies,
}

enum HSSingleSpotCommentsStatus {
  loading,
  loaded,
  error,
  commenting,
  finishedCommenting,
  loadingMoreComments,
  loadingReplies,
}

class HSSingleSpotCommentsCubitState extends Equatable {
  const HSSingleSpotCommentsCubitState({
    this.pageStatus = HSSingleSpotCommentsPageType.comments,
    this.status = HSSingleSpotCommentsStatus.loading,
    this.fetchedComments = const [],
    this.comment = "",
    this.indexOfCommentUnderReply = -1,
    this.fetchedReplies = const [],
  });

  final HSSingleSpotCommentsPageType pageStatus;
  final HSSingleSpotCommentsStatus status;
  final List<HSComment> fetchedComments;
  final String comment;
  final int indexOfCommentUnderReply;
  final List<HSComment> fetchedReplies;

  @override
  List<Object> get props => [
        pageStatus,
        status,
        comment,
        fetchedComments,
        indexOfCommentUnderReply,
        fetchedReplies,
      ];

  HSSingleSpotCommentsCubitState copyWith({
    HSSingleSpotCommentsPageType? pageStatus,
    HSSingleSpotCommentsStatus? status,
    List<HSComment>? fetchedComments,
    String? comment,
    int? indexOfCommentUnderReply,
    List<HSComment>? fetchedReplies,
  }) {
    return HSSingleSpotCommentsCubitState(
      pageStatus: pageStatus ?? this.pageStatus,
      status: status ?? this.status,
      fetchedComments: fetchedComments ?? this.fetchedComments,
      comment: comment ?? this.comment,
      indexOfCommentUnderReply:
          indexOfCommentUnderReply ?? this.indexOfCommentUnderReply,
      fetchedReplies: fetchedReplies ?? this.fetchedReplies,
    );
  }
}

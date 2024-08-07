import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hs_database_repository/hs_database_repository.dart';
import 'package:hs_debug_logger/hs_debug_logger.dart';

part 'hs_single_spot_comments_state.dart';

class HSSingleSpotCommentsCubit extends Cubit<HSSingleSpotCommentsState> {
  HSSingleSpotCommentsCubit({required this.spotID})
      : super(const HSSingleSpotCommentsState()) {
    emit(state.copyWith(status: HSSingleSpotCommentsStatus.loading));
    fetchComments();
  }

  final HSDatabaseRepsitory _databaseRepository = app.databaseRepository;
  final String spotID;
  final TextEditingController commentController = TextEditingController();

  int pagesOfCommentsLoaded = 0;
  int pagesOfRepliesLoaded = 0;

  void commentChanged(String comment) {
    emit(state.copyWith(comment: comment));
  }

  Future<void> fetchComments() async {
    bool isReply = state.pageStatus == HSSingleSpotCommentsPageStatus.replies;

    if (state.status == HSSingleSpotCommentsStatus.loaded) {
      emit(state.copyWith(
          status: HSSingleSpotCommentsStatus.loadingMoreComments));
    }

    List<HSComment> comments = await _databaseRepository.spotFetchComments(
      spotID: isReply
          ? state.fetchedComments[state.indexOfCommentUnderReply].id
          : spotID,
      userID: app.currentUser.uid ?? "",
      currentPageOffset: isReply ? pagesOfRepliesLoaded : pagesOfCommentsLoaded,
      isReply: isReply,
    );

    // Get authors of comments
    for (int i = 0; i < comments.length; i++) {
      final comment = comments[i];
      final author =
          await _databaseRepository.userRead(userID: comment.createdBy);
      comment.author = author;
    }

    // Pagination
    if (comments.isNotEmpty) {
      if (isReply) {
        pagesOfRepliesLoaded += comments.length;
      } else {
        pagesOfCommentsLoaded += comments.length;
      }
    }

    await Future<void>.delayed(const Duration(seconds: 1));

    if (isReply) {
      emit(state.copyWith(
          fetchedReplies: [...state.fetchedReplies, ...comments],
          status: HSSingleSpotCommentsStatus.loaded));
    } else {
      emit(state.copyWith(
          fetchedComments: [...state.fetchedComments, ...comments],
          status: HSSingleSpotCommentsStatus.loaded));
    }
  }

  Future<void> addComment() async {
    try {
      emit(state.copyWith(
          commentingStatus: HsSingleSpotCommentsCommentingStatus.commenting));

      bool isReply = state.pageStatus == HSSingleSpotCommentsPageStatus.replies;

      // Here we check for bad language, but for now I think we can leave it commented
      // final filter = ProfanityFilter();
      // if (filter.hasProfanity(state.comment)) {
      //   HSDebugLogger.logInfo("Bad language detected");
      //   return;
      //   // TODO: Display some error message
      // }

      if (state.comment == "") {
        emit(state.copyWith(
            commentingStatus: HsSingleSpotCommentsCommentingStatus.idle));
        return;
      }

      await Future.delayed(const Duration(seconds: 1));

      late HSComment newComment;

      if (isReply) {
        newComment = await _databaseRepository.spotAddComment(
            spotID: spotID,
            userID: app.currentUser.uid ?? "",
            comment: state.comment,
            isReply: isReply,
            parentCommentID:
                state.fetchedComments[state.indexOfCommentUnderReply].id);

        // Increate share counter of parent comment
        var updatedNormalComments = List<HSComment>.from(state.fetchedComments);

        updatedNormalComments[state.indexOfCommentUnderReply] =
            updatedNormalComments[state.indexOfCommentUnderReply].copyWith(
          repliesCount: updatedNormalComments[state.indexOfCommentUnderReply]
                  .repliesCount +
              1,
        );

        commentController.clear();
        emit(state.copyWith(
          comment: "",
          fetchedReplies: [newComment, ...state.fetchedReplies],
          fetchedComments: updatedNormalComments,
          commentingStatus:
              HsSingleSpotCommentsCommentingStatus.finishedCommenting,
        ));
      } else {
        newComment = await _databaseRepository.spotAddComment(
            spotID: spotID,
            userID: app.currentUser.uid ?? "",
            comment: state.comment,
            isReply: isReply);

        commentController.clear();
        emit(state.copyWith(
            comment: "",
            fetchedComments: [newComment, ...state.fetchedComments],
            commentingStatus:
                HsSingleSpotCommentsCommentingStatus.finishedCommenting));
      }

      newComment.author = currentUser;

      emit(state.copyWith(
          comment: "",
          commentingStatus:
              HsSingleSpotCommentsCommentingStatus.finishedCommenting));

      emit(state.copyWith(
          commentingStatus: HsSingleSpotCommentsCommentingStatus.idle));

      HSSpot spot = await _databaseRepository.spotRead(spotID: spotID);
      _databaseRepository.recommendationSystemCaptureEvent(
          userId: app.currentUser.uid ?? "",
          spot: spot,
          event: HSInteractionType.comment);
    } catch (_) {
      HSDebugLogger.logError("Error adding comment ${_.toString()}");
    }
  }

  Future<void> likeOrDislikeComment(
      {required HSComment comment,
      required int index,
      required bool isReply}) async {
    await _databaseRepository.spotLikeOrDislikeComment(
        commentID: comment.id, userID: app.currentUser.uid ?? "");

    var updatedComments = List<HSComment>.from(
        isReply ? state.fetchedReplies : state.fetchedComments);

    updatedComments[index] = updatedComments[index].copyWith(
      isLiked: !updatedComments[index].isLiked,
      likesCount: updatedComments[index].isLiked
          ? updatedComments[index].likesCount - 1
          : updatedComments[index].likesCount + 1,
    );

    if (isReply) {
      emit(state.copyWith(fetchedReplies: updatedComments));
    } else {
      emit(state.copyWith(fetchedComments: updatedComments));
    }
  }

  Future<void> goToReplyToComment(HSComment comment, int index) async {
    emit(state.copyWith(
        indexOfCommentUnderReply: index,
        pageStatus: HSSingleSpotCommentsPageStatus.replies,
        status: HSSingleSpotCommentsStatus.loadingReplies));

    // Fetch replies
    await fetchComments();
  }

  Future<void> leaveReplyingToComment() async {
    emit(state.copyWith(
        pageStatus: HSSingleSpotCommentsPageStatus.comments,
        indexOfCommentUnderReply: -1,
        fetchedReplies: [],
        status: HSSingleSpotCommentsStatus.loaded));

    pagesOfRepliesLoaded = 0;
  }

  Future<void> removeComment(
      {required HSComment comment,
      required int index,
      required bool isReply}) async {
    await _databaseRepository.spotRemoveComment(
        commentID: comment.id, userID: app.currentUser.uid ?? "");

    var updatedComments = List<HSComment>.from(
        isReply ? state.fetchedReplies : state.fetchedComments);
    updatedComments.removeAt(index);

    // Decrease replies count of parent comment
    if (isReply) {
      List<HSComment> updatedNormalComments =
          List<HSComment>.from(state.fetchedComments);

      updatedNormalComments[state.indexOfCommentUnderReply] =
          updatedNormalComments[state.indexOfCommentUnderReply].copyWith(
        repliesCount:
            updatedNormalComments[state.indexOfCommentUnderReply].repliesCount -
                1,
      );
      emit(state.copyWith(fetchedComments: updatedNormalComments));
    }

    if (isReply) {
      pagesOfRepliesLoaded -= 1;

      emit(state.copyWith(fetchedReplies: updatedComments));
    } else {
      pagesOfCommentsLoaded -= 1;

      emit(state.copyWith(fetchedComments: updatedComments));
    }
  }

  @override
  Future<void> close() {
    commentController.dispose();
    return super.close();
  }
}

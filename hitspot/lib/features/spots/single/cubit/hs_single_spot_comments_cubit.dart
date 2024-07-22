import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hs_authentication_repository/hs_authentication_repository.dart';
import 'package:hs_database_repository/src/spots/hs_comment.dart';
import 'package:hs_database_repository/hs_database_repository.dart';
import 'package:hs_debug_logger/hs_debug_logger.dart';

part 'hs_single_spot_comments_state.dart';

class HSSingleSpotCommentsCubit extends Cubit<HSSingleSpotCommentsCubitState> {
  HSSingleSpotCommentsCubit({required this.spotID})
      : super(const HSSingleSpotCommentsCubitState()) {
    emit(state.copyWith(status: HSSingleSpotCommentsStatus.loading));
    fetchComments();
  }

  final HSDatabaseRepsitory _databaseRepository = app.databaseRepository;
  final String spotID;

  int pagesOfCommentsLoaded = 0;
  int pagesOfRepliesLoaded = 0;

  void commentChanged(String comment) {
    emit(state.copyWith(comment: comment));
  }

  Future<void> fetchComments() async {
    bool isReply = state.pageStatus == HSSingleSpotCommentsPageType.replies;

    if (state.status == HSSingleSpotCommentsStatus.loaded) {
      emit(state.copyWith(
          status: HSSingleSpotCommentsStatus.loadingMoreComments));
    }

    await Future<void>.delayed(const Duration(seconds: 1));

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
      emit(state.copyWith(status: HSSingleSpotCommentsStatus.commenting));

      bool isReply = state.pageStatus == HSSingleSpotCommentsPageType.replies;

      // TODO: Check if goes through filter
      if (state.comment == "") {
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
        emit(state.copyWith(
            fetchedReplies: [newComment, ...state.fetchedReplies],
            status: HSSingleSpotCommentsStatus.loaded));
      } else {
        newComment = await _databaseRepository.spotAddComment(
            spotID: spotID,
            userID: app.currentUser.uid ?? "",
            comment: state.comment,
            isReply: isReply);
        emit(state.copyWith(
            fetchedComments: [newComment, ...state.fetchedComments],
            status: HSSingleSpotCommentsStatus.loaded));
      }

      newComment.author = currentUser;

      emit(state.copyWith(comment: ""));

      // Emit state to clear the comment field
      emit(state.copyWith(
          status: HSSingleSpotCommentsStatus.finishedCommenting));

      emit(state.copyWith(status: HSSingleSpotCommentsStatus.loaded));
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
        pageStatus: HSSingleSpotCommentsPageType.replies,
        status: HSSingleSpotCommentsStatus.loadingReplies));

    // Fetch replies
    await fetchComments();
  }

  Future<void> leaveReplyingToComment() async {
    emit(state.copyWith(
        pageStatus: HSSingleSpotCommentsPageType.comments,
        indexOfCommentUnderReply: -1,
        fetchedReplies: [],
        status: HSSingleSpotCommentsStatus.loaded));

    pagesOfRepliesLoaded = 0;
  }
}

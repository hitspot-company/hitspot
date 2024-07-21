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
    fetchComments();
  }

  final HSDatabaseRepsitory _databaseRepository = app.databaseRepository;
  final String spotID;

  int pagesOfCommentsLoaded = 0;

  void commentChanged(String comment) {
    emit(state.copyWith(comment: comment));
  }

  Future<void> fetchComments() async {
    emit(
        state.copyWith(status: HSSingleSpotCommentsStatus.loadingMoreComments));

    List<Map<HSComment, bool>> comments =
        await _databaseRepository.spotFetchComments(
            spotID: spotID,
            userID: app.currentUser.uid ?? "",
            currentPageOffset: pagesOfCommentsLoaded);

    // Get authors of comments
    for (int i = 0; i < comments.length; i++) {
      final comment = comments[i].keys.first;
      final author =
          await _databaseRepository.userRead(userID: comment.createdBy);
      comment.author = author;
    }

    if (comments.isNotEmpty) {
      pagesOfCommentsLoaded += comments.length;
      HSDebugLogger.logSuccess("Fetched new comments for spot $spotID");
    }

    emit(state
        .copyWith(fetchedComments: [...state.fetchedComments, ...comments]));

    emit(state.copyWith(status: HSSingleSpotCommentsStatus.loaded));
  }

  Future<void> addComment() async {
    try {
      emit(state.copyWith(status: HSSingleSpotCommentsStatus.commenting));

      // TODO: Check if goes through filter
      if (state.comment == "") {
        return;
      }

      await Future.delayed(const Duration(seconds: 1));

      HSComment newComment = await _databaseRepository.spotAddComment(
          spotID: spotID,
          userID: app.currentUser.uid ?? "",
          comment: state.comment);

      newComment.author = app.currentUser;

      emit(state.copyWith(fetchedComments: [
        {newComment: false},
        ...state.fetchedComments
      ]));

      emit(state.copyWith(comment: ""));

      // Emit state to clear the comment field
      emit(state.copyWith(
          status: HSSingleSpotCommentsStatus.finishedCommenting));

      emit(state.copyWith(status: HSSingleSpotCommentsStatus.loaded));
    } catch (_) {
      HSDebugLogger.logError("Error adding comment ${_.toString()}");
    }
  }

  Future<void> likeOrDislikeComment(HSComment comment, int index) async {
    await _databaseRepository.spotLikeOrDislikeComment(
        commentID: comment.id, userID: app.currentUser.uid ?? "");

    var updatedComments =
        List<Map<HSComment, bool>>.from(state.fetchedComments);

    // Like or dislike
    var commentMap = Map<HSComment, bool>.from(updatedComments[index]);
    commentMap[comment] = !(commentMap[comment] ?? false);

    // Change counter
    updatedComments[index].keys.first.likesCount +=
        (commentMap[comment] ?? false) ? 1 : -1;
    updatedComments[index] = commentMap;

    emit(state.copyWith(fetchedComments: updatedComments));
  }
}

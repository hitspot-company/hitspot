import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hitspot/constants/constants.dart';
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

    List<HSComment> comments = await _databaseRepository.spotFetchComments(
        spotID: spotID, currentPageOffset: pagesOfCommentsLoaded);

    // Get authors of comments
    for (int i = 0; i < comments.length; i++) {
      HSComment comment = comments[i];
      comment.author =
          await _databaseRepository.userRead(userID: comment.createdBy);
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

      emit(state
          .copyWith(fetchedComments: [newComment, ...state.fetchedComments]));

      emit(state.copyWith(comment: ""));

      // Emit state to clear the comment field
      emit(state.copyWith(
          status: HSSingleSpotCommentsStatus.finishedCommenting));

      emit(state.copyWith(status: HSSingleSpotCommentsStatus.loaded));
    } catch (_) {
      HSDebugLogger.logError("Error adding comment ${_.toString()}");
    }
  }
}

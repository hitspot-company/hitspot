import 'dart:ui';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:hitspot/features/app/hs_app.dart';
import 'package:hs_authentication_repository/hs_authentication_repository.dart';
import 'package:hs_database_repository/hs_database_repository.dart';

part 'hs_board_invitation_state.dart';

class HsBoardInvitationCubit extends Cubit<HSBoardInvitationState> {
  final String boardId;
  final String token;
  final HSDatabaseRepsitory _databaseRepository = HSApp().databaseRepository;

  HsBoardInvitationCubit({
    required this.boardId,
    required this.token,
  }) : super(const HSBoardInvitationState()) {
    loadBoardInvitation();
  }

  Future<void> loadBoardInvitation() async {
    try {
      emit(state.copyWith(isLoading: true));

      // Check if invitation is valid
      bool isValid = await _databaseRepository.boardCheckIfInvitationIsValid(
          boardId: boardId, token: token, userId: HSApp().currentUser.uid!);
      if (!isValid) {
        emit(state.copyWith(
            error: 'Invalid board ID or token',
            isLoading: false,
            isAccepted: false));
        return;
      }

      // Add user to board collaborators as invited
      await _databaseRepository.boardAddPotentialCollaboratorAsInvited(
          boardId: boardId, userId: HSApp().currentUser.uid!);

      emit(state.copyWith(error: ""));

      // Read board contents
      final board = await _databaseRepository.boardFetchBoardForInvitation(
          boardId: boardId);

      if (board == null) {
        emit(state.copyWith(error: 'Invalid board ID or token'));
        return;
      }

      Image? boardImage;
      String? boardAuthor;

      if (board.createdBy != null) {
        final author =
            await _databaseRepository.userRead(userID: board.createdBy);
        boardAuthor = author.username;
      }

      if (board.thumbnail != null) {
        boardImage = Image.network(board.thumbnail!);
      } else if (board.image != null) {
        boardImage = Image.network(board.image!);
      }

      emit(state.copyWith(
          isLoading: false,
          boardTitle: board.title,
          boardImage: boardImage,
          boardAuthor: boardAuthor));
    } catch (e) {
      emit(state.copyWith(error: 'Invalid board ID or token'));
    }
  }

  Future<void> acceptInvitation() async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      await _databaseRepository.boardAddCollaborator(
          boardId: boardId, userId: HSApp().currentUser.uid!);

      emit(state.copyWith(isLoading: false, isAccepted: true));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> declineInvitation() async {
    emit(state.copyWith(isLoading: true, error: null));

    await _databaseRepository.boardRemovePotentialCollaboratorFromInvited(
        boardId: boardId, userId: HSApp().currentUser.uid!);

    emit(state.copyWith(isLoading: false, error: null));
  }
}

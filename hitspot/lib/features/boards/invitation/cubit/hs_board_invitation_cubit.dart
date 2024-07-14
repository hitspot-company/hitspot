import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'hs_board_invitation_state.dart';

class HsBoardInvitationCubit extends Cubit<HSBoardInvitationState> {
  final String boardId;
  final String token;

  HsBoardInvitationCubit({
    required this.boardId,
    required this.token,
  }) : super(HSBoardInvitationState());

  Future<void> acceptInvitation() async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      // Verify the invitation

      // Check if the invitation has expired

      // Add the user to the board

      // Mark the invitation as used

      emit(state.copyWith(isLoading: false, isAccepted: true));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }
}

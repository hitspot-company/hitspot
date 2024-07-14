import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/features/boards/invitation/cubit/hs_board_invitation_cubit.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BoardInvitationPage extends StatelessWidget {
  final String boardId;
  final String token;

  const BoardInvitationPage(
      {Key? key, required this.boardId, required this.token})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HsBoardInvitationCubit(
        boardId: boardId,
        token: token,
      ),
      child: Scaffold(
        appBar: AppBar(title: Text('Board Invitation')),
        body: BlocConsumer<HsBoardInvitationCubit, HSBoardInvitationState>(
          listener: (context, state) {
            if (state.isAccepted) {
              app.navigation.push('/board/$boardId');
            }
          },
          builder: (context, state) {
            if (state.isLoading) {
              return Center(child: CircularProgressIndicator());
            }
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('You have been invited to join a board!'),
                  SizedBox(height: 20),
                  if (state.error != null)
                    Text(state.error!, style: TextStyle(color: Colors.red)),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => context
                        .read<HsBoardInvitationCubit>()
                        .acceptInvitation(),
                    child: Text('Accept Invitation'),
                  ),
                  SizedBox(height: 10),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('Decline'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

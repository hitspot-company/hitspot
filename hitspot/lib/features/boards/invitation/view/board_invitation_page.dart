import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/features/app/hs_app.dart';
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
        appBar: AppBar(
          title: Text('Board Invitation'),
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: Theme.of(context).primaryColor,
        ),
        body: BlocConsumer<HsBoardInvitationCubit, HSBoardInvitationState>(
          listener: (context, state) {
            if (state.isAccepted) {
              app.navigation.push('/board/$boardId');
            }
          },
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state.error != "") {
              return const InvalidInvitationPage(
                  message: 'Your invitation is invalid or has expired!');
            }
            return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (state.boardImage != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: state.boardImage!,
                    ),
                  SizedBox(height: 20),
                  Text(
                    state.board?.title ?? "",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 40),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: HSApp()
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: Colors.grey[600]),
                      children: [
                        TextSpan(
                          text: state.boardAuthor ?? "",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                            text: ' invited you to collaborate on this board!'),
                      ],
                    ),
                  ),
                  SizedBox(height: 40),
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width:
                              200, // Adjust this value to your preferred width
                          child: ElevatedButton(
                            onPressed: () => context
                                .read<HsBoardInvitationCubit>()
                                .acceptInvitation(),
                            child: Text('Accept Invitation'),
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        SizedBox(
                          width:
                              200, // Adjust this value to your preferred width
                          child: TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text('Decline'),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
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

class InvalidInvitationPage extends StatelessWidget {
  final String message;

  const InvalidInvitationPage({Key? key, required this.message})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 80, color: Colors.red),
            SizedBox(height: 20),
            Text(
              message,
              style: TextStyle(color: Colors.red, fontSize: 18),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => navi.pop(),
              child: Text('Go back'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

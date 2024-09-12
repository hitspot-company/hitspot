import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/features/app/hs_app.dart';
import 'package:hitspot/features/boards/invitation/cubit/hs_board_invitation_cubit.dart';

class BoardInvitationPage extends StatelessWidget {
  final String boardId;
  final String token;

  const BoardInvitationPage(
      {super.key, required this.boardId, required this.token});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HsBoardInvitationCubit(
        boardId: boardId,
        token: token,
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Board Invitation'),
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: Theme.of(context).primaryColor,
        ),
        body: BlocConsumer<HsBoardInvitationCubit, HSBoardInvitationState>(
          listener: (context, state) {
            if (state.isAccepted) {
              app.navigation.router.go('/board/$boardId');
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
                  const SizedBox(height: 20),
                  Text(
                    state.boardTitle ?? "",
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
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
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const TextSpan(
                            text: ' invited you to collaborate on this board!'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
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
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: const Text('Accept Invitation'),
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width:
                              200, // Adjust this value to your preferred width
                          child: TextButton(
                            onPressed: () {
                              context
                                  .read<HsBoardInvitationCubit>()
                                  .declineInvitation();
                              navi.pop();
                            },
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text('Decline'),
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

  const InvalidInvitationPage({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 80, color: Colors.red),
            const SizedBox(height: 20),
            Text(
              message,
              style: const TextStyle(color: Colors.red, fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => navi.pop(),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text('Go back'),
            ),
          ],
        ),
      ),
    );
  }
}

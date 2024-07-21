import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/features/spots/single/cubit/hs_single_spot_comments_cubit.dart';
import 'package:hs_database_repository/src/spots/hs_comment.dart';
import 'package:hitspot/widgets/hs_loading_indicator.dart';
import 'package:hitspot/widgets/hs_textfield.dart';

class SingleSpotCommentsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    HSSingleSpotCommentsCubit singleSpotCommentsCubit =
        BlocProvider.of<HSSingleSpotCommentsCubit>(context);

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: app.theme.currentTheme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            BlocBuilder<HSSingleSpotCommentsCubit,
                HSSingleSpotCommentsCubitState>(
              buildWhen: (previous, current) =>
                  previous.fetchedComments != current.fetchedComments,
              builder: (context, state) {
                return Expanded(
                  child: ListView.builder(
                    itemCount:
                        singleSpotCommentsCubit.state.fetchedComments.length,
                    itemBuilder: (context, index) {
                      return _Comment(
                        comment: singleSpotCommentsCubit
                            .state.fetchedComments[index],
                        index: index,
                        onLike: () {
                          // Implement like functionality
                        },
                        onReply: () {
                          // Implement reply functionality
                        },
                      );
                    },
                  ),
                );
              },
            ),
            _CommentInput(),
          ],
        ),
      ),
    );
  }
}

class _Comment extends StatelessWidget {
  final HSComment comment;
  final int index;
  final VoidCallback onLike;
  final VoidCallback onReply;

  const _Comment({
    Key? key,
    required this.comment,
    required this.index,
    required this.onLike,
    required this.onReply,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(comment.content),
      subtitle: Text(comment.author?.name ?? ""),
      contentPadding: EdgeInsets.only(left: 16, top: 8),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(FontAwesomeIcons.heart),
            onPressed: onLike,
          ),
          IconButton(
            icon: const Icon(FontAwesomeIcons.reply),
            onPressed: onReply,
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms, delay: (50 * index).ms)
        .slideY(
            begin: 0.2,
            end: 0,
            duration: 300.ms,
            delay: (50 * index).ms,
            curve: Curves.easeOut)
        .scale(
            begin: Offset(0.8, 0.8),
            end: Offset(1, 1),
            duration: 300.ms,
            delay: (50 * index).ms);
  }
}

class _CommentInput extends StatelessWidget {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    HSSingleSpotCommentsCubit singleSpotCommentsCubit =
        BlocProvider.of<HSSingleSpotCommentsCubit>(context);

    return BlocConsumer<HSSingleSpotCommentsCubit,
            HSSingleSpotCommentsCubitState>(
        listener: (context, state) {
          if (state.status == HSSingleSpotCommentsStatus.finishedCommenting) {
            _controller.clear();
          }
        },
        builder: (context, state) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: HSTextField(
                    controller: _controller,
                    onChanged: singleSpotCommentsCubit.commentChanged,
                    textInputAction: TextInputAction.done,
                    maxLines: 2,
                    hintText: "Write a comment...",
                    maxLength: 250,
                    readOnly:
                        state.status == HSSingleSpotCommentsStatus.commenting,
                  ),
                ),
                IconButton(
                    icon: state.status == HSSingleSpotCommentsStatus.commenting
                        ? const HSLoadingIndicator(
                            size: 16.0,
                          )
                        : const Icon(Icons.send),
                    onPressed:
                        state.status == HSSingleSpotCommentsStatus.commenting
                            ? null
                            : () => singleSpotCommentsCubit.addComment()),
              ],
            )));
  }
}

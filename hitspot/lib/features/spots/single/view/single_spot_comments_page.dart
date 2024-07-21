import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/features/spots/single/cubit/hs_single_spot_comments_cubit.dart';
import 'package:hitspot/widgets/hs_user_avatar.dart';
import 'package:hs_database_repository/src/spots/hs_comment.dart';
import 'package:hitspot/widgets/hs_loading_indicator.dart';
import 'package:hitspot/widgets/hs_textfield.dart';

class SingleSpotCommentsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    HSSingleSpotCommentsCubit singleSpotCommentsCubit =
        BlocProvider.of<HSSingleSpotCommentsCubit>(context);
    final ScrollController _scrollController = ScrollController();

    _scrollController.addListener(() {
      // Check if user has scrolled to the bottom
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        singleSpotCommentsCubit.fetchComments();

        // TODO: Add loading animation perhaps?
      }
    });

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
                    controller: _scrollController,
                    itemCount:
                        singleSpotCommentsCubit.state.fetchedComments.length,
                    itemBuilder: (context, index) {
                      return _Comment(
                        comment: singleSpotCommentsCubit
                            .state.fetchedComments[index].keys.first,
                        isLiked: singleSpotCommentsCubit
                            .state.fetchedComments[index].values.first,
                        index: index,
                        onLike: () =>
                            singleSpotCommentsCubit.likeOrDislikeComment(
                                singleSpotCommentsCubit
                                    .state.fetchedComments[index].keys.first,
                                index),
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
  final bool isLiked;
  final int index;
  final VoidCallback onLike;
  final VoidCallback onReply;

  const _Comment({
    Key? key,
    required this.comment,
    required this.isLiked,
    required this.index,
    required this.onLike,
    required this.onReply,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: HSUserAvatar(
        radius: 20,
        imageUrl: comment.author?.avatarUrl,
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(comment.content),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                comment.author?.name ?? "",
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
              const SizedBox(width: 8),
              Text(
                _formatDate(comment.createdAt),
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
      contentPadding: EdgeInsets.only(left: 16, top: 8, bottom: 8),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildIconWithCount(
              isLiked ? FontAwesomeIcons.solidHeart : FontAwesomeIcons.heart,
              comment.likesCount,
              onLike,
              isLiked),
          const SizedBox(width: 2),
          _buildIconWithCount(FontAwesomeIcons.reply, comment.repliesCount,
              onReply, /* isLiked */ false),
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

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.day}/${date.month}/${date.year}';
  }
}

Widget _buildIconWithCount(
    IconData icon, int count, VoidCallback onPressed, bool isLiked) {
  return SizedBox(
    width: 40,
    child: Stack(
      alignment: Alignment.topCenter,
      children: [
        IconButton(
          icon: Icon(icon, size: 20, color: isLiked ? Colors.red : null),
          onPressed: onPressed,
          padding: EdgeInsets.zero,
          constraints: BoxConstraints(minWidth: 40, minHeight: 40),
        ),
        Positioned(
          bottom: -3,
          child: Text(
            '$count',
            style: TextStyle(fontSize: 10),
          ),
        ),
      ],
    ),
  );
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

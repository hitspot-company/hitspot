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

    // Check if user has scrolled to the bottom
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        singleSpotCommentsCubit.fetchComments();
      }
    });

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: app.theme.currentTheme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: BlocBuilder<HSSingleSpotCommentsCubit,
          HSSingleSpotCommentsCubitState>(
        buildWhen: (previous, current) =>
            previous.pageStatus != current.pageStatus ||
            previous.status != current.status ||
            previous.fetchedComments != current.fetchedComments ||
            previous.fetchedReplies != current.fetchedReplies,
        builder: (context, state) {
          return SafeArea(
            child: state.status == HSSingleSpotCommentsStatus.loading
                ? const Center(child: CircularProgressIndicator())
                : state.pageStatus == HSSingleSpotCommentsPageType.comments
                    ? _CommentsPage(
                        scrollController: _scrollController,
                      )
                    : _ReplyPage(
                        scrollController: _scrollController,
                      ),
          );
        },
      ),
    );
  }
}

class _Comment extends StatelessWidget {
  final HSComment comment;
  final VoidCallback onLike;
  final VoidCallback? onReply;
  final int index;

  const _Comment({
    Key? key,
    required this.comment,
    required this.onLike,
    this.onReply,
    required this.index,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: GestureDetector(
        onTap: () => navi.toUser(userID: comment.author?.uid ?? ""),
        child: HSUserAvatar(
          radius: 20,
          imageUrl: comment.author?.avatarUrl,
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(comment.content),
          const SizedBox(height: 4),
          Row(
            children: [
              GestureDetector(
                onTap: () => navi.toUser(userID: comment.author?.uid ?? ""),
                child: Text(
                  comment.author?.name ?? "",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 12),
                ),
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
              comment.isLiked
                  ? FontAwesomeIcons.solidHeart
                  : FontAwesomeIcons.heart,
              comment.likesCount,
              onLike,
              comment.isLiked),
          const SizedBox(width: 2),
          onReply != null
              ? _buildIconWithCount(FontAwesomeIcons.reply,
                  comment.repliesCount, onReply!, /* isLiked */ false)
              : const SizedBox.shrink(),
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
  _CommentInput({required this.hintText, super.key});
  final TextEditingController _controller = TextEditingController();
  final String hintText;

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
                    hintText: hintText,
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

class _CommentsPage extends StatelessWidget {
  _CommentsPage({required this.scrollController, super.key});
  final ScrollController scrollController;
  @override
  Widget build(BuildContext context) {
    HSSingleSpotCommentsCubit singleSpotCommentsCubit =
        BlocProvider.of<HSSingleSpotCommentsCubit>(context);
    HSSingleSpotCommentsCubitState state = singleSpotCommentsCubit.state;

    return Column(
      children: [
        Expanded(
          child: Column(
            children: [
              if (state.fetchedComments.isEmpty)
                const Expanded(
                  child: Center(
                    child: Text('No comments yet'),
                  ),
                ),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: state.fetchedComments.length,
                  itemBuilder: (context, index) {
                    return _Comment(
                      comment: state.fetchedComments[index],
                      index: index,
                      onLike: () =>
                          singleSpotCommentsCubit.likeOrDislikeComment(
                              comment: state.fetchedComments[index],
                              index: index,
                              isReply: false),
                      onReply: () => singleSpotCommentsCubit.goToReplyToComment(
                          state.fetchedComments[index], index),
                    );
                  },
                ),
              ),
              if (state.status ==
                  HSSingleSpotCommentsStatus.loadingMoreComments)
                const CircularProgressIndicator.adaptive(),
            ],
          ),
        ),
        _CommentInput(
          hintText: "Write a comment...",
        ),
      ],
    );
  }
}

class _ReplyPage extends StatelessWidget {
  _ReplyPage({required this.scrollController, Key? key}) : super(key: key);
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    HSSingleSpotCommentsCubit singleSpotCommentsCubit =
        BlocProvider.of<HSSingleSpotCommentsCubit>(context);
    HSSingleSpotCommentsCubitState state = singleSpotCommentsCubit.state;

    final HSComment originalComment =
        singleSpotCommentsCubit.state.fetchedComments[
            singleSpotCommentsCubit.state.indexOfCommentUnderReply];

    return Column(
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => singleSpotCommentsCubit.leaveReplyingToComment(),
            ),
            const Expanded(
              child: Text(
                'Replies',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(width: 48), // To balance the layout
          ],
        ),
        _Comment(
          comment: originalComment,
          index: state.indexOfCommentUnderReply,
          onLike: () => singleSpotCommentsCubit.likeOrDislikeComment(
              comment: originalComment,
              index: state.indexOfCommentUnderReply,
              isReply: false),
          onReply: null,
        ),
        if (state.status == HSSingleSpotCommentsStatus.loadingReplies)
          const Expanded(child: Center(child: CircularProgressIndicator())),
        if ((state.status == HSSingleSpotCommentsStatus.loaded ||
                state.status == HSSingleSpotCommentsStatus.commenting) &&
            state.fetchedReplies.isEmpty)
          const Expanded(
            child: Center(
              child: Text('No replies yet'),
            ),
          ),
        if (state.fetchedReplies.isNotEmpty)
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: state.fetchedReplies.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(
                            left: 24.0), // Add left padding for indent
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Add a vertical line to indicate reply
                            Container(
                              width: 2,
                              height: 80,
                              color: Colors.grey[300],
                              margin: EdgeInsets.only(right: 12),
                            ),
                            Expanded(
                              child: _Comment(
                                comment: state.fetchedReplies[index],
                                index: index,
                                onLike: () => singleSpotCommentsCubit
                                    .likeOrDislikeComment(
                                        comment: state.fetchedReplies[index],
                                        index: index,
                                        isReply: true),
                                onReply: null,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                if (state.status ==
                    HSSingleSpotCommentsStatus.loadingMoreComments)
                  const CircularProgressIndicator.adaptive(),
              ],
            ),
          ),
        _CommentInput(
          hintText: "Write a reply...",
        ),
      ],
    );
  }
}

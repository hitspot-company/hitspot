import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/features/spots/single/cubit/hs_single_spot_comments_cubit.dart';
import 'package:hitspot/widgets/hs_scaffold.dart';
import 'package:hitspot/widgets/hs_user_avatar.dart';
import 'package:hitspot/widgets/hs_loading_indicator.dart';
import 'package:hitspot/widgets/hs_textfield.dart';
import 'package:hitspot/widgets/shimmers/hs_shimmer_box.dart';
import 'package:hs_database_repository/hs_database_repository.dart';

class SingleSpotCommentsSection extends StatelessWidget {
  const SingleSpotCommentsSection({super.key});

  @override
  Widget build(BuildContext context) {
    HSSingleSpotCommentsCubit singleSpotCommentsCubit =
        BlocProvider.of<HSSingleSpotCommentsCubit>(context);
    final ScrollController scrollController = ScrollController();
    scrollController.addListener(() {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        singleSpotCommentsCubit.fetchComments();
      }
    });
    return GestureDetector(
      onTap: HSScaffold.hideInput,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: BoxDecoration(
          color: app.theme.currentTheme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child:
            BlocBuilder<HSSingleSpotCommentsCubit, HSSingleSpotCommentsState>(
          buildWhen: (previous, current) =>
              previous.pageStatus != current.pageStatus ||
              previous.status != current.status,
          builder: (context, state) {
            return SafeArea(
              child: state.status == HSSingleSpotCommentsStatus.loading
                  ? const _LoadingComments()
                  : state.pageStatus == HSSingleSpotCommentsPageStatus.comments
                      ? _CommentsPage(
                          scrollController: scrollController,
                        )
                      : _ReplyPage(
                          scrollController: scrollController,
                        ),
            );
          },
        ),
      ),
    );
  }
}

class _LoadingComments extends StatelessWidget {
  const _LoadingComments({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: 6,
        separatorBuilder: (BuildContext context, int index) {
          return const Gap(16.0);
        },
        itemBuilder: (BuildContext context, int index) {
          return HSShimmerBox(width: screenWidth, height: 60.0);
        },
      ),
    );
  }
}

class _Comment extends StatelessWidget {
  final HSComment comment;
  final VoidCallback onLike;
  final VoidCallback? onDelete;
  final VoidCallback? onReply;
  final int index;

  const _Comment({
    required this.comment,
    required this.onLike,
    this.onDelete,
    this.onReply,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    bool isReply = onReply == null && onDelete != null;

    return Slidable(
      key: ValueKey(comment.id),
      enabled: onDelete != null && comment.author?.uid == app.currentUser.uid,
      endActionPane: ActionPane(
        extentRatio: 0.25,
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (context) => onDelete!(),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: FontAwesomeIcons.trash,
            label: 'Delete',
            padding: const EdgeInsets.symmetric(vertical: 4),
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(left: isReply ? 38 : 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  child: ListTile(
                    leading: GestureDetector(
                      onTap: () =>
                          navi.toUser(userID: comment.author?.uid ?? ""),
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
                              onTap: () => navi.toUser(
                                  userID: comment.author?.uid ?? ""),
                              child: Text(
                                comment.author?.name ?? "",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ),
                            const SizedBox(width: 8),
                            AutoSizeText(
                              "• ${comment.createdAt.timeAgo}",
                              maxLines: 1,
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                    contentPadding:
                        const EdgeInsets.only(left: 16, top: 8, bottom: 8),
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
                        if (onReply != null)
                          _buildIconWithCount(FontAwesomeIcons.reply,
                              comment.repliesCount, onReply!, false),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isReply)
            Positioned(
              left: 34,
              top: 0,
              bottom: 0,
              child: Container(
                width: 2,
                color: Colors.grey[300],
              ),
            ),
        ],
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
              begin: const Offset(0.8, 0.8),
              end: const Offset(1, 1),
              duration: 300.ms,
              delay: (50 * index).ms),
    );
  }
}

Widget _buildIconWithCount(
    IconData icon, int? count, VoidCallback onPressed, bool isLiked) {
  return SizedBox(
    width: 40,
    child: Stack(
      alignment: Alignment.topCenter,
      children: [
        IconButton(
          icon: Icon(icon, size: 20, color: isLiked ? Colors.red : null),
          onPressed: onPressed,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
        ),
        count != null
            ? Positioned(
                bottom: -3,
                child: Text(
                  '$count',
                  style: const TextStyle(fontSize: 10),
                ),
              )
            : const SizedBox.shrink(),
      ],
    ),
  );
}

class _CommentsPage extends StatelessWidget {
  const _CommentsPage({required this.scrollController});

  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    HSSingleSpotCommentsCubit singleSpotCommentsCubit =
        BlocProvider.of<HSSingleSpotCommentsCubit>(context);

    return BlocBuilder<HSSingleSpotCommentsCubit, HSSingleSpotCommentsState>(
      buildWhen: (previous, current) =>
          previous.status != current.status ||
          previous.fetchedComments != current.fetchedComments,
      builder: (context, state) {
        return Column(
          children: [
            Expanded(
              child: Column(
                children: [
                  if (state.fetchedComments.isEmpty)
                    const Expanded(
                        child: _EmptyComments("Be the first to comment")),
                  if (state.fetchedComments.isNotEmpty)
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
                            onReply: () =>
                                singleSpotCommentsCubit.goToReplyToComment(
                                    state.fetchedComments[index], index),
                            onDelete: () =>
                                singleSpotCommentsCubit.removeComment(
                                    comment: state.fetchedComments[index],
                                    index: index,
                                    isReply: false),
                          );
                        },
                      ),
                    ),
                  if (state.status ==
                      HSSingleSpotCommentsStatus.loadingMoreComments)
                    const HSLoadingIndicator()
                ],
              ),
            ),
            const _CommentInput(),
          ],
        );
      },
    );
  }
}

class _EmptyComments extends StatelessWidget {
  const _EmptyComments(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            FontAwesomeIcons.comment,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

class _CommentInput extends StatelessWidget {
  const _CommentInput();

  @override
  Widget build(BuildContext context) {
    final cubit = BlocProvider.of<HSSingleSpotCommentsCubit>(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(
          16, 8, 16, MediaQuery.of(context).viewInsets.bottom + 8.0),
      child: HSTextField.filled(
        maxLength: 256,
        autofocus: true,
        controller: cubit.commentController,
        hintText: 'Write a comment...',
        onChanged: cubit.commentChanged,
        suffixIcon:
            BlocBuilder<HSSingleSpotCommentsCubit, HSSingleSpotCommentsState>(
          buildWhen: (previous, current) =>
              previous.commentingStatus != current.commentingStatus ||
              previous.comment != current.comment,
          builder: (context, state) {
            final isSending = state.commentingStatus ==
                HsSingleSpotCommentsCommentingStatus.commenting;
            final isNotEmpty = state.comment.isNotEmpty;
            if (isSending) {
              return const HSLoadingIndicator(size: 16.0);
            }
            return IconButton(
              icon: Icon(Icons.send,
                  color: isNotEmpty ? app.theme.mainColor : Colors.grey),
              onPressed: isNotEmpty && !isSending
                  ? () => BlocProvider.of<HSSingleSpotCommentsCubit>(context)
                      .addComment()
                  : null,
            );
          },
        ),
      ),
    );
  }
}

class _ReplyPage extends StatelessWidget {
  const _ReplyPage({required this.scrollController});
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    HSSingleSpotCommentsCubit singleSpotCommentsCubit =
        BlocProvider.of<HSSingleSpotCommentsCubit>(context);

    return BlocBuilder<HSSingleSpotCommentsCubit, HSSingleSpotCommentsState>(
      buildWhen: (previous, current) =>
          previous.status != current.status ||
          previous.fetchedReplies != current.fetchedReplies ||
          previous.fetchedComments != current.fetchedComments,
      builder: (context, state) {
        final HSComment originalComment =
            singleSpotCommentsCubit.state.fetchedComments[
                singleSpotCommentsCubit.state.indexOfCommentUnderReply];

        return Column(
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () =>
                      singleSpotCommentsCubit.leaveReplyingToComment(),
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
              onDelete: null,
              onReply: null,
            ),
            if (state.status == HSSingleSpotCommentsStatus.loadingReplies)
              const Expanded(child: _LoadingComments()),
            if ((state.status == HSSingleSpotCommentsStatus.loaded) &&
                state.fetchedReplies.isEmpty)
              const Expanded(child: _EmptyComments("No replies yet")),
            if (state.fetchedReplies.isNotEmpty)
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        itemCount: state.fetchedReplies.length,
                        itemBuilder: (context, index) {
                          return _Comment(
                            comment: state.fetchedReplies[index],
                            index: index,
                            onLike: () =>
                                singleSpotCommentsCubit.likeOrDislikeComment(
                                    comment: state.fetchedReplies[index],
                                    index: index,
                                    isReply: true),
                            onReply: null,
                            onDelete: () =>
                                singleSpotCommentsCubit.removeComment(
                                    comment: state.fetchedReplies[index],
                                    index: index,
                                    isReply: true),
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
            const _CommentInput(
                // hintText: "Write a reply...",
                ),
          ],
        );
      },
    );
  }
}

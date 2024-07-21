import 'package:hs_authentication_repository/hs_authentication_repository.dart';

class HSComment {
  final String id;
  final String content;
  final DateTime createdAt;
  final int likesCount;
  final int repliesCount;
  final String createdBy;
  HSUser? author;

  HSComment({
    required this.id,
    required this.content,
    required this.createdAt,
    required this.likesCount,
    required this.repliesCount,
    required this.createdBy,
    this.author,
  });

  factory HSComment.deserialize(Map<String, dynamic> map) {
    return HSComment(
      id: map['id'],
      createdBy: map['created_by'],
      content: map['content'],
      createdAt: DateTime.parse(map['created_at']),
      likesCount: map['likes_count'],
      repliesCount: map['replies_count'],
    );
  }
}

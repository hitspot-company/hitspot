import 'package:hs_authentication_repository/hs_authentication_repository.dart';

class HSComment {
  final String id;
  final String createdBy;
  final String content;
  final DateTime createdAt;
  int likesCount;
  int repliesCount;
  HSUser? author;

  HSComment({
    required this.id,
    required this.createdBy,
    required this.content,
    required this.createdAt,
    required this.likesCount,
    required this.repliesCount,
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

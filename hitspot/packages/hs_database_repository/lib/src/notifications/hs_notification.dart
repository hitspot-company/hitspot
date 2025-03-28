import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hs_authentication_repository/hs_authentication_repository.dart';
import 'package:intl/intl.dart';

enum HSNotificationType {
  spotlike,
  spotcomment,
  spotcreation,
  userfollow,
  boardlike,
  boardinvitation,
  other;

  String get str {
    switch (this) {
      case HSNotificationType.spotlike:
        return 'spot_like';
      case HSNotificationType.spotcomment:
        return 'spot_comment';
      case HSNotificationType.spotcreation:
        return 'spot_creation';
      case HSNotificationType.userfollow:
        return 'user_follow';
      case HSNotificationType.boardlike:
        return 'board_like';
      case HSNotificationType.boardinvitation:
        return 'board_invitation';
      case HSNotificationType.other:
        return 'other';
    }
  }

  static HSNotificationType fromString(String str) {
    switch (str) {
      case 'spot_like':
        return HSNotificationType.spotlike;
      case 'spot_comment':
        return HSNotificationType.spotcomment;
      case 'spot_creation':
        return HSNotificationType.spotcreation;
      case 'user_follow':
        return HSNotificationType.userfollow;
      case 'board_like':
        return HSNotificationType.boardlike;
      case 'board_invitation':
        return HSNotificationType.boardinvitation;
      default:
        return HSNotificationType.other;
    }
  }
}

class HSNotification {
  final String? id, message;
  final UserID? from, to;
  final HSUser? fromUser, toUser;
  final HSNotificationType? type;
  final String? boardID, spotID;
  final bool? isHidden;
  final bool isRead;
  final DateTime? createdAt, updatedAt;
  final Map<String, dynamic>? metadata;

  HSNotification({
    this.id,
    this.fromUser,
    this.toUser,
    this.message,
    this.from,
    this.to,
    this.type,
    this.isRead = false,
    this.isHidden,
    this.createdAt,
    this.updatedAt,
    this.metadata,
    this.boardID,
    this.spotID,
  });

  HSNotification copyWith({
    String? id,
    String? message,
    UserID? from,
    UserID? to,
    HSNotificationType? type,
    bool? isRead,
    bool? isHidden,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
    String? boardID,
    String? spotID,
    HSUser? fromUser,
    HSUser? toUser,
  }) {
    return HSNotification(
      id: id ?? this.id,
      message: message ?? this.message,
      from: from ?? this.from,
      to: to ?? this.to,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      isHidden: isHidden ?? this.isHidden,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      metadata: metadata ?? this.metadata,
      boardID: boardID ?? this.boardID,
      spotID: spotID ?? this.spotID,
      fromUser: fromUser ?? this.fromUser,
      toUser: toUser ?? this.toUser,
    );
  }

  Map<String, dynamic> serialize() {
    return {
      'message': message,
      'user_from_id': from,
      'user_to_id': to,
      'board_id': boardID,
      'spot_id': spotID,
      'type': type!.str,
      'is_read': isRead,
      'is_hidden': isHidden,
      'metadata': metadata,
    };
  }

  factory HSNotification.deserialize(Map<String, dynamic> data) {
    return HSNotification(
      id: data['id'],
      message: data['message'],
      from: data['user_from_id'],
      to: data['user_to_id'],
      type: HSNotificationType.values.firstWhere(
        (element) => element.str == data['type'],
        orElse: () => HSNotificationType.other,
      ),
      isRead: data['is_read'],
      isHidden: data['is_hidden'],
      createdAt: DateTime.parse(data['created_at']),
      updatedAt: DateTime.parse(data['updated_at']),
      metadata: data['metadata'],
      boardID: data['board_id'],
      spotID: data['spot_id'],
      toUser: HSUser.deserialize(data, prefix: 'user_to_'),
      fromUser: HSUser.deserialize(data, prefix: 'user_from_'),
    );
  }

  String get title {
    switch (type) {
      case HSNotificationType.spotlike:
        return 'Spot liked';
      case HSNotificationType.spotcomment:
        return 'Spot commented';
      case HSNotificationType.spotcreation:
        return 'Spot created';
      case HSNotificationType.userfollow:
        return 'New follow';
      case HSNotificationType.boardlike:
        return 'Board liked';
      case HSNotificationType.boardinvitation:
        return 'Board invitation';
      case HSNotificationType.other || null:
        return "Notification";
    }
  }

  String get body {
    final fromUsername = fromUser?.username ?? 'Someone';
    switch (type) {
      case HSNotificationType.spotlike:
        return '$fromUsername liked your spot';
      case HSNotificationType.spotcomment:
        return '$fromUsername commented on your spot';
      case HSNotificationType.spotcreation:
        return '$fromUsername created new spot';
      case HSNotificationType.userfollow:
        return '$fromUsername started following you';
      case HSNotificationType.boardlike:
        return '$fromUsername liked your board';
      case HSNotificationType.boardinvitation:
        return '$fromUsername invited you to a board';
      case HSNotificationType.other || null:
        return message ?? '';
    }
  }

  get icon {
    switch (type) {
      case HSNotificationType.spotlike || HSNotificationType.boardlike:
        return FontAwesomeIcons.solidHeart;
      case HSNotificationType.spotcomment:
        return FontAwesomeIcons.solidComment;
      case HSNotificationType.spotcreation:
        return FontAwesomeIcons.earthAfrica;
      case HSNotificationType.userfollow:
        return FontAwesomeIcons.userPlus;
      case HSNotificationType.boardinvitation:
        return FontAwesomeIcons.envelope;
      case HSNotificationType.other || null:
        return FontAwesomeIcons.bell;
    }
  }
}

extension TimeAgo on DateTime {
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.inDays > 365) {
      return DateFormat.yMMMd().format(this);
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months month${months == 1 ? '' : 's'} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }
}

import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';

enum HSBoardVisibility {
  private,
  invite,
  public;

  factory HSBoardVisibility.fromCode(int code) {
    switch (code) {
      case 1:
        return HSBoardVisibility.invite;
      case 2:
        return HSBoardVisibility.public;
      default:
        return HSBoardVisibility.private;
    }
  }

  int get code {
    switch (this) {
      case HSBoardVisibility.private:
        return 0;
      case HSBoardVisibility.invite:
        return 1;
      case HSBoardVisibility.public:
        return 2;
    }
  }

  String get name {
    switch (this) {
      case HSBoardVisibility.private:
        return "private";
      case HSBoardVisibility.invite:
        return "invite";
      case HSBoardVisibility.public:
        return "public";
    }
  }

  String get description {
    switch (this) {
      case HSBoardVisibility.private:
        return "Only you can see the board.";
      case HSBoardVisibility.invite:
        return "You and the people you give access can see the board.";
      case HSBoardVisibility.public:
        return "Everyone can see the board.";
    }
  }
}

class HSBoard {
  final String? bid;
  final String? authorID;
  final List? editors;
  final List? participants;

  /// [color] The background color of the board
  final Color? color;

  /// [image] The image of the board
  /// (the value can be null)
  final String? image;

  final List? spots;
  final String? description;
  final String? title;
  final Timestamp? tripDate;
  final double? tripBudget;
  final HSBoardVisibility? boardVisibility;
  final Timestamp? createdAt;

  Map<String, dynamic> serialize() {
    return {
      "author_id": authorID,
      "editors": editors,
      "participants": participants,
      "color": color?.toHex,
      "image": image,
      "spots": spots,
      "description": description,
      "title": title,
      "trip_date": tripDate,
      "trip_budget": tripBudget,
      "board_visibility": boardVisibility?.code,
      "created_at": createdAt,
    };
  }

  factory HSBoard.deserialize(Map<String, dynamic> data, [String? authorID]) {
    return HSBoard(
      authorID: authorID,
      bid: data["author_id"],
      editors: data["editors"],
      participants: data["participants"],
      color: data["color"].toString().toColor,
      image: data["image"],
      spots: data["spots"],
      description: data["description"],
      title: data["title"],
      tripDate: data["trip_date"],
      tripBudget: data["trip_budget"],
      boardVisibility: HSBoardVisibility.fromCode(data["board_visibility"]),
      createdAt: data["created_at"],
    );
  }

  const HSBoard({
    this.bid,
    this.authorID,
    this.editors,
    this.participants,
    this.color,
    this.image,
    this.spots,
    this.description,
    this.title,
    this.tripDate,
    this.tripBudget,
    this.boardVisibility,
    this.createdAt,
  });

  @override
  String toString() => """
HSBoard data:
bid: $bid
authorID: $authorID
editors: $editors
participants: $participants
color: $color
image: $image
spots: $spots
description: $description
title: $title
tripDate: $tripDate
tripBudget: $tripBudget
boardVisibility: $boardVisibility
createdAt: $createdAt
""";
}

extension HSBoardColorExtensions on Color {
  String get toHex => "#${value.toRadixString(16)}";
}

extension HSBoardStringExtensions on String {
  Color get toColor {
    final buffer = StringBuffer();
    if (this.length == 6 || this.length == 7) buffer.write('ff');
    buffer.write(this.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}

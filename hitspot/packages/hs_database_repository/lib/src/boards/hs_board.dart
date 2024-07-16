import 'dart:ui';
import 'package:hs_authentication_repository/hs_authentication_repository.dart';

typedef BoardID = String;

class HSBoard {
  final UserID? createdBy;
  List<HSUser>? collaborators;
  final BoardID? id;
  final String? title, description, image;
  final Color? color;
  final HSBoardVisibility? visibility;
  final DateTime? createdAt;

  factory HSBoard.deserialize(Map<String, dynamic> data) {
    return HSBoard(
      createdBy: data["created_by"],
      id: data["id"],
      title: data["title"],
      description: data["description"],
      color: data["color"]?.toString().toColor,
      image: data["image"],
      visibility: HSBoardVisibility.deserialize(data["visibility"]),
      createdAt: data["created_at"] != null
          ? DateTime.tryParse(data["created_at"])
          : null,
    );
  }

  Map<String, dynamic> serialize() {
    return {
      "created_by": createdBy,
      "title": title,
      "description": description,
      "color": color?.toHex,
      "image": image,
      "visibility": visibility!.name,
      "created_at": createdAt?.toIso8601String(),
    };
  }

  HSBoard copyWith({
    UserID? createdBy,
    List<HSUser>? collaborators,
    BoardID? id,
    String? title,
    String? description,
    Color? color,
    String? image,
    dynamic visibility,
    DateTime? createdAt,
  }) =>
      HSBoard(
        createdBy: createdBy ?? this.createdBy,
        collaborators: collaborators ?? this.collaborators,
        id: id ?? this.id,
        title: title ?? this.title,
        description: description ?? this.description,
        color: color ?? this.color,
        image: image ?? this.image,
        visibility: visibility ?? this.visibility,
        createdAt: createdAt ?? this.createdAt,
      );

  HSBoard({
    this.createdBy,
    this.collaborators,
    this.id,
    this.title,
    this.description,
    this.color,
    this.image,
    this.visibility,
    this.createdAt,
  });

  @override
  String toString() {
    return "HSBoard(createdBy: $createdBy, id: $id, title: $title, description: $description, color: $color, image: $image, visibility: $visibility, createdAt: $createdAt)";
  }
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

enum HSBoardVisibility {
  private,
  invite,
  public;

  factory HSBoardVisibility.deserialize(String name) {
    switch (name) {
      case "on-invite":
        return HSBoardVisibility.invite;
      case "public":
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
        return "on-invite";
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

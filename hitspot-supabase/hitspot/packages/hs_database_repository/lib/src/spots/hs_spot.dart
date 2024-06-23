import 'package:hs_authentication_repository/hs_authentication_repository.dart';

class HSSpot {
  final String? sid, title, description, geohash, createdBy, address;
  final int? likesCount,
      commentsCount,
      savesCount,
      tripsCount,
      boardsCount,
      sharesCount;
  final double? latitude, longitude;
  final List<String>? images;
  final HSUser? author;

  const HSSpot({
    this.sid,
    this.address,
    this.author,
    this.title,
    this.description,
    this.geohash,
    this.createdBy,
    this.likesCount,
    this.commentsCount,
    this.savesCount,
    this.tripsCount,
    this.boardsCount,
    this.sharesCount,
    this.latitude,
    this.longitude,
    this.images,
  });

  HSSpot copyWith({
    String? sid,
    String? title,
    String? description,
    String? geohash,
    String? address,
    String? createdBy,
    int? likesCount,
    int? commentsCount,
    int? savesCount,
    int? tripsCount,
    int? boardsCount,
    int? sharesCount,
    double? latitude,
    double? longitude,
    List<String>? images,
    HSUser? author,
  }) {
    return HSSpot(
      sid: sid ?? this.sid,
      title: title ?? this.title,
      address: address ?? this.address,
      description: description ?? this.description,
      geohash: geohash ?? this.geohash,
      createdBy: createdBy ?? this.createdBy,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      savesCount: savesCount ?? this.savesCount,
      tripsCount: tripsCount ?? this.tripsCount,
      sharesCount: sharesCount ?? this.sharesCount,
      boardsCount: boardsCount ?? this.boardsCount,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      images: images ?? this.images,
      author: author ?? this.author,
    );
  }

  Map<String, dynamic> serialize() {
    return {
      'title': title,
      'description': description,
      'geohash': geohash,
      'created_by': createdBy,
      'likes_count': likesCount ?? 0,
      'comments_count': commentsCount ?? 0,
      'saves_count': savesCount ?? 0,
      'trips_count': tripsCount ?? 0,
      'boards_count': boardsCount ?? 0,
      'shares_count': sharesCount ?? 0,
      "location": "POINT($longitude $latitude)",
      'address': address,
    };
  }

  static HSSpot deserialize(Map<String, dynamic> data) {
    return HSSpot(
      sid: data['id'],
      title: data['title'],
      description: data['description'],
      geohash: data['geohash'],
      createdBy: data['created_by'],
      likesCount: data['likes_count'],
      commentsCount: data['comments_count'],
      savesCount: data['saves_count'],
      sharesCount: data['shares_count'],
      tripsCount: data['trips_count'],
      boardsCount: data['boards_count'],
      address: data['address'],
      latitude: data['lat'] ?? data['latitude'],
      longitude: data['long'] ?? data['longitude'],
    );
  }

  @override
  String toString() {
    return 'HSSpot{sid: $sid, title: $title, description: $description, geohash: $geohash, createdBy: $createdBy, likesCount: $likesCount, commentsCount: $commentsCount, savesCount: $savesCount, tripsCount: $tripsCount, boardsCount: $boardsCount, latitude: $latitude, longitude: $longitude}';
  }
}

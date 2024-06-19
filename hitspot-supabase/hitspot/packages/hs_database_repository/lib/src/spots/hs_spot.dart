class HSSpot {
  final String? sid, title, description, geohash, createdBy;
  final int? likesCount, commentsCount, savesCount, tripsCount, boardsCount;
  final double? latitude, longitude;

  HSSpot({
    this.sid,
    this.title,
    this.description,
    this.geohash,
    this.createdBy,
    this.likesCount,
    this.commentsCount,
    this.savesCount,
    this.tripsCount,
    this.boardsCount,
    this.latitude,
    this.longitude,
  });

  HSSpot copyWith({
    String? sid,
    String? title,
    String? description,
    String? geohash,
    String? createdBy,
    int? likesCount,
    int? commentsCount,
    int? savesCount,
    int? tripsCount,
    int? boardsCount,
    double? latitude,
    double? longitude,
  }) {
    return HSSpot(
      sid: sid ?? this.sid,
      title: title ?? this.title,
      description: description ?? this.description,
      geohash: geohash ?? this.geohash,
      createdBy: createdBy ?? this.createdBy,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      savesCount: savesCount ?? this.savesCount,
      tripsCount: tripsCount ?? this.tripsCount,
      boardsCount: boardsCount ?? this.boardsCount,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  Map<String, dynamic> serialize() {
    return {
      'title': title,
      'description': description,
      'geohash': geohash,
      'created_by': createdBy,
      'likes_count': likesCount,
      'comments_count': commentsCount,
      'saves_count': savesCount,
      'trips_count': tripsCount,
      'boards_count': boardsCount,
      "location": "POINT($latitude $longitude)",
    };
  }

  static HSSpot deserialize(Map<String, dynamic> data) {
    return HSSpot(
      sid: data['sid'],
      title: data['title'],
      description: data['description'],
      geohash: data['geohash'],
      createdBy: data['created_by'],
      likesCount: data['likes_count'],
      commentsCount: data['comments_count'],
      savesCount: data['saves_count'],
      tripsCount: data['trips_count'],
      boardsCount: data['boards_count'],
      // TODO: ADD POSITION
    );
  }

  @override
  String toString() {
    return 'HSSpot{sid: $sid, title: $title, description: $description, geohash: $geohash, createdBy: $createdBy, likesCount: $likesCount, commentsCount: $commentsCount, savesCount: $savesCount, tripsCount: $tripsCount, boardsCount: $boardsCount, latitude: $latitude, longitude: $longitude}';
  }
}

import 'package:hs_authentication_repository/hs_authentication_repository.dart';
import 'package:hs_database_repository/hs_database_repository.dart';

class HSSpotsUtils {
  static HSSpot deserializeSpotWithAuthor(Map<String, dynamic> data) {
    HSUser author = HSUser.deserialize({
      "id": data["user_id"],
      "biogram": data["user_biogram"],
      "email": data["user_email"],
      "name": data["user_name"],
      "avatar_url": data["user_avatar_url"],
      "username": data["user_username"],
      "followers": data["user_followers_count"],
      "following": data["user_following_count"],
      "boards": data["user_spots_count"],
      "spots": data["use_boards_count"],
    });

    List<String>? imagesUrls = (data['images'] as List<dynamic>?)
        ?.map((item) => item.toString())
        .toList();

    List<String>? thumbnailsUrls = (data['thumbnails'] as List<dynamic>?)
        ?.map((item) => item.toString())
        .toList();

    List<String>? tagsUrls = (data['tags'] as List<dynamic>?)
        ?.map((item) => item.toString())
        .toList();

    return HSSpot(
      sid: data['id'],
      author: author,
      createdBy: data['created_by'],
      title: data['title'],
      description: data['description'],
      geohash: data['geohash'],
      likesCount: data['likes_count'],
      commentsCount: data['comments_count'],
      savesCount: data['saves_count'],
      tripsCount: data['trips_count'],
      boardsCount: data['boards_count'],
      sharesCount: data['shares_count'],
      address: data['address'],
      latitude: data['lat'] ?? data['latitude'],
      longitude: data['long'] ?? data['longitude'],
      images: imagesUrls,
      thumbnails: thumbnailsUrls,
      tags: tagsUrls,
    );
  }
}

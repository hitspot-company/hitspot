import 'package:cloud_firestore/cloud_firestore.dart';

enum HSUserField {
  username("username"),
  boards("boards"),
  trips("trips"),
  profilePicture("profile_picture"),
  likedSpots("liked_spots"),
  followers("followers"),
  following("following"),
  spots("spots"),
  fcmTokens("fcm_tokens"),
  previouslySearchedUsers("previously_searched_users"),
  email("email"),
  saves("saves"),
  fullName("full_name"),
  biogram("biogram"),
  emailHidden("email_hidden"),
  createdAt("created_at"),
  bday("birthdate"),
  algoliaObjectID("objectID"),
  isEmailVerified("is_email_verified"),
  isProfileCompleted("is_profile_completed");

  final String name;
  const HSUserField(this.name);
}

class HSUser {
  final List? fcmTokens,
      followers,
      following,
      likedSpots,
      previouslySearchedUsers,
      boards,
      trips,
      saves,
      spots;
  final String? uid, biogram, email, fullName, profilePicture, username;
  final Timestamp? birthday, createdAt;
  final bool? emailHidden;
  final bool? isProfileCompleted, isEmailVerified;

  Map<String, dynamic> serialize() {
    return {
      HSUserField.fcmTokens.name: fcmTokens,
      HSUserField.followers.name: followers,
      HSUserField.trips.name: trips,
      HSUserField.following.name: following,
      HSUserField.likedSpots.name: likedSpots,
      HSUserField.previouslySearchedUsers.name: previouslySearchedUsers,
      HSUserField.spots.name: spots,
      HSUserField.saves.name: saves,
      HSUserField.biogram.name: biogram,
      HSUserField.email.name: email,
      HSUserField.fullName.name: fullName,
      HSUserField.profilePicture.name: profilePicture,
      HSUserField.username.name: username,
      HSUserField.bday.name: birthday,
      HSUserField.createdAt.name: createdAt,
      HSUserField.emailHidden.name: emailHidden,
      HSUserField.isProfileCompleted.name: isProfileCompleted ?? false,
      HSUserField.isEmailVerified.name: isEmailVerified ?? false,
      HSUserField.boards.name: boards,
    };
  }

  factory HSUser.deserialize(Map<String, dynamic> data, {String? uid}) {
    return HSUser(
      uid: uid,
      fcmTokens: data[HSUserField.fcmTokens.name],
      followers: data[HSUserField.followers.name],
      following: data[HSUserField.following.name],
      likedSpots: data[HSUserField.likedSpots.name],
      previouslySearchedUsers: data[HSUserField.previouslySearchedUsers.name],
      spots: data[HSUserField.spots.name],
      trips: data[HSUserField.trips.name],
      saves: data[HSUserField.saves.name],
      boards: data[HSUserField.boards.name],
      biogram: data[HSUserField.biogram.name],
      email: data[HSUserField.email.name],
      fullName: data[HSUserField.fullName.name],
      profilePicture: data[HSUserField.profilePicture.name],
      username: data[HSUserField.username.name],
      birthday: data[HSUserField.bday.name],
      createdAt: data[HSUserField.createdAt.name],
      emailHidden: data[HSUserField.emailHidden.name],
      isProfileCompleted: data[HSUserField.isProfileCompleted.name] ?? false,
      isEmailVerified: data[HSUserField.isEmailVerified.name] ?? false,
    );
  }

  HSUser copyWith({
    List? fcmTokens,
    List? followers,
    List? following,
    List? likedSpots,
    List? previouslySearchedUsers,
    List? spots,
    List? trips,
    List? saves,
    List? boards,
    String? uid,
    String? biogram,
    String? email,
    String? fullName,
    String? profilePicture,
    String? username,
    Timestamp? birthday,
    Timestamp? createdAt,
    bool? emailHidden,
    bool? isProfileCompleted,
    bool? isEmailVerified,
  }) {
    return HSUser(
      fcmTokens: fcmTokens ?? this.fcmTokens,
      followers: followers ?? this.followers,
      following: following ?? this.following,
      likedSpots: likedSpots ?? this.likedSpots,
      previouslySearchedUsers:
          previouslySearchedUsers ?? this.previouslySearchedUsers,
      spots: spots ?? this.spots,
      trips: trips ?? this.trips,
      saves: saves ?? this.saves,
      boards: boards ?? this.boards,
      uid: uid ?? this.uid,
      biogram: biogram ?? this.biogram,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      profilePicture: profilePicture ?? this.profilePicture,
      username: username ?? this.username,
      birthday: birthday ?? this.birthday,
      createdAt: createdAt ?? this.createdAt,
      emailHidden: emailHidden ?? this.emailHidden,
      isProfileCompleted: isProfileCompleted ?? this.isProfileCompleted,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
    );
  }

  const HSUser({
    this.uid,
    this.fcmTokens,
    this.followers,
    this.following,
    this.likedSpots,
    this.previouslySearchedUsers,
    this.spots,
    this.trips,
    this.saves,
    this.boards,
    this.biogram,
    this.email,
    this.fullName,
    this.profilePicture,
    this.username,
    this.birthday,
    this.createdAt,
    this.emailHidden,
    this.isProfileCompleted,
    this.isEmailVerified,
  });

  @override
  String toString() {
    return """
User $uid data:
uid: $uid
fcmTokens: $fcmTokens
followers: $followers
following: $following
likedSpots: $likedSpots
previouslySearchedUsers: $previouslySearchedUsers
spots: $spots
trips: $trips
saves: $saves
boards: $boards
biogram: $biogram
email: $email
fullName: $fullName
profilePicture: $profilePicture
username: $username
birthday: $birthday
createdAt: $createdAt
emailHidden: $emailHidden
isProfileCompleted: $isProfileCompleted
isEmailVerified: $isEmailVerified
""";
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

enum HSUserField {
  username("username"),
  profilePicture("profile_picture"),
  likedSpots("liked_spots"),
  followers("followers"),
  following("following"),
  spots("spots"),
  fcmTokens("fcm_tokens"),
  previouslySearchedUsers("previously_searched_users"),
  email("email"),
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
      spots;
  final String? uid, biogram, email, fullName, profilePicture, username;
  final Timestamp? birthday, createdAt;
  final bool? emailHidden;
  final bool? isProfileCompleted, isEmailVerified;

  Map<String, dynamic> serialize() {
    return {
      HSUserField.fcmTokens.name: fcmTokens,
      HSUserField.followers.name: followers,
      HSUserField.following.name: following,
      HSUserField.likedSpots.name: likedSpots,
      HSUserField.previouslySearchedUsers.name: previouslySearchedUsers,
      HSUserField.spots.name: spots,
      HSUserField.biogram.name: biogram,
      HSUserField.email.name: email,
      HSUserField.fullName.name: fullName,
      HSUserField.profilePicture.name: profilePicture,
      HSUserField.username.name: username,
      HSUserField.bday.name: birthday,
      HSUserField.createdAt.name: createdAt,
      HSUserField.emailHidden.name: emailHidden,
      HSUserField.isProfileCompleted.name: isProfileCompleted ?? false,
      HSUserField.isEmailVerified.name: isEmailVerified ?? false
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
}

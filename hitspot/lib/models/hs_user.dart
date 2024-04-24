import 'package:cloud_firestore/cloud_firestore.dart';

enum HSUserField {
  username("username"),
  profilePicture("profile_picture"),
  likedSpots("liked_spots"),
  followers("followers"),
  following("following"),
  spots("spots"),
  fcmTokens("fcm_tokens"),
  authProvidersIDs("auth_providers_IDs"),
  previouslySearchedUsers("previously_searched_users"),
  email("email"),
  fullName("full_name"),
  biogram("biogram"),
  emailHidden("email_hidden"),
  createdAt("created_at"),
  bday("birthdate"),
  algoliaObjectID("objectID");

  final String name;
  const HSUserField(this.name);
}

class HSUser {
  final List? authProviderIDs,
      fcmTokens,
      followers,
      following,
      likedSpots,
      previouslySearchedUsers,
      spots;
  final String? biogram, email, fullName, profilePicture, username;
  final Timestamp? birthday, createdAt;
  final bool? emailHidden;

  Map<String, dynamic> serialize() {
    return {
      HSUserField.authProvidersIDs.name: authProviderIDs,
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
      HSUserField.emailHidden.name: emailHidden
    };
  }

  factory HSUser.deserialize(Map<String, dynamic> data) {
    return HSUser(
      authProviderIDs: data[HSUserField.authProvidersIDs.name],
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
    );
  }

  factory HSUser.fromFirebaseUser(User firebaseUser) {}

  const HSUser({
    this.authProviderIDs,
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
  });
}

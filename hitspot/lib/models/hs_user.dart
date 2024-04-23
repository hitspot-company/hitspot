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
  isComplete("is_complete"),
  tags("tags"),
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
      tags,
      spots;
  final String? docID, biogram, email, fullName, profilePicture, username;
  final Timestamp? birthday, createdAt;
  final bool? emailHidden, isComplete;

  Map<String, dynamic> serialize() {
    return {
      HSUserField.authProvidersIDs.name: authProviderIDs ?? [],
      HSUserField.fcmTokens.name: fcmTokens ?? [],
      HSUserField.followers.name: followers ?? [],
      HSUserField.following.name: following ?? [],
      HSUserField.likedSpots.name: likedSpots ?? [],
      HSUserField.previouslySearchedUsers.name: previouslySearchedUsers ?? [],
      HSUserField.spots.name: spots ?? [],
      HSUserField.biogram.name: biogram,
      HSUserField.email.name: email,
      HSUserField.fullName.name: fullName,
      HSUserField.profilePicture.name: profilePicture,
      HSUserField.username.name: username,
      HSUserField.bday.name: birthday,
      HSUserField.createdAt.name: createdAt ?? Timestamp.now(),
      HSUserField.emailHidden.name: emailHidden ?? true,
      HSUserField.isComplete.name: isComplete ?? false,
      HSUserField.tags.name: tags ?? false,
    };
  }

  factory HSUser.fromFirestore(DocumentSnapshot doc) {
    HSUser ret = HSUser.deserialize(doc.data() as Map<String, dynamic>, doc.id);
    return (ret);
  }

  factory HSUser.deserialize(Map<String, dynamic> data, [String? id]) {
    return HSUser(
      docID: id,
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
      isComplete: data[HSUserField.isComplete.name],
      tags: data[HSUserField.tags.name],
    );
  }

  const HSUser({
    this.authProviderIDs = const [],
    this.fcmTokens = const [],
    this.followers = const [],
    this.following = const [],
    this.likedSpots = const [],
    this.previouslySearchedUsers = const [],
    this.spots = const [],
    this.biogram,
    this.email,
    this.fullName,
    this.profilePicture,
    this.username,
    this.birthday,
    this.createdAt,
    this.emailHidden,
    this.isComplete,
    this.docID,
    this.tags,
  });

  HSUser copyWith({
    List? authProviderIDs,
    List? fcmTokens,
    List? followers,
    List? following,
    List? likedSpots,
    List? previouslySearchedUsers,
    List? spots,
    List? tags,
    String? docID,
    String? biogram,
    String? email,
    String? fullName,
    String? profilePicture,
    String? username,
    Timestamp? birthday,
    Timestamp? createdAt,
    bool? emailHidden,
    bool? isComplete,
  }) {
    return HSUser(
      authProviderIDs: authProviderIDs ?? this.authProviderIDs,
      fcmTokens: fcmTokens ?? this.fcmTokens,
      followers: followers ?? this.followers,
      following: following ?? this.following,
      likedSpots: likedSpots ?? this.likedSpots,
      previouslySearchedUsers:
          previouslySearchedUsers ?? this.previouslySearchedUsers,
      spots: spots ?? this.spots,
      docID: docID ?? this.docID,
      biogram: biogram ?? this.biogram,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      profilePicture: profilePicture ?? this.profilePicture,
      username: username ?? this.username,
      birthday: birthday ?? this.birthday,
      createdAt: createdAt ?? this.createdAt,
      emailHidden: emailHidden ?? this.emailHidden,
      isComplete: isComplete ?? this.isComplete,
      tags: tags ?? this.tags,
    );
  }

  @override
  String toString() {
    return """"
User ($docID) details:
authProviderIDs: $authProviderIDs,
fcmTokens: $fcmTokens,
followers: $followers,
following: $following,
likedSpots: $likedSpots,
previouslySearchedUsers: $previouslySearchedUsers,
spots: $spots,
docID: $docID,
biogram: $biogram,
email: $email,
fullName: $fullName,
profilePicture: $profilePicture,
username: $username,
birthday: $birthday,
createdAt: $createdAt,
emailHidden: $emailHidden,
isComplete: $isComplete,
tags: $tags,
""";
  }
}

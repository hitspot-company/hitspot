typedef UserID = String;

class HSUser {
  final String? uid, biogram, email, name, avatarUrl, username;
  final DateTime? birthday, createdAt;
  final bool? emailHidden;
  final bool? isProfileCompleted, isEmailVerified;

  // Counts
  final int? followers, following, boards, spots;

  Map<String, dynamic> serialize() {
    return {
      "id": uid,
      "biogram": biogram,
      "email": email,
      "name": name,
      "avatar_url": avatarUrl,
      "username": username,
      "birthday": birthday?.toIso8601String(),
      "created_at": createdAt?.toIso8601String(),
      "is_email_hidden": emailHidden,
      "is_profile_completed": isProfileCompleted ?? false,
      "is_email_verified": isEmailVerified ?? false,
      "followers_count": followers ?? 0,
      "following_count": following ?? 0,
      "boards_count": boards ?? 0,
      "spots_count": spots ?? 0,
    };
  }

  factory HSUser.deserialize(Map<String, dynamic> data,
      {String? uid, String prefix = ""}) {
    return HSUser(
      uid: data[prefix + "id"],
      biogram: data[prefix + "biogram"],
      email: data[prefix + "email"],
      name: data[prefix + "name"],
      avatarUrl: data[prefix + "avatar_url"],
      username: data[prefix + "username"],
      birthday: data[prefix + "birthday"] != null
          ? DateTime.tryParse(data[prefix + "birthday"])
          : null,
      createdAt: data[prefix + "created_at"] != null
          ? DateTime.tryParse(data[prefix + "created_at"])
          : null,
      emailHidden: data[prefix + "is_email_hidden"] ?? true,
      isProfileCompleted: data[prefix + "is_profile_completed"] ?? false,
      isEmailVerified:
          data[prefix + "is_email_verified"] ?? true, // We use magic links
      followers: data[prefix + "followers_count"] ?? 0,
      following: data[prefix + "following_count"] ?? 0,
      boards: data[prefix + "boards_count"] ?? 0,
      spots: data[prefix + "spots_count"] ?? 0,
    );
  }

  HSUser copyWith({
    String? uid,
    String? biogram,
    String? email,
    String? fullName,
    String? profilePicture,
    String? username,
    DateTime? birthday,
    DateTime? createdAt,
    bool? emailHidden,
    bool? isProfileCompleted,
    bool? isEmailVerified,
    int? followers,
    int? following,
    int? boards,
    int? spots,
  }) {
    return HSUser(
      uid: uid ?? this.uid,
      biogram: biogram ?? this.biogram,
      email: email ?? this.email,
      name: fullName ?? this.name,
      avatarUrl: profilePicture ?? this.avatarUrl,
      username: username ?? this.username,
      birthday: birthday ?? this.birthday,
      createdAt: createdAt ?? this.createdAt,
      emailHidden: emailHidden ?? this.emailHidden,
      isProfileCompleted: isProfileCompleted ?? this.isProfileCompleted,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      followers: followers ?? this.followers,
      following: following ?? this.followers,
      boards: boards ?? this.followers,
      spots: spots ?? this.followers,
    );
  }

  const HSUser({
    this.uid,
    this.biogram,
    this.email,
    this.name,
    this.avatarUrl,
    this.username,
    this.birthday,
    this.createdAt,
    this.emailHidden,
    this.isProfileCompleted,
    this.isEmailVerified,
    this.followers,
    this.following,
    this.boards,
    this.spots,
  });

  @override
  String toString() {
    return """
User $uid data:
uid: $uid
biogram: $biogram
email: $email
fullName: $name
profilePicture: $avatarUrl
username: $username
birthday: $birthday
createdAt: $createdAt
emailHidden: $emailHidden
isProfileCompleted: $isProfileCompleted
isEmailVerified: $isEmailVerified
followers: $followers
following: $following
boards: $boards
spots: $spots
""";
  }
}

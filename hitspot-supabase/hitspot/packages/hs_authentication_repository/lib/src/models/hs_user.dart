import 'package:hs_debug_logger/hs_debug_logger.dart';

typedef UserID = String;

class HSUser {
  final String? uid, biogram, email, name, avatarUrl, username;
  final DateTime? birthday, createdAt;
  final bool? emailHidden;
  final bool? isProfileCompleted, isEmailVerified;

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
    };
  }

  factory HSUser.deserialize(Map<String, dynamic> data, {String? uid}) {
    HSDebugLogger.logInfo("DATA: $data");
    return HSUser(
      uid: data["id"],
      biogram: data["biogram"],
      email: data["email"],
      name: data["name"],
      avatarUrl: data["avatar_url"],
      username: data["username"],
      birthday:
          data["birthday"] != null ? DateTime.tryParse(data["birthday"]) : null,
      createdAt: data["created_at"] != null
          ? DateTime.tryParse(data["created_at"])
          : null,
      emailHidden: data["is_email_hidden"] ?? true,
      isProfileCompleted: data["is_profile_completed"] ?? false,
      isEmailVerified: data["is_email_verified"] ?? true, // We use magic links
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
""";
  }
}

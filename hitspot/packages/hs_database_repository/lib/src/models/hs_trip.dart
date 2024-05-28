import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hs_authentication_repository/hs_authentication_repository.dart';

enum HSTripVisibility {
  private,
  invite,
  public;

  factory HSTripVisibility.fromCode(int code) {
    switch (code) {
      case 1:
        return HSTripVisibility.invite;
      case 2:
        return HSTripVisibility.public;
      default:
        return HSTripVisibility.private;
    }
  }

  int get code {
    switch (this) {
      case HSTripVisibility.private:
        return 0;
      case HSTripVisibility.invite:
        return 1;
      case HSTripVisibility.public:
        return 2;
    }
  }

  String get name {
    switch (this) {
      case HSTripVisibility.private:
        return "private";
      case HSTripVisibility.invite:
        return "invite";
      case HSTripVisibility.public:
        return "public";
    }
  }

  String get description {
    switch (this) {
      case HSTripVisibility.private:
        return "Only you can see the trip.";
      case HSTripVisibility.invite:
        return "You and the people you give access can see the trip.";
      case HSTripVisibility.public:
        return "Everyone can see the trip.";
    }
  }
}

class HSTrip {
  final String? tid, authorID, title, description;
  final List<HSUser>? participants, editors;
  final double? tripBudget;
  final Timestamp? date;
  final Timestamp? createdAt;
  final HSTripVisibility? tripVisibility;

  Map<String, dynamic> get serialize {
    return {
      "author_id": authorID,
      "title": title,
      "description": description,
      "participants": participants,
      "editors": editors,
      "trip_budget": tripBudget,
      "trip_date": date,
      "created_at": createdAt,
      "trip_visibility": tripVisibility,
    };
  }

  factory HSTrip.deserialize(Map<String, dynamic> data, [String? tid]) {
    return HSTrip(
      tid: tid,
      authorID: data["author_id"],
      title: data["title"],
      description: data["description"],
      participants: data["participants"],
      editors: data["editors"],
      tripBudget: data["trip_budget"],
      date: data["trip_date"],
      createdAt: data["created_at"],
      tripVisibility: data["trip_visibility"],
    );
  }

  HSTrip copyWith({
    String? tid,
    String? authorID,
    String? title,
    String? description,
    List<HSUser>? participants,
    List<HSUser>? editors,
    double? tripBudget,
    Timestamp? tripDate,
    Timestamp? createdAt,
    HSTripVisibility? tripVisibility,
  }) {
    return HSTrip(
      authorID: authorID,
      tid: tid,
      title: title,
      description: description,
      participants: participants,
      editors: editors,
      tripBudget: tripBudget,
      date: tripDate,
      createdAt: createdAt,
      tripVisibility: tripVisibility,
    );
  }

  const HSTrip({
    this.authorID,
    this.tid,
    this.title,
    this.description,
    this.participants,
    this.editors,
    this.tripBudget,
    this.date,
    this.createdAt,
    this.tripVisibility,
  });
}

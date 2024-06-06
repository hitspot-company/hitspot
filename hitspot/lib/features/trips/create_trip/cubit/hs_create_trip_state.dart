part of 'hs_create_trip_cubit.dart';

enum HSCreateTripStatus { idle, uploading, error }

final class HSCreateTripState extends Equatable {
  const HSCreateTripState(
      {this.tripTitle = "",
      this.currency,
      this.tripDescription = "",
      this.tripVisibility = HSTripVisibility.private,
      this.participants = const [],
      this.tripBudget = 0.0,
      this.createTripStatus = HSCreateTripStatus.idle,
      this.editors = const [],
      this.tripDate = ""});

  final String tripTitle;
  final String tripDescription;
  final List<HSUser> participants;
  final List<HSUser> editors;
  final String tripDate;
  final double tripBudget;
  final Currency? currency;
  final HSCreateTripStatus createTripStatus;
  final HSTripVisibility tripVisibility;

  @override
  List<Object?> get props => [
        tripTitle,
        tripDescription,
        participants,
        editors,
        tripDate,
        tripBudget,
        currency,
        createTripStatus,
        tripVisibility,
      ];

  factory HSCreateTripState.update(HSTrip prototype) {
    return HSCreateTripState(
      tripTitle: prototype.title!,
      tripDescription: prototype.description!,
      participants: prototype.participants!,
      editors: prototype.editors!,
      tripBudget: prototype.tripBudget ?? 0.0,
      tripDate: prototype.date.toString(),
      tripVisibility: prototype.tripVisibility!,
      currency: null, // prototype.currency,
    );
  }

  HSCreateTripState copyWith({
    String? tripTitle,
    String? tripDescription,
    List<HSUser>? participants,
    List<HSUser>? editors,
    String? tripDate,
    double? tripBudget,
    Currency? currency,
    HSCreateTripStatus? createTripStatus,
    HSTripVisibility? tripVisibility,
  }) {
    return HSCreateTripState(
      tripTitle: tripTitle ?? this.tripTitle,
      tripDescription: tripDescription ?? this.tripDescription,
      participants: participants ?? this.participants,
      editors: editors ?? this.editors,
      tripDate: tripDate ?? this.tripDate,
      tripBudget: tripBudget ?? this.tripBudget,
      currency: currency != null && currency != this.currency
          ? currency
          : this.currency,
      createTripStatus: createTripStatus ?? this.createTripStatus,
      tripVisibility: tripVisibility ?? this.tripVisibility,
    );
  }
}

part of 'hs_create_trip_cubit.dart';

final class HSCreateTripState extends Equatable {
  const HSCreateTripState(
      {this.tripTitle = "",
      this.currency,
      this.tripDescription = "",
      this.participants = const [],
      this.editors = const [],
      this.tripDate = ""});

  final String tripTitle;
  final String tripDescription;
  final List<HSUser> participants;
  final List<HSUser> editors;
  final String tripDate;
  final Currency? currency;

  @override
  List<Object?> get props => [
        tripTitle,
        tripDescription,
        participants,
        editors,
        tripDate,
        currency,
      ];

  factory HSCreateTripState.update(HSTrip prototype) {
    return HSCreateTripState(
      tripTitle: prototype.title!,
      tripDescription: prototype.description!,
      participants: prototype.participants!,
      editors: prototype.editors!,
      tripDate: prototype.date.toString(),
      currency: null, // prototype.currency,
    );
  }

  HSCreateTripState copyWith({
    String? tripTitle,
    String? tripDescription,
    List<HSUser>? participants,
    List<HSUser>? editors,
    String? tripDate,
    Currency? currency,
  }) {
    return HSCreateTripState(
      tripTitle: tripTitle ?? this.tripTitle,
      tripDescription: tripDescription ?? this.tripDescription,
      participants: participants ?? this.participants,
      editors: editors ?? this.editors,
      tripDate: tripDate ?? this.tripDate,
      currency: currency != null && currency != this.currency
          ? currency
          : this.currency,
    );
  }
}

part of 'hs_create_trip_cubit.dart';

final class HSCreateTripState extends Equatable {
  const HSCreateTripState(
      {this.tripTitle = "",
      this.tripDescription = "",
      this.participants = const [],
      this.editors = const [],
      this.tripDate = ""});

  final String tripTitle;
  final String tripDescription;
  final List<HSUser> participants;
  final List<HSUser> editors;
  final String tripDate;

  @override
  List<Object> get props => [
        tripTitle,
        tripDescription,
        participants,
        editors,
        tripDate,
      ];

  factory HSCreateTripState.update(HSTrip prototype) {
    return HSCreateTripState(
      tripTitle: prototype.title!,
      tripDescription: prototype.description!,
      participants: prototype.participants!,
      editors: prototype.editors!,
      tripDate: prototype.date.toString(),
    );
  }
}

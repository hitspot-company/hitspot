import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hs_authentication_repository/hs_authentication_repository.dart';
import 'package:hs_database_repository/hs_database_repository.dart';

class HSTripsRepository {
  const HSTripsRepository(this._trips, this._users);
  final CollectionReference _trips;
  final CollectionReference _users;

  Future<void> delete({required HSTrip trip}) async {
    try {
      // 1. Remove trip from trips collection
      await _trips.doc(trip.tid).delete();
      // 2. Remove trip from authors profile
      await _users.doc(trip.authorID).update({
        "trips": FieldValue.arrayRemove([trip.tid])
      });
      // 3. Remove trip from editors' profiles
      final List? editors = trip.editors;
      if (editors != null) {
        for (var i = 0; i < editors.length; i++) {
          final String uid = editors[i];
          await _users.doc(uid).update({
            "trips": FieldValue.arrayRemove([trip.tid])
          });
        }
      }
    } catch (_) {
      throw DatabaseConnectionFailure("Could not delete trip: ${trip.tid}");
    }
  }

  bool hasAccess(HSUser user, HSTrip trip) {
    try {
      return trip.authorID == user.uid ||
          (trip.editors != null && trip.editors!.contains(user.uid));
    } catch (_) {
      throw const DatabaseConnectionFailure();
    }
  }

  Future<void> addToEditors(
      {required HSTrip trip, required HSUser user}) async {
    try {
      await _trips.doc(trip.tid).update({
        "editors": FieldValue.arrayUnion([user.uid])
      });
    } catch (_) {
      throw DatabaseConnectionFailure(
          "Could not add user: ${user.uid} to editors of trip: ${trip.tid}");
    }
  }

  Future<void> removeFromEditors(
      {required HSTrip trip, required HSUser user}) async {
    try {
      await _trips.doc(trip.tid).update({
        "editors": FieldValue.arrayRemove([user.uid])
      });
    } catch (_) {
      throw DatabaseConnectionFailure(
          "Could not remove user: ${user.uid} from editors of trip: ${trip.tid}");
    }
  }

  Future<List<HSTrip>> getUserTrips(HSUser user) async {
    try {
      final List tripsIDs = user.trips ?? [];
      final List<HSTrip> trips = [];
      for (var i = 0; i < tripsIDs.length; i++) {
        trips.add(await get(tripsIDs[i]));
      }
      return trips;
    } catch (_) {
      throw DatabaseConnectionFailure(
          "Could not get user's: ${user.uid} trips");
    }
  }

  Future<HSTrip> get(String tripID) async {
    try {
      DocumentSnapshot snap = await _trips.doc(tripID).get();
      if (!snap.exists)
        throw DatabaseConnectionFailure("The trip does not exist.");
      return HSTrip.deserialize(snap.data() as Map<String, dynamic>, snap.id);
    } on DatabaseConnectionFailure catch (_) {
      rethrow;
    } catch (_) {
      throw DatabaseConnectionFailure();
    }
  }

  Future<String> create(HSTrip trip) async {
    try {
      DocumentReference ref = await _trips.add(trip.serialized);
      await _assignTripToUser(trip.copyWith(tid: ref.id));
      return (ref.id);
    } catch (_) {
      throw DatabaseConnectionFailure("An error occured creating trip: $_");
    }
  }

  Future<void> update(HSTrip trip) async {
    try {
      await _trips.doc(trip.tid!).update(trip.serialized);
    } catch (_) {
      throw DatabaseConnectionFailure("An error occured creating trip: $_");
    }
  }

  Future<void> _assignTripToUser(HSTrip trip) async {
    try {
      await _users.doc(trip.authorID!).update({
        "trips": FieldValue.arrayUnion([trip.tid]),
      });
    } catch (_) {
      throw DatabaseConnectionFailure("Error assigning trip to user: $_");
    }
  }

  Future<void> _unassignTripFromUser(HSTrip trip) async {
    try {
      await _users.doc(trip.authorID!).update({
        "trips": FieldValue.arrayRemove([trip.tid]),
      });
    } catch (_) {
      throw DatabaseConnectionFailure("Error unassigning trip from user: $_");
    }
  }
}

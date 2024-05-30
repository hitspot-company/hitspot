import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:hs_authentication_repository/hs_authentication_repository.dart';
import 'package:hs_database_repository/hs_database_repository.dart';
import 'package:hs_database_repository/src/hs_database_repository_boards.dart';
import 'package:hs_database_repository/src/hs_database_repository_trips.dart';
import 'package:hs_database_repository/src/hs_database_repository_users.dart';

class HSDatabaseRepository {
  const HSDatabaseRepository();
  static final CollectionReference boards =
      FirebaseFirestore.instance.collection("boards");
  static final CollectionReference trips =
      FirebaseFirestore.instance.collection("trips");
  static final CollectionReference users =
      FirebaseFirestore.instance.collection("users");

  static final _usersRepository = HSUsersRepository();
  static final _boardsRepository = HSBoardsRepository(boards, users);
  static final _tripsRepository = HSTripsRepository(trips, users);

  Future<void> userFollow(HSUser currentUser, HSUser user) async =>
      await _usersRepository.followUser(currentUser, user);

  Future<void> userUnfollow(HSUser currentUser, HSUser user) async =>
      await _usersRepository.unfollowUser(currentUser, user);

  Future<void> userUpdateField(
          HSUser user, String field, String newValue) async =>
      _usersRepository.updateField(user, field, newValue);

  Future<void> userProfileComplete(HSUser user) async =>
      await _usersRepository.completeUserProfile(user);

  Future<void> userUpdate(HSUser user) async =>
      await _usersRepository.updateUserInfoInDatabase(user);

  Future<HSUser?> userGet(String uid) async {
    try {
      final HSUser? user = await _usersRepository.getUserFromDatabase(uid);
      return (user);
    } catch (e) {
      throw DatabaseConnectionFailure("The user could not be fetched");
    }
  }

  Future<bool> userIsUsernameAvailable(String username) async =>
      await _usersRepository.isUsernameAvailable(username);

  Future<HSBoard> boardGet(String boardID) async =>
      await _boardsRepository.getBoard(boardID);

  Future<String> boardCreate(HSBoard board) async =>
      await _boardsRepository.createBoard(board);

  Future<void> boardUpdate(HSBoard board) async =>
      await _boardsRepository.updateBoard(board);

  Future<void> boardSave(
          {required HSBoard board, required HSUser user}) async =>
      await _boardsRepository.saveBoard(board, user);

  Future<void> boardUnsave(
          {required HSBoard board, required HSUser user}) async =>
      await _boardsRepository.unsaveBoard(board, user);

  Future<List<HSBoard>> boardGetUserBoards({required HSUser user}) async =>
      await _boardsRepository.getUserBoards(user);

  Future<List<HSBoard>> boardGetSaved({required HSUser user}) async =>
      await _boardsRepository.getSavedBoards(user);

  Future<void> boardDelete({required HSBoard board}) async =>
      await _boardsRepository.deleteBoard(board: board);

  Future<void> boardDeleteImage({required HSBoard board}) async =>
      await _boardsRepository.deleteBoardImage(board);

  // TRIPS
  Future<void> tripDelete({required HSTrip trip}) async =>
      _tripsRepository.delete(trip: trip);

  Future<void> tripAddToEditors(
          {required HSTrip trip, required HSUser user}) async =>
      _tripsRepository.addToEditors(trip: trip, user: user);

  Future<void> tripRemoveFromEditors(
          {required HSTrip trip, required HSUser user}) async =>
      _tripsRepository.removeFromEditors(trip: trip, user: user);

  Future<List<HSTrip>> tripGetUserTrips(HSUser user) async =>
      _tripsRepository.getUserTrips(user);

  Future<HSTrip> tripGet(String tripID) async => _tripsRepository.get(tripID);

  Future<String> tripCreate(HSTrip trip) async => _tripsRepository.create(trip);

  Future<void> tripUpdate(HSTrip trip) async => _tripsRepository.update(trip);

  Future<String> uploadFile(File file, Reference reference) async {
    try {
      final UploadTask uploadTask = reference.putFile(file);
      final TaskSnapshot downloadUrl = await uploadTask;
      final String url = await downloadUrl.ref.getDownloadURL();
      return url;
    } catch (_) {
      rethrow;
    }
  }
}

import 'dart:io';
import 'dart:isolate';
import 'package:hitspot/main.dart';
import 'package:hs_database_repository/hs_database_repository.dart';
import 'package:hs_storage_repository/hs_storage_repository.dart';

// This class will hold all the data needed for spot creation
class HSSpotCreationData {
  final HSSpot spot;
  final List<String> imagePaths;
  final String uid;
  final List<String> tags;

  HSSpotCreationData({
    required this.spot,
    required this.imagePaths,
    required this.uid,
    required this.tags,
  });
}

// This function will run in the isolate
Future<String> _createSpotInIsolate(HSSpotCreationData data) async {
  final databaseRepo = HSDatabaseRepsitory(supabase);
  final storageRepo = HSStorageRepository(supabase);

  // Create the spot
  final String sid = await databaseRepo.spotCreate(spot: data.spot);

  // Upload images
  if (data.imagePaths.isNotEmpty) {
    final List<String> urls = await storageRepo.spotUploadImages(
      files: data.imagePaths.map((path) => File(path)).toList(),
      uid: data.uid,
      sid: sid,
    );
    await databaseRepo.spotUploadImages(
      spotID: sid,
      imageUrls: urls,
      uid: data.uid,
    );
  }

  // Upload tags
  if (data.tags.isNotEmpty) {
    for (var tag in data.tags) {
      await databaseRepo.tagSpotCreate(
        value: tag,
        spotID: sid,
        userID: data.uid,
      );
    }
  }

  return sid;
}

// This function will be called from your cubit to start the isolate
Future<String> createSpotWithIsolate(HSSpotCreationData data) async {
  final ReceivePort receivePort = ReceivePort();
  await Isolate.spawn(_createSpotInIsolate, data);

  final String sid = await receivePort.first as String;
  return sid;
}

import 'dart:io';
import 'dart:isolate';
import 'package:flutter/services.dart';
import 'package:hitspot/features/spots/create/form/cubit/hs_spot_upload_cubit.dart';
import 'package:hs_database_repository/hs_database_repository.dart';
import 'package:hs_debug_logger/hs_debug_logger.dart';
import 'package:hs_storage_repository/hs_storage_repository.dart';
import 'package:pair/pair.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HSSpotCreationData {
  final RootIsolateToken rootIsolateToken;
  final HSSpot spot;
  // final List<String> imagePaths;
  final String uid;
  // final List<String> tags;
  final SendPort sendPort;
  final Map<String, dynamic> supabaseData;
  final Session? currentSession;

  HSSpotCreationData({
    required this.rootIsolateToken,
    required this.spot,
    // required this.imagePaths,
    required this.uid,
    // required this.tags,
    required this.sendPort,
    required this.supabaseData,
    required this.currentSession,
  });
}

Future<void> _createSpotInIsolate(HSSpotCreationData data) async {
  BackgroundIsolateBinaryMessenger.ensureInitialized(data.rootIsolateToken);
  if (data.currentSession == null) {
    throw Exception('User is not authenticated');
  }
  final supabase =
      SupabaseClient(data.supabaseData['url'], data.supabaseData['anonKey']);
  await supabase.auth.setSession(data.currentSession!.refreshToken!);
  final databaseRepo = HSDatabaseRepsitory(supabase);
  final storageRepo = HSStorageRepository(supabase);

  void sendProgress(String message, double progress) {
    data.sendPort.send({'message': message, 'progress': progress});
  }

  try {
    // Create the spot
    sendProgress('Creating spot record...', 0.1);
    final String sid = await databaseRepo.spotCreate(spot: data.spot);

    // Upload images
    if (data.spot.images!.isNotEmpty) {
      sendProgress('Uploading images...', .4);
      final List<Pair<String, String>> urls =
          await storageRepo.spotUploadImages(
        files: data.spot.images!.map((e) => File(e)).toList(),
        uid: data.uid,
        sid: sid,
      );
      await databaseRepo.spotUploadImages(
        spotID: sid,
        imageUrls: urls,
        uid: data.uid,
      );
    }
    await Future.delayed(const Duration(milliseconds: 500));

    // Upload tags
    if (data.spot.tags!.isNotEmpty) {
      sendProgress('Uploading tags...', 0.9);
      for (var tag in data.spot.tags!) {
        await databaseRepo.tagSpotCreate(
          value: tag,
          spotID: sid,
          userID: data.uid,
        );
      }
    }

    sendProgress('Upload completed', 1.0);
    data.sendPort.send({'spotId': sid});
  } catch (e) {
    HSDebugLogger.logInfo("[!!!] Error creating spot: $e");
    data.sendPort.send({'error': e.toString()});
  }
  HSDebugLogger.logInfo('Spot creation process completed');
  await Future.delayed(const Duration(seconds: 1));
  data.sendPort.send({'exit': true});
  Isolate.exit();
}

Future<void> createSpotWithIsolate(
    HSSpotCreationData data, HSSpotUploadCubit cubit) async {
  final ReceivePort receivePort = ReceivePort();
  final isolateData = HSSpotCreationData(
    rootIsolateToken: data.rootIsolateToken,
    currentSession: data.currentSession,
    supabaseData: data.supabaseData,
    spot: data.spot,
    uid: data.uid,
    sendPort: receivePort.sendPort,
  );

  await Isolate.spawn(_createSpotInIsolate, isolateData);

  await for (var message in receivePort) {
    if (message is Map) {
      if (message.containsKey('message') && message.containsKey('progress')) {
        cubit.updateProgress(message['message'], message['progress']);
      } else if (message.containsKey('spotId')) {
        cubit.setSuccess(message['spotId']);
        break;
      } else if (message.containsKey('error')) {
        cubit.setFailure(message['error']);
        break;
      } else if (message.containsKey("exit")) {
        cubit.reset();
        break;
      }
    }
  }
  receivePort.close();
}

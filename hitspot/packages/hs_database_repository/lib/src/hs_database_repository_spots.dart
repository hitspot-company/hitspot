import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hs_database_repository/hs_database_repository.dart';
import 'package:hs_debug_logger/hs_debug_logger.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:hs_database_repository/src/models/hs_spot.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HSSpotsRepository {
  final db = FirebaseFirestore.instance;
  late final spotsCollection = db.collection("spots");

  final spotImagesStorage =
      FirebaseStorage.instanceFor(bucket: "gs://spots_images");

  static final GeoFlutterFire geoHashManager = GeoFlutterFire();

  final int _THUMBNAIL_SIZE = 100;

  Future<void> createSpot(String userID, LatLng location, String title,
      String description, List<XFile> images) async {
    // Get data and create HSSpot based on that data
    HSSpot newSpot = HSSpot(
        ownersId: userID,
        name: title,
        description: description,
        latitude: location.latitude,
        longitude: location.longitude,
        numberOfImagesUploaded: images.length);

    // Create geo hash based on latitude & longitude

    // Save HSSpot to database
    final _convertedImages =
        images.map<File>((xfile) => File(xfile.path)).toList();
    addSpotToDatabase(newSpot, _convertedImages);
  }

  Future<void> addSpotToDatabase(HSSpot spot, List<File> images) async {
    // Create thumbnails of spot images
    List<File> imageThumbnails = [];
    for (int i = 0; i < images.length; i++) {
      imageThumbnails.add(await createThumbnailFromImage(images[i]));
    }

    try {
      // Retrieve document's id
      DocumentReference docRef = await spotsCollection.add(spot.serialize());
      spot.uid = docRef.id;

      // Save images & their thumbnails to Firebase storage
      final storageRef = spotImagesStorage.ref();
      final spotStorageRef = storageRef.child(spot.uid);

      for (int i = 0; i < spot.numberOfImagesUploaded; i++) {
        final imageSpotStorageRef = spotStorageRef.child("${i.toString()}.jpg");
        final imageThumbnailSpotStorageRef =
            spotStorageRef.child("thumbnail_${i.toString()}.jpg");

        // Save images & thumbnails URLs to spot
        spot.fullImages.add(await imageSpotStorageRef.getDownloadURL());
        spot.imageThumbnails
            .add(await imageThumbnailSpotStorageRef.getDownloadURL());

        try {
          await imageSpotStorageRef.putFile(images[i]);
          await imageThumbnailSpotStorageRef.putFile(imageThumbnails[i]);
        } catch (e) {
          throw DatabaseRepositoryFailure(
              "There was an error in adding spot's images to database!");
        }
      }

      // Update current data with image URLs saved
      await spotsCollection.doc(spot.uid).update(spot.serializeImages());
    } catch (_) {
      throw DatabaseRepositoryFailure(
          "There was an error in saving spot to database!");
    }
  }

  Future<List<File>> getSpotThumbnails(HSSpot spot) async {
    List<File> downloadedThumbnails = [];

    try {
      final storageRef = spotImagesStorage.ref();
      final spotStorageRef = storageRef.child(spot.uid);

      for (int i = 0; i < spot.numberOfImagesUploaded; i++) {
        final imageThumbnailSpotStorageRef =
            spotStorageRef.child("thumbnail_${i.toString()}.jpg");
        try {
          final Uint8List? thumbnail = await imageThumbnailSpotStorageRef
              .getData(_THUMBNAIL_SIZE * _THUMBNAIL_SIZE);

          final tempDir = await getTemporaryDirectory();
          File thumbnailAsFile =
              await File('${tempDir.path}/image.png').create();

          if (thumbnail == null) {
            throw DatabaseRepositoryFailure(
                "Couldn't download thumbnail from database!");
          }

          thumbnailAsFile.writeAsBytes(thumbnail);
          downloadedThumbnails.add(thumbnailAsFile);
        } catch (e) {
          throw DatabaseRepositoryFailure(
              "There was an error in downloading spot's thumbnails from database - ${e.toString()}!");
        }
      }
    } catch (_) {
      throw DatabaseRepositoryFailure(
          "There was an error in downloading spot from database!");
    }

    return downloadedThumbnails;
  }

  GeoFirePoint getGeoHash(double latitude, double longitude) {
    try {
      return geoHashManager.point(latitude: latitude, longitude: longitude);
    } catch (e) {
      HSDebugLogger.logError(e.toString());
      throw DatabaseRepositoryFailure(e.toString());
    }
  }

  Future<File> createThumbnailFromImage(File input) async {
    try {
      List<int> inputImageInBytes = input.readAsBytesSync();
      img.Image? inputImage = img.decodeImage(inputImageInBytes);

      if (inputImage == null) {
        throw DatabaseRepositoryFailure("Couldn't parse image!");
      }

      img.Image thumbnail = img.copyResize(inputImage,
          width: _THUMBNAIL_SIZE, height: _THUMBNAIL_SIZE);

      final Directory temp = await getTemporaryDirectory();
      File thumbnailAsFile =
          File('${temp.path}/images_thumbnails/${basename(input.path)}.jpg');

      await thumbnailAsFile.writeAsBytes(img.encodeJpg(thumbnail));

      return thumbnailAsFile;
    } catch (e) {
      HSDebugLogger.logError(e.toString());
      throw DatabaseRepositoryFailure(e.toString());
    }
  }
}

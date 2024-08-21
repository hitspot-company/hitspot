import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:hs_storage_repository/src/files/exceptions/hs_file_exception.dart';
import 'package:pair/pair.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HSFilesRepository {
  const HSFilesRepository(this._supabase);
  final SupabaseClient _supabase;

  /// Returns full path to the uploaded file
  Future<String> upload(File file, String bucketName, String uploadPath,
      FileOptions? fileOptions) async {
    try {
      final String response = await _supabase.storage.from(bucketName).upload(
          uploadPath, file,
          fileOptions: fileOptions ?? FileOptions(upsert: true));
      return response;
    } catch (_) {
      throw HSFileException.upload(details: _.toString());
    }
  }

  Future<Uint8List> download(String bucketName, String uploadPath) async {
    try {
      final Uint8List file =
          await _supabase.storage.from(bucketName).download(uploadPath);
      return file;
    } catch (_) {
      throw HSFileException.download(details: _.toString());
    }
  }

  Future<String> update(File file, String bucketName, String uploadPath,
      FileOptions? fileOptions) async {
    try {
      final String response = await _supabase.storage.from(bucketName).upload(
          uploadPath, file,
          fileOptions: fileOptions ?? FileOptions(upsert: true));
      return response;
    } catch (_) {
      throw HSFileException.update(details: _.toString());
    }
  }

  Future<List<FileObject>> delete(
      String bucketName, List<String> uploadPaths) async {
    try {
      final List<FileObject> objects =
          await _supabase.storage.from(bucketName).remove(uploadPaths);
      return objects;
    } catch (_) {
      throw HSFileException.delete(details: _.toString());
    }
  }

  Future<String> fetchPublicUrl(String bucketName, String uploadPath) async {
    try {
      final String res =
          await _supabase.storage.from(bucketName).getPublicUrl(uploadPath);
      return res;
    } catch (_) {
      throw HSFileException.delete(details: _.toString());
    }
  }

  Future<String> uploadAndFetchPublicUrl(File file, String bucketName,
      String uploadPath, FileOptions? fileOptions) async {
    try {
      await upload(file, bucketName, uploadPath, fileOptions);
      final url = fetchPublicUrl(bucketName, uploadPath);
      return url;
    } catch (_) {
      throw HSFileException(message: _.toString());
    }
  }

  String userAvatarUploadPath(String uid) => "$uid/user_avatar";
  String boardImageUploadPath(String uid, String boardID) =>
      "$uid/boards/$boardID/image";

  String spotImagesUploadPath(String uid, String sid) => "$uid/spots/$sid";

  Future<List<Pair<String, String>>> spotUploadImages(
      List<File> images, String uid, String sid) async {
    try {
      final List<Pair<String, String>> ret = [];
      for (var i = 0; i < images.length; i++) {
        final File image = images[i];

        // Create thumbnail
        final File thumbnail = await FlutterNativeImage.compressImage(
            image.path,
            quality: 100,
            targetHeight: 128,
            targetWidth: 128);

        final String uploadPath = "${spotImagesUploadPath(uid, sid)}__$i";
        final String thumbnailUploadPath =
            "${spotImagesUploadPath(uid, sid)}__${i}_thumbnail";

        final String imageUrl =
            await uploadAndFetchPublicUrl(image, "spots", uploadPath, null);
        final String thumbnailUrl = await uploadAndFetchPublicUrl(
            thumbnail, "spots", thumbnailUploadPath, null);
        ;

        ret.add(Pair(imageUrl, thumbnailUrl));
      }
      return (ret);
    } catch (_) {
      throw ("Could not upload spot images: $_");
    }
  }
}

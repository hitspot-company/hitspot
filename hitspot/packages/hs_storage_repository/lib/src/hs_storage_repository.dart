import 'dart:io';
import 'dart:typed_data';

import 'package:hs_storage_repository/src/buckets/hs_buckets_repository.dart';
import 'package:hs_storage_repository/src/files/hs_files_repository.dart';
import 'package:pair/pair.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HSStorageRepository {
  HSStorageRepository(this._supabase) {
    this._bucketsRepository = HSBucketsRepository(_supabase);
    this._filesRepository = HSFilesRepository(_supabase);
  }
  final SupabaseClient _supabase;
  late final HSBucketsRepository _bucketsRepository;
  late final HSFilesRepository _filesRepository;
  final String avatarsBucket = "user_avatars";
  final String boardsBucket = "boards";
  String spotImagesUploadPath(String uid, String sid) =>
      _filesRepository.spotImagesUploadPath(uid, sid);

  // Buckets
  Future<String> bucketCreate(
          {required String bucketName, BucketOptions? bucketOptions}) async =>
      await _bucketsRepository.create(bucketName, bucketOptions);

  Future<Bucket> bucketRead({required String bucketName}) async =>
      await _bucketsRepository.read(bucketName);

  Future<String> bucketUpdate(
          {required String bucketName, BucketOptions? bucketOptions}) async =>
      await _bucketsRepository.update(bucketName, bucketOptions);

  Future<String> bucketDelete(
          {required String bucketName, bool force = false}) async =>
      await _bucketsRepository.delete(bucketName, force);

  // Files
  Future<String> fileUpload(
          {required File file,
          required String bucketName,
          required String uploadPath,
          required FileOptions? fileOptions}) async =>
      await _filesRepository.upload(file, bucketName, uploadPath, fileOptions);

  Future<Uint8List> fileDownload(
          {required String bucketName, required String uploadPath}) async =>
      await _filesRepository.download(bucketName, uploadPath);

  Future<String> fileUpdate(
          {required File file,
          required String bucketName,
          required String uploadPath,
          FileOptions? fileOptions}) async =>
      await _filesRepository.update(file, bucketName, uploadPath, fileOptions);

  Future<List<FileObject>> fileDelete(
          {required String bucketName,
          required List<String> uploadPaths}) async =>
      _filesRepository.delete(bucketName, uploadPaths);

  Future<String> fileFetchPublicUrl(
          {required String bucketName, required String uploadPath}) async =>
      await _filesRepository.fetchPublicUrl(bucketName, uploadPath);

  Future<String> fileUploadAndFetchPublicUrl(
          {required File file,
          required String bucketName,
          required String uploadPath,
          FileOptions? fileOptions}) async =>
      await _filesRepository.uploadAndFetchPublicUrl(
          file, bucketName, uploadPath, fileOptions);

  String userAvatarUploadPath({required String uid}) =>
      _filesRepository.userAvatarUploadPath(uid);

  String boardImageUploadPath({required String uid, required String boardID}) =>
      _filesRepository.boardImageUploadPath(uid, boardID);

  Future<List<Pair<String, String>>> spotUploadImages(
          {required List<File> files,
          required String uid,
          required String sid}) async =>
      await _filesRepository.spotUploadImages(files, uid, sid);

  Future<void> spotDeleteImages(
          {List<String>? images, List<String>? thumbnails}) async =>
      await _filesRepository.spotDeleteImages(images, thumbnails);

  // TODO: Add implementation
  // Future<void> reorderImages(String url1, String url2) async =>
  //     await _filesRepository.reorderImages(url1, url2);
}

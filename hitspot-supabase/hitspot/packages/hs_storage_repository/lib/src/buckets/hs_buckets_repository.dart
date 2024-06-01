import 'package:hs_storage_repository/src/buckets/exceptions/hs_bucket_exception.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HSBucketsRepository {
  const HSBucketsRepository(this._supabase);
  final SupabaseClient _supabase;

  Future<String> create(String bucketName, BucketOptions? bucketOptions) async {
    try {
      final String bucketID = await _supabase.storage.createBucket(
          bucketName, bucketOptions ?? const BucketOptions(public: true));
      return bucketID;
    } catch (_) {
      throw HSBucketException.create(details: _.toString());
    }
  }

  Future<Bucket> read(String bucketName) async {
    try {
      final Bucket bucket = await _supabase.storage.getBucket(bucketName);
      return bucket;
    } catch (_) {
      throw HSBucketException.read(details: _.toString());
    }
  }

  Future<String> update(String bucketName, BucketOptions? bucketOptions) async {
    try {
      final String response = await _supabase.storage.updateBucket(
          bucketName,
          bucketOptions ??
              const BucketOptions(
                  public:
                      true)); //  TODO: Verify later whether should be public by default
      return response;
    } catch (_) {
      throw HSBucketException.update(details: _.toString());
    }
  }

  Future<String> delete(String bucketName, bool force) async {
    try {
      if (force) await _supabase.storage.emptyBucket(bucketName);
      final String res = await _supabase.storage.deleteBucket(bucketName);
      return res;
    } catch (_) {
      throw HSBucketException.delete(details: _.toString());
    }
  }
}

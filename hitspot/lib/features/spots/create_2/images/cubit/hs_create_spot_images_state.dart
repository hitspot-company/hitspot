part of 'hs_create_spot_images_cubit.dart';

enum HsCreateSpotImagesStatus { choosingImages, ready, error }

final class HsCreateSpotImagesState extends Equatable {
  const HsCreateSpotImagesState(
      {this.images = const [],
      this.imageUrls = const [],
      this.status = HsCreateSpotImagesStatus.choosingImages});

  final List<XFile> images;
  final List<String> imageUrls;
  final HsCreateSpotImagesStatus status;

  @override
  List<Object> get props => [images, status, imageUrls];

  HsCreateSpotImagesState copyWith({
    List<XFile>? images,
    HsCreateSpotImagesStatus? status,
    List<String>? imageUrls,
  }) {
    return HsCreateSpotImagesState(
      images: images ?? this.images,
      imageUrls: imageUrls ?? this.imageUrls,
      status: status ?? this.status,
    );
  }
}

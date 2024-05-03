import "dart:io";
import "package:geoflutterfire2/geoflutterfire2.dart";
import "package:hs_authentication_repository/hs_authentication_repository.dart";

typedef ImageUrl = String;

enum HSSpotField {
  uid("uid"),
  ownersId("ownersId"),
  name("name"),
  description("description"),
  latitude("latitude"),
  longitude("longitude"),
  numberOfImagesUploaded("numberOfImagesUploaded"),
  fullImages("fullImages"),
  imageThumbnails("imageThumbnails"),
  geoHash("geoHash"),
  likes("likes"),
  saves("saves"),
  reposts("reposts");

  final String field;
  const HSSpotField(this.field);
}

class HSSpot {
  late UserID uid;
  String ownersId;
  String name;
  String description;
  double latitude;
  double longitude;
  late int numberOfImagesUploaded;
  List<ImageUrl> fullImages = [];
  List<ImageUrl> imageThumbnails = [];
  GeoFirePoint? geoHash;
  List<UserID> likes = [];
  List<UserID> saves = [];
  List<UserID> reposts = [];

  HSSpot(
      {this.uid = "",
      required this.ownersId,
      required this.name,
      required this.description,
      required this.latitude,
      required this.longitude,
      required this.numberOfImagesUploaded,
      this.fullImages = const [],
      this.imageThumbnails = const [],
      this.geoHash,
      this.likes = const [],
      this.saves = const [],
      this.reposts = const []});

  Map<String, dynamic> serialize() {
    return {
      HSSpotField.uid.field: uid,
      HSSpotField.ownersId.field: ownersId,
      HSSpotField.name.field: name,
      HSSpotField.latitude.field: latitude,
      HSSpotField.longitude.field: longitude,
      HSSpotField.numberOfImagesUploaded.field: numberOfImagesUploaded,
      HSSpotField.fullImages.field: description,
      HSSpotField.fullImages.field: fullImages,
      HSSpotField.imageThumbnails.field: imageThumbnails,
      HSSpotField.geoHash.field: geoHash,
      HSSpotField.likes.field: likes,
      HSSpotField.saves.field: saves,
      HSSpotField.reposts.field: reposts
    };
  }

  Map<String, dynamic> serializeImages() {
    return {
      HSSpotField.numberOfImagesUploaded.field: numberOfImagesUploaded,
      HSSpotField.fullImages.field: description,
      HSSpotField.fullImages.field: fullImages,
    };
  }

  factory HSSpot.deserialize(Map<String, dynamic> data) {
    return HSSpot(
      uid: data[HSSpotField.uid.field],
      ownersId: data[HSSpotField.ownersId.field],
      name: data[HSSpotField.name.field],
      description: data[HSSpotField.description.field],
      latitude: data[HSSpotField.latitude.field],
      longitude: data[HSSpotField.longitude.field],
      numberOfImagesUploaded: data[HSSpotField.numberOfImagesUploaded.field],
      fullImages: data[HSSpotField.fullImages.field],
      imageThumbnails: data[HSSpotField.imageThumbnails.field],
      geoHash: data[HSSpotField.geoHash.field],
      likes: data[HSSpotField.likes.field],
      saves: data[HSSpotField.saves.field],
      reposts: data[HSSpotField.reposts.field],
    );
  }
}

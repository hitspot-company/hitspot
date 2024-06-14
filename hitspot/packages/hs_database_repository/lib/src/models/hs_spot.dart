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
  List<ImageUrl>? fullImages = List<ImageUrl>.empty(growable: true);
  List<ImageUrl>? imageThumbnails = List<ImageUrl>.empty(growable: true);
  GeoFirePoint? geoHash;
  List<UserID>? likes = List<UserID>.empty(growable: true);
  List<UserID>? saves = List<UserID>.empty(growable: true);
  List<UserID>? reposts = List<UserID>.empty(growable: true);

  HSSpot(
      {this.uid = "",
      required this.ownersId,
      required this.name,
      required this.description,
      required this.latitude,
      required this.longitude,
      required this.numberOfImagesUploaded,
      this.fullImages,
      this.imageThumbnails,
      this.geoHash,
      this.likes,
      this.saves,
      this.reposts}) {
    this.fullImages = fullImages ?? List<ImageUrl>.empty(growable: true);
    this.imageThumbnails =
        imageThumbnails ?? List<ImageUrl>.empty(growable: true);
    this.likes = likes ?? List<UserID>.empty(growable: true);
    this.saves = saves ?? List<UserID>.empty(growable: true);
    this.reposts = reposts ?? List<UserID>.empty(growable: true);
  }

  Map<String, dynamic> serialize() {
    return {
      HSSpotField.uid.field: uid,
      HSSpotField.ownersId.field: ownersId,
      HSSpotField.name.field: name,
      HSSpotField.latitude.field: latitude,
      HSSpotField.longitude.field: longitude,
      HSSpotField.numberOfImagesUploaded.field: numberOfImagesUploaded,
      HSSpotField.description.field: description,
      HSSpotField.fullImages.field: fullImages,
      HSSpotField.imageThumbnails.field: imageThumbnails,
      HSSpotField.geoHash.field: geoHash,
      HSSpotField.likes.field: likes,
      HSSpotField.saves.field: saves,
      HSSpotField.reposts.field: reposts
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

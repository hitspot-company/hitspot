import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/features/spots/create_2/location/view/create_spot_location_provider.dart';
import 'package:hs_database_repository/hs_database_repository.dart';
import 'package:hs_debug_logger/hs_debug_logger.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:page_transition/page_transition.dart';
import 'package:permission_handler/permission_handler.dart';

part 'hs_create_spot_images_state.dart';

class HsCreateSpotImagesCubit extends Cubit<HsCreateSpotImagesState> {
  HsCreateSpotImagesCubit({this.prototype})
      : super(const HsCreateSpotImagesState()) {
    chooseImages();
  }

  final HSSpot? prototype;

  Future<void> chooseImages() async {
    if (prototype != null) {
      emit(state.copyWith(
        status: HsCreateSpotImagesStatus.ready,
        imageUrls: prototype!.images,
      ));
      return;
    }
    final permissionStatus = await Permission.photos.request();
    if (permissionStatus.isPermanentlyDenied) {
      emit(state.copyWith(status: HsCreateSpotImagesStatus.error));
    } else if (permissionStatus.isGranted ||
        await Permission.photos.isLimited) {
      try {
        final images = await app.pickers.multipleImages(
          cropAspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        );
        if (images.isNotEmpty) {
          emit(state.copyWith(
            images: images,
            status: HsCreateSpotImagesStatus.ready,
          ));
        }
      } catch (e) {
        navi.pop();
        return;
      }
    } else {
      emit(state.copyWith(status: HsCreateSpotImagesStatus.error));
      throw "Photos permission is denied: $permissionStatus";
    }
  }

  void reorderImages(int oldIndex, int newIndex) async {
    final List<dynamic> allImages = [...state.images, ...state.imageUrls];
    final item = allImages.removeAt(oldIndex);
    allImages.insert(newIndex, item);

    if (allImages.elementAt(newIndex).runtimeType == String) {
      try {
        final url1 = allImages
            .elementAt(oldIndex)
            .toString()
            .split("storage/v1/object/")
            .last;
        final url2 = allImages
            .elementAt(newIndex)
            .toString()
            .split("storage/v1/object/")
            .last;
        print("Reordering images: $url1, $url2");
        await app.storageRepository.reorderImages(url1, url2);
      } catch (e) {
        HSDebugLogger.logError("Could not reorder images: $e");
      }
    }

    emit(state.copyWith(
      images: allImages.whereType<XFile>().toList(),
      imageUrls: allImages.whereType<String>().toList(),
    ));
  }

  dynamic next() async {
    navi.pushTransition(PageTransitionType.fade,
        CreateSpotLocationProvider(images: state.images, prototype: prototype));
  }
}

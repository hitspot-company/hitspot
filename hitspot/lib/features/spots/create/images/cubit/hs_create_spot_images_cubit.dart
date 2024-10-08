import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/features/spots/create/location/view/create_spot_location_provider.dart';
import 'package:hs_database_repository/hs_database_repository.dart';
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

  bool Function(int) itemDragEnable() {
    if (state.images.isNotEmpty) {
      return (index) => true;
    }
    return (index) => false;
  }

  Future<void> chooseImages([bool force = false]) async {
    if (prototype != null && !force) {
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
            imageUrls: [],
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

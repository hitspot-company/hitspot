import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/features/spots/create_2/location/view/create_spot_location_provider.dart';
import 'package:hs_database_repository/hs_database_repository.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:page_transition/page_transition.dart';
import 'package:permission_handler/permission_handler.dart';

part 'hs_create_spot_images_state.dart';

class HsCreateSpotImagesCubit extends Cubit<HsCreateSpotImagesState> {
  HsCreateSpotImagesCubit({this.prototype})
      : super(const HsCreateSpotImagesState()) {
    _chooseImages();
  }

  final HSSpot? prototype;

  Future<void> _chooseImages() async {
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
          var res = await navi.pushTransition(PageTransitionType.fade,
              CreateSpotLocationProvider(images: images, prototype: prototype));
          if (res == true) {
            _chooseImages();
          }
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
}

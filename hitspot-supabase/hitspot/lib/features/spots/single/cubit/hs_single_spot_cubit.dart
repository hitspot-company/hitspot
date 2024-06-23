import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/features/spots/create/view/create_spot_provider.dart';
import 'package:hs_database_repository/hs_database_repository.dart';
import 'package:hs_debug_logger/hs_debug_logger.dart';
import 'package:hs_location_repository/hs_location_repository.dart';
import 'package:hs_toasts/hs_toasts.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:share_plus/share_plus.dart';

part 'hs_single_spot_state.dart';

class HSSingleSpotCubit extends Cubit<HSSingleSpotState> {
  HSSingleSpotCubit(this.spotID) : super(const HSSingleSpotState()) {
    _fetchSpot();
  }

  final String spotID;
  final _databaseRepository = app.databaseRepository;
  LatLng? get spotLocation =>
      state.spot.latitude == null || state.spot.longitude == null
          ? null
          : LatLng(state.spot.latitude!, state.spot.longitude!);

  Future<void> _fetchSpot() async {
    try {
      final HSSpot spot =
          await _databaseRepository.spotfetchSpotWithAuthor(spotID: spotID);
      final bool isSpotLiked = await _databaseRepository.spotIsSpotLiked(
          spotID: spotID, userID: currentUser.uid);
      final bool isSpotSaved = await _databaseRepository.spotIsSaved(
          spotID: spotID, userID: currentUser.uid);
      final bool isAuthor =
          spot.createdBy == currentUser.uid && currentUser.uid != null;
      HSDebugLogger.logSuccess("Fetched spot: $spot");
      HSDebugLogger.logSuccess("With images: ${spot.images.toString()}");
      emit(state.copyWith(
        spot: spot,
        isSpotLiked: isSpotLiked,
        isSpotSaved: isSpotSaved,
        isAuthor: isAuthor,
        status: HSSingleSpotStatus.loaded,
      ));
    } catch (_) {
      HSDebugLogger.logError("Error fetching spot: $_");
      emit(state.copyWith(status: HSSingleSpotStatus.error));
    }
  }

  Future<void> likeDislikeSpot() async {
    try {
      emit(state.copyWith(status: HSSingleSpotStatus.liking));
      await Future.delayed(const Duration(seconds: 1));
      final bool isSpotLiked = await _databaseRepository.spotLikeDislike(
          spotID: spotID, userID: currentUser.uid);
      emit(state.copyWith(
          isSpotLiked: isSpotLiked, status: HSSingleSpotStatus.loaded));
    } catch (_) {
      HSDebugLogger.logError(_.toString());
    }
  }

  Future<void> saveUnsaveSpot() async {
    try {
      emit(state.copyWith(status: HSSingleSpotStatus.saving));
      await Future.delayed(const Duration(seconds: 1));
      final bool isSpotSaved = await _databaseRepository.spotSaveUnsave(
          spotID: spotID, userID: currentUser.uid);
      emit(state.copyWith(
          isSpotSaved: isSpotSaved, status: HSSingleSpotStatus.loaded));
    } catch (_) {
      HSDebugLogger.logError(_.toString());
    }
  }

  Future<void> showBottomSheet() async {
    return showCupertinoModalBottomSheet(
      context: app.context,
      builder: (context) => Material(
        color: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Gap(8.0),
            HSModalBottomSheetItem(
              title: "Edit",
              iconData: FontAwesomeIcons.penToSquare,
              onTap: () => navi.pushPage(
                page: CreateSpotProvider(prototype: state.spot),
              ),
            ),
            HSModalBottomSheetItem(
              iconData: FontAwesomeIcons.arrowUpRightFromSquare,
              title: "Share",
              onTap: shareSpot,
            ),
            HSModalBottomSheetItem(
              iconData: FontAwesomeIcons.trashCan,
              title: "Delete",
              onTap: _deleteSpot,
            ),
            const SizedBox(
              height: 20.0,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> shareSpot() async {
    try {
      await Share.share("https://hitspot.app/spot/${state.spot.sid}",
          subject:
              "Check out this spot: ${state.spot.title} by ${state.spot.author!.username}");
    } catch (_) {
      HSDebugLogger.logError("Could not share spot: $_");
    }
  }

  Future<void> _deleteSpot() async {
    try {
      final bool? isDelete = await showAdaptiveDialog(
        context: app.context,
        builder: (context) => AlertDialog.adaptive(
          title: const Text('Delete Spot'),
          content: const Text.rich(
            TextSpan(
              text: 'Destructive Action. ',
              style: TextStyle(fontWeight: FontWeight.bold),
              children: [
                TextSpan(
                    text: "This spot will be deleted permanently.",
                    style: TextStyle(fontWeight: FontWeight.normal))
              ],
            ),
          ),
          actions: <Widget>[
            CupertinoDialogAction(
              onPressed: () => navi.pop(false),
              child: const Text('Cancel'),
            ),
            CupertinoDialogAction(
              onPressed: () => navi.pop(true),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      if (isDelete == true) {
        HSDebugLogger.logSuccess("Delete");
        emit(state.copyWith(status: HSSingleSpotStatus.deleting));
        await _databaseRepository.spotDelete(spot: state.spot);
        HSDebugLogger.logSuccess("Spot deleted successfully");
        navi.router.go('/');
        return;
      } else {
        HSDebugLogger.logError("Cancelled");
      }
    } catch (_) {
      HSDebugLogger.logError(_.toString());
    }
  }
}

class HSModalBottomSheetItem extends StatelessWidget {
  const HSModalBottomSheetItem({
    super.key,
    this.onTap,
    this.borderRadius = 8.0,
    this.leftPadding = 16.0,
    this.height = 60.0,
    required this.title,
    required this.iconData,
  });

  final VoidCallback? onTap;
  final double borderRadius, leftPadding, height;
  final String title;
  final IconData iconData;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(borderRadius),
          onTap: onTap ?? () {},
          child: SizedBox(
              height: height,
              width: screenWidth,
              child: Padding(
                padding: EdgeInsets.only(left: leftPadding),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(iconData),
                    const Gap(16.0),
                    Text(title, style: const TextStyle(fontSize: 16.0)),
                  ],
                ),
              )),
        ),
      ),
    );
  }
}

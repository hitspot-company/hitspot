import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/features/spots/create/cubit/hs_spot_creation_data.dart';
import 'package:hitspot/features/spots/create/cubit/hs_spot_upload_cubit.dart';
import 'package:hitspot/features/spots/create/map/view/choose_location_provider.dart';
import 'package:hitspot/main.dart';
import 'package:hitspot/widgets/hs_scaffold.dart';
import 'package:hs_database_repository/hs_database_repository.dart';
import 'package:hs_debug_logger/hs_debug_logger.dart';
import 'package:hs_location_repository/hs_location_repository.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

part 'hs_create_spot_state.dart';

class HSCreateSpotCubit extends Cubit<HSCreateSpotState> {
  HSCreateSpotCubit({this.prototype}) : super(const HSCreateSpotState()) {
    _initializeCreatingSpot();
  }

  final HSSpot? prototype;
  final PageController pageController = PageController();
  final _locationRepository = app.locationRepository;
  String get titleHint =>
      state.title.isEmpty ? "The best spot on earth..." : state.title;
  String? get titleInitialValue => state.title.isEmpty ? null : state.title;
  final HSDatabaseRepsitory _databaseRepository = app.databaseRepository;
  final TextEditingController categoriesController = TextEditingController();

  String get descriptionHint =>
      state.description.isEmpty ? "Writings on the wall..." : state.description;
  String? get descriptionInitialValue =>
      state.description.isEmpty ? null : state.description;

  void unfocus() => HSScaffold.hideInput();

  void nextPage() {
    unfocus();
    pageController.nextPage(
        duration: const Duration(milliseconds: 200), curve: Curves.easeIn);
  }

  void prevPage() {
    unfocus();
    pageController.previousPage(
        duration: const Duration(milliseconds: 200), curve: Curves.easeIn);
  }

  void _initializeCreatingSpot() async {
    try {
      HSDebugLogger.logInfo("Initializing creating spot");
      emit(state.copyWith(
          status: HSCreateSpotStatus.requestingLocationPermission));
      await _requestLocationPermission();
      if (prototype == null) {
        await _chooseImages();
      }
      await _chooseLocation();
      if (prototype != null) {
        emit(
          state.copyWith(
            title: prototype!.title,
            description: prototype!.description,
          ),
        );
      }
    } catch (_) {
      HSDebugLogger.logError("Error: $_");
      navi.pop();
    }
  }

  Future<void> _requestLocationPermission() async {
    try {
      final Position currentPosition =
          app.currentPosition ?? await _locationRepository.getCurrentLocation();
      emit(state.copyWith(
          currentLocation: currentPosition,
          status: HSCreateSpotStatus.choosingImages));
    } catch (_) {
      rethrow;
    }
  }

  Future<void> _chooseImages() async {
    try {
      final List<XFile> images = await app.pickers.multipleImages(
          cropAspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1));
      emit(state.copyWith(
          images: images, status: HSCreateSpotStatus.choosingLocation));
    } catch (_) {
      throw Exception("No images selected: $_");
    }
  }

  Future<void> _chooseLocation() async {
    final HSLocation? result = await navi.pushPage(
        page: ChooseLocationProvider(
            initialUserLocation: state.currentLocation!));
    if (result != null) {
      HSDebugLogger.logSuccess("Received location: $result");
      emit(state.copyWith(
          spotLocation: result, status: HSCreateSpotStatus.fillingData));
    } else {
      throw "No location selected";
    }
  }

  void updateTitle(String value) => emit(state.copyWith(title: value));
  void updateDescription(String value) =>
      emit(state.copyWith(description: value));
  void updateTagsQuery(String value) {
    emit(state.copyWith(tagsQuery: value));
    _fetchTags();
  }

  List<File> get _xfilesToFiles =>
      state.images.map((e) => File(e.path)).toList();

  final HSSpotUploadCubit spotUploadCubit =
      BlocProvider.of<HSSpotUploadCubit>(app.context);

  Future<void> submitSpot() async {
    try {
      emit(state.copyWith(status: HSCreateSpotStatus.submitting));
      final double lat = state.spotLocation!.latitude;
      final double long = state.spotLocation!.longitude;
      final HSSpot spot = HSSpot(
        title: state.title,
        description: state.description,
        geohash: _locationRepository.encodeGeoHash(lat, long),
        createdBy: currentUser.uid!,
        latitude: lat,
        longitude: long,
        address: state.spotLocation!.address,
      );

      if (RootIsolateToken.instance == null) {
        HSDebugLogger.logError("RootIsolateToken is null");
        return;
      }

      if (prototype != null) {
        // Handle updating existing spot (not using isolate for simplicity)
        await app.databaseRepository
            .spotUpdate(spot: spot.copyWith(sid: prototype!.sid!));
        if (state.selectedTags.isNotEmpty) {
          await uploadTags(prototype!.sid!);
        }
        HSDebugLogger.logSuccess("Spot updated: ${prototype!.sid!}");
        navi.go("/user/${currentUser.uid}");
        navi.push('/spot/${prototype!.sid}');
      } else {
        final receivePort = ReceivePort();
        final spotData = HSSpotCreationData(
          rootIsolateToken: RootIsolateToken.instance!,
          spot: spot,
          imagePaths: state.images.map((e) => e.path).toList(),
          uid: currentUser.uid!,
          tags: state.selectedTags,
          sendPort: receivePort.sendPort,
          supabaseData: {
            'url': dotenv.env['SUPABASE_URL'],
            'anonKey': dotenv.env['SUPABASE_ANON_KEY'],
          },
          currentSession: supabase.auth.currentSession,
        );

        spotUploadCubit.startUpload();
        navi.go('/');
        await createSpotWithIsolate(spotData, spotUploadCubit);
      }
    } catch (e) {
      HSDebugLogger.logError("Could not submit spot: $e");
      emit(state.copyWith(status: HSCreateSpotStatus.error));
    }
  }

  Future<void> _fetchTags() async {
    try {
      final res = await supabase
          .from('tags')
          .select()
          .textSearch('tag_value', "${state.tagsQuery}:*")
          .limit(10)
          .select();
      final List<String> tags =
          res.map((e) => e['tag_value'] as String).toList();
      emit(state.copyWith(queriedTags: tags));
    } catch (_) {
      HSDebugLogger.logError("Could not fetch tags: $_");
    }
  }

  void selectTag(String tag) {
    if (!state.selectedTags.contains(tag)) {
      final newSelectedTags = List<String>.from(state.selectedTags)..add(tag);
      categoriesController.clear();
      emit(state.copyWith(selectedTags: newSelectedTags, tagsQuery: ""));
    }
  }

  void deselectTag(String tag) {
    final newSelectedTags = List<String>.from(state.selectedTags)..remove(tag);
    emit(state.copyWith(selectedTags: newSelectedTags));
  }

  Future<void> uploadTags(String spotID) async {
    try {
      final List<String> tags = state.selectedTags;
      for (var i = 0; i < tags.length; i++) {
        await _databaseRepository.tagSpotCreate(
            value: tags[i], spotID: spotID, userID: currentUser.uid!);
      }
      HSDebugLogger.logSuccess("Uploaded tags: $tags");
    } catch (_) {
      HSDebugLogger.logError("Failed to upload tags: $_");
    }
  }

  @override
  Future<void> close() async {
    categoriesController.dispose();
    return super.close();
  }
}

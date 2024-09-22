import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/features/spots/create/cubit/hs_spot_creation_data.dart';
import 'package:hitspot/features/spots/create/cubit/hs_spot_upload_cubit.dart';
import 'package:hitspot/main.dart';
import 'package:hitspot/widgets/hs_scaffold.dart';
import 'package:hs_database_repository/hs_database_repository.dart';
import 'package:hs_debug_logger/hs_debug_logger.dart';
import 'package:hs_location_repository/hs_location_repository.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pair/pair.dart';

part 'hs_create_spot_form_state.dart';

class HsCreateSpotFormCubit extends Cubit<HSCreateSpotFormState> {
  HsCreateSpotFormCubit(
      {this.prototype, required this.images, required this.location})
      : super(const HSCreateSpotFormState()) {
    emit(state.copyWith(
      spotLocation: location,
      images: images,
      title: prototype?.title,
      description: prototype?.description,
      selectedTags: prototype?.tags,
    ));
  }

  final HSSpot? prototype;
  final List<XFile> images;
  final HSLocation location;
  final PageController pageController = PageController();
  final _locationRepository = app.locationRepository;
  String get titleHint =>
      state.description.isEmpty ? "The best spot on earth..." : state.title;
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

  void updateTitle(String value) => emit(state.copyWith(title: value));
  void updateDescription(String value) =>
      emit(state.copyWith(description: value));
  void updateTagsQuery(String value) {
    emit(state.copyWith(tagsQuery: value));
    _fetchTags();
  }

  final HSSpotUploadCubit spotUploadCubit =
      BlocProvider.of<HSSpotUploadCubit>(app.context);

  Future<void> submitSpot() async {
    try {
      emit(state.copyWith(status: HSCreateSpotFormStatus.submitting));
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
        images: state.images.map((e) => e.path).toList(),
        tags: state.selectedTags,
      );

      if (RootIsolateToken.instance == null) {
        HSDebugLogger.logError("RootIsolateToken is null");
        return;
      }

      if (prototype != null) {
        final spotWithPrototype = spot.copyWith(
            sid: prototype!.sid,
            latitude: lat,
            longitude: long,
            images: prototype!.images,
            thumbnails: prototype!.thumbnails,
            tags: prototype!.tags);
        await _updateSpot(spotWithPrototype);
        HSDebugLogger.logSuccess("Spot updated: ${prototype!.sid!}");
        navi.go("/user/${currentUser.uid}");
        navi.push('/spot/${prototype!.sid}');
      } else {
        final receivePort = ReceivePort();
        final spotData = HSSpotCreationData(
          rootIsolateToken: RootIsolateToken.instance!,
          spot: spot,
          uid: currentUser.uid!,
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
        return;
      }
    } catch (e) {
      HSDebugLogger.logError("Could not submit spot: $e");
      emit(state.copyWith(status: HSCreateSpotFormStatus.error));
    }
  }

  Future<void> _clearSpotData(HSSpot spot) async {
    if (state.images.isNotEmpty) {
      await app.storageRepository
          .spotDeleteImages(images: spot.images, thumbnails: spot.thumbnails);
      await _databaseRepository.spotDeleteImages(spot: spot);
      for (var i = 0; i < spot.images!.length; i++) {
        final image = spot.images![i];
        await CachedNetworkImage.evictFromCache(image);
      }
    }
    if (spot.tags != state.selectedTags) {
      final List<String> tagsToRemove =
          spot.tags!.where((e) => !state.selectedTags.contains(e)).toList();
      HSDebugLogger.logInfo("Tags to remove: $tagsToRemove");
      await _databaseRepository.tagDeleteSpotTags(
          spot: spot, tags: tagsToRemove);
    }
  }

  Future<void> _updateSpot(HSSpot spot) async {
    await _clearSpotData(spot);
    if (state.selectedTags.isNotEmpty) {
      late final List<String> tagsToUpload;
      if (prototype!.tags != null) {
        tagsToUpload = state.selectedTags
            .where((e) => !prototype!.tags!.contains(e))
            .toList();
      } else {
        tagsToUpload = state.selectedTags;
      }
      await uploadTags(prototype!.sid!, tagsToUpload);
    }
    final List<Pair<String, String>> urls =
        await app.storageRepository.spotUploadImages(
      files: state.images.map((e) => File(e.path)).toList(),
      uid: app.currentUser.uid!,
      sid: spot.sid!,
    );
    await _databaseRepository.spotUploadImages(
      spotID: spot.sid!,
      imageUrls: urls,
      uid: app.currentUser.uid!,
    );
    await app.databaseRepository.spotUpdate(spot: spot);
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

  Future<void> uploadTags(String spotID, List<String> tags) async {
    try {
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

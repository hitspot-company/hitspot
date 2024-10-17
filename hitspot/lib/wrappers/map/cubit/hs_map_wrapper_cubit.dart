import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/features/map/cluster/view/cluster_map_page.dart';
import 'package:hitspot/utils/assets/hs_assets.dart';
import 'package:hs_database_repository/hs_database_repository.dart';
import 'package:hs_debug_logger/hs_debug_logger.dart';
import 'package:hs_location_repository/hs_location_repository.dart';

part 'hs_map_wrapper_state.dart';

class HSMapWrapperCubit extends Cubit<HSMapWrapperState> {
  late final GoogleMapController mapController;
  late final void Function(HSSpot)? onMarkerTapped;
  late final void Function()? onCameraIdle;
  late final void Function(CameraPosition)? onCameraMove;
  final _locationRepository = app.locationRepository;
  late final CameraPosition initialCameraPosition;

  CameraPosition get cameraPosition {
    _initCheck();
    return state.cameraPosition;
  }

  CameraPosition get getInitialCameraPosition {
    _initCheck();
    return initialCameraPosition;
  }

  HSMapWrapperCubit() : super(const HSMapWrapperState());

  /// Ensures that the HSMapWrapperCubit is properly initialised.
  ///
  /// This method checks if the cubit's state is initialised. If the state is not
  /// initialised, an assertion error is thrown with a message indicating that
  /// the cubit must be initialised using the `init()` method.
  void _initCheck() {
    assert(state.isInitialised,
        "The HSMapWrapperCubit must be initialised. Please use the init() method to initialise the cubit.");
  }

  /// Initializes the HSMapWrapperCubit with the provided parameters.
  ///
  /// This method sets up various callbacks and initial states for the map wrapper.
  /// It handles marker taps, camera movements, and visibility of spots on the map.
  /// If no visible spots or initial camera position are provided, it sets default values.
  ///
  /// Parameters:
  /// - `onMarkerTapped`: A callback function that is called when a marker is tapped.
  /// - `onCameraIdle`: A callback function that is called when the camera becomes idle.
  /// - `visibleSpots`: A list of spots that should be visible on the map.
  /// - `initialCameraPosition`: The initial position of the camera on the map.
  /// - `onCameraMove`: A callback function that is called when the camera moves.
  ///
  /// Throws:
  /// - Logs an error message if initialization fails.
  ///
  /// Emits:
  /// - Updates the state to indicate that the map wrapper has been successfully initialized.
  void init({
    void Function(HSSpot)? onMarkerTapped,
    void Function()? onCameraIdle,
    List<HSSpot>? visibleSpots,
    CameraPosition? initialCameraPosition,
    void Function(CameraPosition)? onCameraMove,
  }) {
    try {
      setOnMarkerTapped(onMarkerTapped);
      setOnCameraIdle(onCameraIdle);
      setOnCameraMove(onCameraMove);
      if (visibleSpots == null && initialCameraPosition == null) {
        _setDefaultInitialCameraPositionAndCloseSpots();
      } else {
        setVisibleSpots(visibleSpots);
        setInitialCameraPosition(initialCameraPosition);
      }
      emit(state.copyWith(isInitialised: true));
      HSDebugLogger.logSuccess(
          "The HSMapWrapper has been successfully initialised.");
    } catch (e) {
      HSDebugLogger.logError("[!] Failed to initialise HSMapWrapperCubit: $e");
    }
  }

  /// Updates the visible spots on the map.
  ///
  /// This method compares the provided list of spots with the current list of
  /// visible spots. If they are different, it updates the state with the new
  /// list of visible spots.
  ///
  /// [spots] - A list of [HSSpot] objects representing the spots to be made
  /// visible on the map. If the provided list is the same as the current list
  /// of visible spots, no update will be made.
  void setVisibleSpots(List<HSSpot>? spots) async {
    final currentSpots = state.visibleSpots;
    if (currentSpots == spots) return;
    emit(state.copyWith(visibleSpots: spots));
  }

  /// Sets the callback function to be executed when the camera moves.
  ///
  /// If the provided [onCameraMove] callback is `null`, a default callback is set
  /// which logs an error message and updates the camera position in the state.
  ///
  /// If a non-null [onCameraMove] callback is provided, it will be executed along
  /// with updating the camera position in the state and calling `updateMarkerLevel()`.
  ///
  /// [onCameraMove] - A callback function that takes a [CameraPosition] as a parameter.
  void setOnCameraMove(void Function(CameraPosition)? onCameraMove) {
    if (onCameraMove == null) {
      HSDebugLogger.logError("onCameraMove is null");
      this.onCameraMove = (CameraPosition position) {
        emit(state.copyWith(cameraPosition: position));
      };
    } else {
      this.onCameraMove = (CameraPosition pos) {
        onCameraMove(pos);
        emit(state.copyWith(cameraPosition: pos));
        updateMarkerLevel();
      };
    }
  }

  Future<void> _setDefaultInitialCameraPositionAndCloseSpots() async {
    try {
      final currentPosition = await _locationRepository.getCurrentLocation();
      final res = await _locationRepository
          .getInitialCameraPositionAndSpots(currentPosition);
      setInitialCameraPosition(res?.key);
      setVisibleSpots(res?.value);
    } catch (e) {
      HSDebugLogger.logError(
          "[!] Failed to set the default initial camera position and close spots: $e");
    }
  }

  /// Sets the initial camera position for the map.
  ///
  /// If the provided [initialCameraPosition] is `null`, it defaults to
  /// [kDefaultCameraPosition]. Otherwise, it sets the initial camera
  /// position to the provided value.
  ///
  /// - Parameter [initialCameraPosition]: The initial position of the camera.
  void setInitialCameraPosition(CameraPosition? initialCameraPosition) {
    if (initialCameraPosition == null) {
      this.initialCameraPosition = kDefaultCameraPosition;
    } else {
      this.initialCameraPosition = initialCameraPosition;
    }
  }

  /// Sets the callback function to be executed when a marker is tapped on the map.
  ///
  /// If the provided [onMarkerTapped] callback is `null`, a default callback is used
  /// which logs an info message and sets the selected spot.
  ///
  /// The [onMarkerTapped] callback takes an [HSSpot] as a parameter.
  ///
  /// - [onMarkerTapped]: The callback function to be executed when a marker is tapped.
  ///   If `null`, a default callback is used.
  void setOnMarkerTapped(void Function(HSSpot)? onMarkerTapped) {
    if (onMarkerTapped == null) {
      HSDebugLogger.logError("onMarkerTapped is null");
      this.onMarkerTapped = (spot) {
        HSDebugLogger.logInfo("Using default onMarkerTapped");
        setSelectedSpot(spot);
      };
    } else {
      this.onMarkerTapped = onMarkerTapped;
    }
  }

  /// Called when the map is created. If the current state status is `initial`,
  /// it assigns the provided [controller] to the [mapController] and updates
  /// the state status to `initialised`.
  ///
  /// [controller] - The GoogleMapController instance created for the map.
  void onMapCreated(GoogleMapController controller) {
    if (state.status == HSMapWrapperStatus.initial) {
      mapController = controller;
      emit(state.copyWith(status: HSMapWrapperStatus.initialised));
    }
  }

  /// Updates the marker level based on the current camera position's zoom level.
  ///
  /// This method first checks if the initialization is complete. It then retrieves
  /// the current camera position and calculates the appropriate marker level using
  /// the zoom level. If the new marker level is different from the current one in
  /// the state, it emits a new state with the updated marker level and calls
  /// `updateMarkers` to refresh the markers.
  void updateMarkerLevel() {
    _initCheck();
    final position = state.cameraPosition;
    final markerLevel = HSSpotMarker.getMarkerLevel(position.zoom);
    if (markerLevel != state.markerLevel) {
      emit(state.copyWith(markerLevel: markerLevel));
      updateMarkers();
    }
  }

  /// Updates the markers on the map based on the provided list of spots or the current visible spots in the state.
  ///
  /// If no list of spots is provided, the method uses the `visibleSpots` from the current state.
  /// The method filters the spots based on the current filters in the state and creates a set of markers.
  /// Each marker is created with a unique ID, position, icon, and an onTap callback.
  /// Finally, the method emits a new state with the updated set of markers.
  ///
  /// [spots] - An optional list of [HSSpot] objects to update the markers with.
  void updateMarkers([List<HSSpot>? spots]) {
    _initCheck();
    spots ??= state.visibleSpots;
    final markers = spots.where((spot) {
      if (state.filters.isEmpty) return true;
      return spot.tags?.any((tag) => state.filters.contains(tag)) ?? false;
    }).map((e) {
      final markerIcon = app.assets.getMarkerIcon(e,
          level: state.markerLevel, isSelected: state.selectedSpot == e);
      return Marker(
        markerId: MarkerId(e.sid!),
        position: LatLng(e.latitude!, e.longitude!),
        icon: markerIcon,
        onTap: () => _onMarkerTapped(e),
      );
    }).toSet();
    emit(state.copyWith(markers: markers));
  }

  /// Sets the selected spot in the state.
  ///
  /// This method updates the state with the provided [spot] by emitting a new state
  /// with the selected spot updated.
  ///
  /// [spot] : The [HSSpot] to be set as the selected spot. It can be null.
  void setSelectedSpot(HSSpot? spot) {
    emit(state.copyWith(selectedSpot: spot));
  }

  /// Clears the currently selected spot by emitting a new state with an empty [HSSpot].
  ///
  /// Also updates the markers on the map.
  void clearSelectedSpot() {
    emit(state.copyWith(
        selectedSpot: const HSSpot(),
        visibleSpots: [...state.visibleSpots, state.selectedSpot]));
    updateMarkers();
  }

  void setOnCameraIdle(void Function()? onCameraIdle) {
    if (onCameraIdle == null) {
      HSDebugLogger.logError("onCameraIdle is null");
      this.onCameraIdle = () {
        HSDebugLogger.logInfo("Using default onCameraIdle");
        updateMarkers();
      };
    } else {
      this.onCameraIdle = onCameraIdle;
    }
  }

  Future<void> moveCamera(LatLng newPosition, double zoom) async {
    _initCheck();
    final newCameraPosition = CameraPosition(target: newPosition, zoom: zoom);
    await mapController
        .animateCamera(CameraUpdate.newCameraPosition(newCameraPosition));
    emit(state.copyWith(cameraPosition: newCameraPosition));
  }

  void clearMarkers() {
    _initCheck();
    emit(state.copyWith(markers: {}));
  }

  void _onMarkerTapped(HSSpot spot) {
    if (onMarkerTapped != null) {
      onMarkerTapped!(spot);
    } else {
      HSDebugLogger.logError("onMarkerTapped is not set");
    }
  }

  Future<void> zoomInToMarker([double zoom = 18.0]) async {
    _initCheck();
    try {
      if (state.selectedSpot.sid != null) {
        final spot = state.selectedSpot;
        await moveCamera(LatLng(spot.latitude!, spot.longitude!), zoom);
      }
    } catch (e) {
      HSDebugLogger.logError("Error zooming in to marker: $e");
    }
  }

  Future<void> animateToCurrentPosition() async {
    try {
      final currentPosition = await _locationRepository.getCurrentLocation();
      final cameraPosition = CameraPosition(
        target: LatLng(currentPosition.latitude, currentPosition.longitude),
        zoom: 18.0,
      );
      await mapController
          .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
      emit(state.copyWith(cameraPosition: cameraPosition));
    } catch (e) {
      HSDebugLogger.logError("[!] Failed to animate to current position: $e");
    }
  }

  /// Fetches and returns a sorted list of unique tags from the visible spots.
  ///
  /// This method iterates over the `visibleSpots` in the current state,
  /// collects all tags, removes duplicates by converting them to a set,
  /// and then sorts the tags alphabetically.
  ///
  /// Returns:
  ///   A sorted list of unique tags as strings.
  List<String> fetchFilters() {
    final tags =
        state.visibleSpots.expand((spot) => spot.tags ?? []).toSet().toList();
    tags.sort();
    return tags.cast<String>();
  }

  /// Displays a filter selection dialog and updates the state with the selected filters.
  ///
  /// This method shows a dialog with filter options and waits for the user's selection.
  /// If the user selects filters and confirms, the state is updated with the new filters
  /// and the markers are updated accordingly.
  ///
  /// Parameters:
  /// - `context`: The BuildContext in which to show the dialog.
  ///
  /// Returns:
  /// - `void`: This method does not return a value.
  void showFilters(BuildContext context) async {
    List<String> filterOptions = fetchFilters();

    final List<String>? result = await showDialog<List<String>>(
      context: context,
      builder: (BuildContext context) {
        return HSFilterPopup(
            filterOptions: filterOptions, selected: state.filters);
      },
    );

    if (result != null) {
      emit(state.copyWith(filters: result));
      updateMarkers();
    }
  }

  @override
  Future<void> close() {
    if (state.status == HSMapWrapperStatus.initialised) {
      mapController.dispose();
    }
    HSDebugLogger.logInfo('HSMapWrapperCubit closed');
    return super.close();
  }

  @override
  String toString() => 'HSMapWrapperCubit';
}

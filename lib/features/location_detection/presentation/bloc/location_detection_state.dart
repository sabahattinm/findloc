part of 'location_detection_bloc.dart';

/// Base class for location detection states
abstract class LocationDetectionState {
  const LocationDetectionState();
}

/// Initial state
class LocationDetectionInitial extends LocationDetectionState {
  const LocationDetectionInitial();
}

/// Loading state
class LocationDetectionLoading extends LocationDetectionState {
  const LocationDetectionLoading({this.imagePath});

  final String? imagePath;
}

/// Success state with detected location
class LocationDetectionSuccess extends LocationDetectionState {
  const LocationDetectionSuccess({required this.location});

  final LocationEntity location;
}

/// State when location detection is successful but blurred (first scan)
class LocationDetectionBlurred extends LocationDetectionState {
  const LocationDetectionBlurred({required this.location});

  final LocationEntity location;
}

/// Error state
class LocationDetectionError extends LocationDetectionState {
  const LocationDetectionError(this.message);

  final String message;
}

/// State when location history is loaded
class LocationHistoryLoaded extends LocationDetectionState {
  const LocationHistoryLoaded({required this.history});

  final List<LocationEntity> history;
}

/// State when nearby cameras are loading
class NearbyCamerasLoading extends LocationDetectionState {
  const NearbyCamerasLoading();
}

/// State when nearby cameras are loaded
class NearbyCamerasLoaded extends LocationDetectionState {
  const NearbyCamerasLoaded({required this.cameras});

  final List<LiveCameraEntity> cameras;
}

/// State when location history is cleared
class LocationHistoryCleared extends LocationDetectionState {
  const LocationHistoryCleared();
}

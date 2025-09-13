part of 'location_detection_bloc.dart';

/// Base class for location detection events
abstract class LocationDetectionEvent {
  const LocationDetectionEvent();
}

/// Event to detect location from image file
class DetectLocationFromImage extends LocationDetectionEvent {
  const DetectLocationFromImage({
    required this.imageFile,
    this.isDetailedAnalysis = true,
  });

  final File imageFile;
  final bool isDetailedAnalysis;
}

/// Event to detect location from image URL
class DetectLocationFromUrl extends LocationDetectionEvent {
  const DetectLocationFromUrl({
    required this.imageUrl,
    this.isDetailedAnalysis = true,
  });

  final String imageUrl;
  final bool isDetailedAnalysis;
}

/// Event to load location history
class LoadLocationHistory extends LocationDetectionEvent {
  const LoadLocationHistory();
}

/// Event to load nearby cameras
class LoadNearbyCameras extends LocationDetectionEvent {
  const LoadNearbyCameras({required this.location});

  final LocationEntity location;
}

/// Event to pick image from camera
class PickImageFromCamera extends LocationDetectionEvent {
  const PickImageFromCamera();
}

/// Event to pick image from gallery
class PickImageFromGallery extends LocationDetectionEvent {
  const PickImageFromGallery();
}

/// Event to clear location history
class ClearLocationHistory extends LocationDetectionEvent {
  const ClearLocationHistory();
}

/// Event to reset state
class ResetState extends LocationDetectionEvent {
  const ResetState();
}

/// Event to show full results (for testing)
class ShowFullResults extends LocationDetectionEvent {
  const ShowFullResults({required this.location});

  final LocationEntity location;
}

/// Event to search nearby cameras using current location
class SearchNearbyCameras extends LocationDetectionEvent {
  const SearchNearbyCameras();
}

/// Event to load demo cameras for testing
class LoadDemoCameras extends LocationDetectionEvent {
  const LoadDemoCameras();
}

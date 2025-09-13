part of 'live_camera_bloc.dart';

/// Base class for all live camera events
abstract class LiveCameraEvent {
  const LiveCameraEvent();
}

/// Event to load nearby cameras for a location
class LoadNearbyCameras extends LiveCameraEvent {
  const LoadNearbyCameras({required this.location}) : super();

  final LocationEntity location;
}

/// Event to load all available cameras
class LoadAllCameras extends LiveCameraEvent {
  const LoadAllCameras() : super();
}

/// Event to load camera by ID
class LoadCameraById extends LiveCameraEvent {
  const LoadCameraById({required this.cameraId}) : super();

  final String cameraId;
}

/// Event to load cameras by type
class LoadCamerasByType extends LiveCameraEvent {
  const LoadCamerasByType({required this.type}) : super();

  final CameraType type;
}

/// Event to search cameras
class SearchCameras extends LiveCameraEvent {
  const SearchCameras({required this.query}) : super();

  final String query;
}

/// Event to load camera stream
class LoadCameraStream extends LiveCameraEvent {
  const LoadCameraStream({required this.cameraId}) : super();

  final String cameraId;
}

/// Event to check camera status
class CheckCameraStatus extends LiveCameraEvent {
  const CheckCameraStatus({required this.cameraId}) : super();

  final String cameraId;
}

/// Event to load camera thumbnail
class LoadCameraThumbnail extends LiveCameraEvent {
  const LoadCameraThumbnail({required this.cameraId}) : super();

  final String cameraId;
}

/// Event to reset state
class ResetState extends LiveCameraEvent {
  const ResetState() : super();
}

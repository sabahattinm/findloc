part of 'live_camera_bloc.dart';

/// Base class for all live camera states
abstract class LiveCameraState {
  const LiveCameraState();
}

/// Initial state
class LiveCameraInitial extends LiveCameraState {
  const LiveCameraInitial() : super();
}

/// Loading state
class LiveCameraLoading extends LiveCameraState {
  const LiveCameraLoading() : super();
}

/// State when cameras are loaded successfully
class LiveCameraLoaded extends LiveCameraState {
  const LiveCameraLoaded({required this.cameras}) : super();

  final List<LiveCameraEntity> cameras;
}

/// State when camera stream is loaded
class LiveCameraStreamLoaded extends LiveCameraState {
  const LiveCameraStreamLoaded({required this.streamUrl}) : super();

  final String streamUrl;
}

/// State when camera status is checked
class LiveCameraStatusChecked extends LiveCameraState {
  const LiveCameraStatusChecked({required this.isActive}) : super();

  final bool isActive;
}

/// State when camera thumbnail is loaded
class LiveCameraThumbnailLoaded extends LiveCameraState {
  const LiveCameraThumbnailLoaded({required this.thumbnailUrl}) : super();

  final String? thumbnailUrl;
}

/// Error state
class LiveCameraError extends LiveCameraState {
  const LiveCameraError(this.message) : super();

  final String message;
}

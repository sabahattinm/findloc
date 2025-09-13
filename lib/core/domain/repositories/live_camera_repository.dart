import '../entities/live_camera_entity.dart';
import '../entities/location_entity.dart';

/// Repository interface for live camera operations
abstract class LiveCameraRepository {
  /// Get nearby live cameras for a specific location
  Future<List<LiveCameraEntity>> getNearbyCameras(LocationEntity location);
  
  /// Get all available live cameras
  Future<List<LiveCameraEntity>> getAllCameras();
  
  /// Get camera by ID
  Future<LiveCameraEntity?> getCameraById(String cameraId);
  
  /// Get cameras by type
  Future<List<LiveCameraEntity>> getCamerasByType(CameraType type);
  
  /// Search cameras by name or description
  Future<List<LiveCameraEntity>> searchCameras(String query);
  
  /// Get camera stream URL
  Future<String> getCameraStreamUrl(String cameraId);
  
  /// Check if camera is currently active
  Future<bool> isCameraActive(String cameraId);
  
  /// Get camera thumbnail
  Future<String?> getCameraThumbnail(String cameraId);
}

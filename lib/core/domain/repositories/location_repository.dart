import 'dart:io';
import '../entities/location_entity.dart';
import '../entities/live_camera_entity.dart';
import '../../errors/failures.dart';

/// Repository interface for location detection operations
abstract class LocationRepository {
  /// Detect location from an image file
  Future<LocationEntity> detectLocationFromImage(
    File imageFile, {
    bool isDetailedAnalysis = true,
    bool useTwoStageAnalysis = false,
  });

  /// Detect location from image URL
  Future<LocationEntity> detectLocationFromUrl(
    String imageUrl, {
    bool isDetailedAnalysis = true,
    bool useTwoStageAnalysis = false,
  });

  /// Get location history for the user
  Future<List<LocationEntity>> getLocationHistory();

  /// Save detected location to history
  Future<void> saveLocationToHistory(LocationEntity location);

  /// Clear location history
  Future<void> clearLocationHistory();

  /// Get nearby live cameras for a location
  Future<List<LiveCameraEntity>> getNearbyCameras(LocationEntity location);

  /// Validate image file before processing
  Future<bool> validateImageFile(File imageFile);
}

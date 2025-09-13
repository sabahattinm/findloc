import 'dart:io';
import '../../domain/entities/location_entity.dart';
import '../../domain/entities/live_camera_entity.dart';
import '../../domain/repositories/location_repository.dart';
import '../../errors/failures.dart';

/// Use case for detecting location from image
class DetectLocationUseCase {
  const DetectLocationUseCase(this._repository);

  final LocationRepository _repository;

  /// Execute location detection from image file
  Future<LocationEntity> call(DetectLocationParams params) async {
    // Validate image file first
    final isValid = await _repository.validateImageFile(params.imageFile);
    if (!isValid) {
      throw const ValidationFailure('Geçersiz görsel dosyası');
    }

    // Detect location
    final location = await _repository.detectLocationFromImage(
      params.imageFile,
      isDetailedAnalysis: params.isDetailedAnalysis,
    );

    // Save to history
    await _repository.saveLocationToHistory(location);

    return location;
  }
}

/// Parameters for location detection
class DetectLocationParams {
  const DetectLocationParams({
    required this.imageFile,
    this.saveToHistory = true,
    this.isDetailedAnalysis = true,
    this.useTwoStageAnalysis = false,
  });

  final File imageFile;
  final bool saveToHistory;
  final bool isDetailedAnalysis;
  final bool useTwoStageAnalysis;
}

/// Use case for detecting location from URL
class DetectLocationFromUrlUseCase {
  const DetectLocationFromUrlUseCase(this._repository);

  final LocationRepository _repository;

  /// Execute location detection from image URL
  Future<LocationEntity> call(DetectLocationFromUrlParams params) async {
    // Detect location from URL
    final location = await _repository.detectLocationFromUrl(
      params.imageUrl,
      isDetailedAnalysis: params.isDetailedAnalysis,
    );

    // Save to history if requested
    if (params.saveToHistory) {
      await _repository.saveLocationToHistory(location);
    }

    return location;
  }
}

/// Parameters for location detection from URL
class DetectLocationFromUrlParams {
  const DetectLocationFromUrlParams({
    required this.imageUrl,
    this.saveToHistory = true,
    this.isDetailedAnalysis = true,
    this.useTwoStageAnalysis = false,
  });

  final String imageUrl;
  final bool saveToHistory;
  final bool isDetailedAnalysis;
  final bool useTwoStageAnalysis;
}

/// Use case for getting location history
class GetLocationHistoryUseCase {
  const GetLocationHistoryUseCase(this._repository);

  final LocationRepository _repository;

  /// Execute getting location history
  Future<List<LocationEntity>> call() async {
    return await _repository.getLocationHistory();
  }
}

/// Use case for getting nearby cameras from location repository
class GetLocationNearbyCamerasUseCase {
  const GetLocationNearbyCamerasUseCase(this._repository);

  final LocationRepository _repository;

  /// Execute getting nearby cameras
  Future<List<LiveCameraEntity>> call(LocationEntity location) async {
    return await _repository.getNearbyCameras(location);
  }
}

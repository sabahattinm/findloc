import 'dart:io';
import 'dart:convert';
import 'package:uuid/uuid.dart';
import '../../domain/entities/location_entity.dart';
import '../../domain/entities/live_camera_entity.dart';
import '../../domain/repositories/location_repository.dart';
import '../datasources/location_remote_datasource.dart';
import '../datasources/location_local_datasource.dart';
import '../models/location_model.dart';
import '../../errors/failures.dart';
import '../../errors/exceptions.dart';
import '../../network/network_info.dart';

/// Implementation of LocationRepository
class LocationRepositoryImpl implements LocationRepository {
  const LocationRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  final LocationRemoteDataSource remoteDataSource;
  final LocationLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  @override
  Future<LocationEntity> detectLocationFromImage(
    File imageFile, {
    bool isDetailedAnalysis = true,
    bool useTwoStageAnalysis = false,
  }) async {
    try {
      // Check network connectivity
      if (!await networkInfo.isConnected) {
        throw const NetworkFailure('İnternet bağlantısı yok');
      }

      // Detect location
      final locationModel = await remoteDataSource.detectLocationFromImage(
        imageFile,
        isDetailedAnalysis: isDetailedAnalysis,
        useTwoStageAnalysis: useTwoStageAnalysis,
      );

      // Cache the result
      await localDataSource.cacheLocation(locationModel);

      return locationModel.toEntity();
    } on AppException catch (e) {
      throw _mapExceptionToFailure(e);
    } catch (e) {
      throw UnknownFailure('Bilinmeyen hata: $e');
    }
  }

  @override
  Future<LocationEntity> detectLocationFromUrl(
    String imageUrl, {
    bool isDetailedAnalysis = true,
    bool useTwoStageAnalysis = false,
  }) async {
    try {
      // Check network connectivity
      if (!await networkInfo.isConnected) {
        throw const NetworkFailure('İnternet bağlantısı yok');
      }

      // Detect location from URL
      final locationModel = await remoteDataSource.detectLocationFromUrl(
        imageUrl,
        isDetailedAnalysis: isDetailedAnalysis,
        useTwoStageAnalysis: useTwoStageAnalysis,
      );

      // Cache the result
      await localDataSource.cacheLocation(locationModel);

      return locationModel.toEntity();
    } on AppException catch (e) {
      throw _mapExceptionToFailure(e);
    } catch (e) {
      throw UnknownFailure('Bilinmeyen hata: $e');
    }
  }

  @override
  Future<List<LocationEntity>> getLocationHistory() async {
    try {
      final locations = await localDataSource.getLocationHistory();
      return locations.map((model) => model.toEntity()).toList();
    } on AppException catch (e) {
      throw _mapExceptionToFailure(e);
    } catch (e) {
      throw UnknownFailure('Bilinmeyen hata: $e');
    }
  }

  @override
  Future<void> saveLocationToHistory(LocationEntity location) async {
    try {
      await localDataSource.saveLocationToHistory(
        LocationModel.fromEntity(location),
      );
    } on AppException catch (e) {
      throw _mapExceptionToFailure(e);
    } catch (e) {
      throw UnknownFailure('Bilinmeyen hata: $e');
    }
  }

  @override
  Future<void> clearLocationHistory() async {
    try {
      await localDataSource.clearLocationHistory();
    } on AppException catch (e) {
      throw _mapExceptionToFailure(e);
    } catch (e) {
      throw UnknownFailure('Bilinmeyen hata: $e');
    }
  }

  @override
  Future<List<LiveCameraEntity>> getNearbyCameras(
      LocationEntity location) async {
    try {
      // This would typically call a camera API service
      // For now, return mock data
      return _getMockCameras(location);
    } catch (e) {
      throw UnknownFailure('Bilinmeyen hata: $e');
    }
  }

  @override
  Future<bool> validateImageFile(File imageFile) async {
    try {
      // Check if file exists
      if (!await imageFile.exists()) {
        return false;
      }

      // Check file size
      final fileSize = await imageFile.length();
      if (fileSize > 5 * 1024 * 1024) {
        // 5MB limit
        return false;
      }

      // Check file extension
      final extension = imageFile.path.split('.').last.toLowerCase();
      const supportedFormats = ['jpg', 'jpeg', 'png', 'webp'];
      if (!supportedFormats.contains(extension)) {
        return false;
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Map exceptions to failures
  Failure _mapExceptionToFailure(AppException exception) {
    if (exception is NetworkException) {
      return NetworkFailure(exception.message);
    } else if (exception is ServerException) {
      return ServerFailure(exception.message);
    } else if (exception is CacheException) {
      return CacheFailure(exception.message);
    } else if (exception is AuthException) {
      return AuthFailure(exception.message);
    } else if (exception is LocationDetectionException) {
      return LocationDetectionFailure(exception.message);
    } else {
      return UnknownFailure(exception.message);
    }
  }

  /// Get mock cameras for testing
  List<LiveCameraEntity> _getMockCameras(LocationEntity location) {
    return [
      LiveCameraEntity(
        id: 'camera_1',
        name: 'Trafik Kamerası - ${location.name}',
        location: location,
        streamUrl: 'https://example.com/stream1',
        isActive: true,
        cameraType: CameraType.traffic,
        description: 'Ana cadde trafik kamerası',
        thumbnailUrl: 'https://example.com/thumb1.jpg',
        resolution: '1920x1080',
        lastUpdated: DateTime.now(),
      ),
      LiveCameraEntity(
        id: 'camera_2',
        name: 'Güvenlik Kamerası - ${location.name}',
        location: location,
        streamUrl: 'https://example.com/stream2',
        isActive: true,
        cameraType: CameraType.security,
        description: 'Güvenlik kamerası',
        thumbnailUrl: 'https://example.com/thumb2.jpg',
        resolution: '1280x720',
        lastUpdated: DateTime.now(),
      ),
    ];
  }
}

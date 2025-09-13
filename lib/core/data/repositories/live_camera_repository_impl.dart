import '../../domain/entities/live_camera_entity.dart';
import '../../domain/entities/location_entity.dart';
import '../../domain/repositories/live_camera_repository.dart';
import '../datasources/live_camera_remote_datasource.dart';
import '../../errors/failures.dart';
import '../../errors/exceptions.dart';

/// Implementation of LiveCameraRepository
class LiveCameraRepositoryImpl implements LiveCameraRepository {
  const LiveCameraRepositoryImpl({
    required this.remoteDataSource,
  });

  final LiveCameraRemoteDataSource remoteDataSource;

  @override
  Future<List<LiveCameraEntity>> getNearbyCameras(LocationEntity location) async {
    try {
      final cameras = await remoteDataSource.getNearbyCameras(location);
      return cameras.map((model) => model.toEntity()).toList();
    } on AppException catch (e) {
      throw _mapExceptionToFailure(e);
    } catch (e) {
      throw UnknownFailure('Yakındaki kameralar alınamadı: $e');
    }
  }

  @override
  Future<List<LiveCameraEntity>> getAllCameras() async {
    try {
      final cameras = await remoteDataSource.getAllCameras();
      return cameras.map((model) => model.toEntity()).toList();
    } on AppException catch (e) {
      throw _mapExceptionToFailure(e);
    } catch (e) {
      throw UnknownFailure('Kameralar alınamadı: $e');
    }
  }

  @override
  Future<LiveCameraEntity?> getCameraById(String cameraId) async {
    try {
      final camera = await remoteDataSource.getCameraById(cameraId);
      return camera?.toEntity();
    } on AppException catch (e) {
      throw _mapExceptionToFailure(e);
    } catch (e) {
      throw UnknownFailure('Kamera bilgisi alınamadı: $e');
    }
  }

  @override
  Future<List<LiveCameraEntity>> getCamerasByType(CameraType type) async {
    try {
      final cameras = await remoteDataSource.getCamerasByType(type);
      return cameras.map((model) => model.toEntity()).toList();
    } on AppException catch (e) {
      throw _mapExceptionToFailure(e);
    } catch (e) {
      throw UnknownFailure('Kamera türüne göre arama başarısız: $e');
    }
  }

  @override
  Future<List<LiveCameraEntity>> searchCameras(String query) async {
    try {
      final cameras = await remoteDataSource.searchCameras(query);
      return cameras.map((model) => model.toEntity()).toList();
    } on AppException catch (e) {
      throw _mapExceptionToFailure(e);
    } catch (e) {
      throw UnknownFailure('Kamera arama başarısız: $e');
    }
  }

  @override
  Future<String> getCameraStreamUrl(String cameraId) async {
    try {
      return await remoteDataSource.getCameraStreamUrl(cameraId);
    } on AppException catch (e) {
      throw _mapExceptionToFailure(e);
    } catch (e) {
      throw UnknownFailure('Kamera stream URL alınamadı: $e');
    }
  }

  @override
  Future<bool> isCameraActive(String cameraId) async {
    try {
      return await remoteDataSource.isCameraActive(cameraId);
    } on AppException catch (e) {
      throw _mapExceptionToFailure(e);
    } catch (e) {
      throw UnknownFailure('Kamera durumu kontrol edilemedi: $e');
    }
  }

  @override
  Future<String?> getCameraThumbnail(String cameraId) async {
    try {
      return await remoteDataSource.getCameraThumbnail(cameraId);
    } on AppException catch (e) {
      throw _mapExceptionToFailure(e);
    } catch (e) {
      throw UnknownFailure('Kamera thumbnail alınamadı: $e');
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
    } else if (exception is CameraException) {
      return CameraFailure(exception.message);
    } else {
      return UnknownFailure(exception.message);
    }
  }
}

import '../entities/live_camera_entity.dart';
import '../entities/location_entity.dart';
import '../repositories/live_camera_repository.dart';

/// Use case for getting nearby live cameras
class GetNearbyCamerasUseCase {
  const GetNearbyCamerasUseCase(this.repository);
  
  final LiveCameraRepository repository;
  
  Future<List<LiveCameraEntity>> call(LocationEntity location) async {
    return await repository.getNearbyCameras(location);
  }
}

/// Use case for getting all available cameras
class GetAllCamerasUseCase {
  const GetAllCamerasUseCase(this.repository);
  
  final LiveCameraRepository repository;
  
  Future<List<LiveCameraEntity>> call() async {
    return await repository.getAllCameras();
  }
}

/// Use case for getting camera by ID
class GetCameraByIdUseCase {
  const GetCameraByIdUseCase(this.repository);
  
  final LiveCameraRepository repository;
  
  Future<LiveCameraEntity?> call(String cameraId) async {
    return await repository.getCameraById(cameraId);
  }
}

/// Use case for getting cameras by type
class GetCamerasByTypeUseCase {
  const GetCamerasByTypeUseCase(this.repository);
  
  final LiveCameraRepository repository;
  
  Future<List<LiveCameraEntity>> call(CameraType type) async {
    return await repository.getCamerasByType(type);
  }
}

/// Use case for searching cameras
class SearchCamerasUseCase {
  const SearchCamerasUseCase(this.repository);
  
  final LiveCameraRepository repository;
  
  Future<List<LiveCameraEntity>> call(String query) async {
    return await repository.searchCameras(query);
  }
}

/// Use case for getting camera stream URL
class GetCameraStreamUrlUseCase {
  const GetCameraStreamUrlUseCase(this.repository);
  
  final LiveCameraRepository repository;
  
  Future<String> call(String cameraId) async {
    return await repository.getCameraStreamUrl(cameraId);
  }
}

/// Use case for checking camera status
class CheckCameraStatusUseCase {
  const CheckCameraStatusUseCase(this.repository);
  
  final LiveCameraRepository repository;
  
  Future<bool> call(String cameraId) async {
    return await repository.isCameraActive(cameraId);
  }
}

/// Use case for getting camera thumbnail
class GetCameraThumbnailUseCase {
  const GetCameraThumbnailUseCase(this.repository);
  
  final LiveCameraRepository repository;
  
  Future<String?> call(String cameraId) async {
    return await repository.getCameraThumbnail(cameraId);
  }
}

import '../models/live_camera_model.dart';
import '../models/location_model.dart';
import '../../domain/entities/location_entity.dart';
import '../../domain/entities/live_camera_entity.dart';
import '../../errors/exceptions.dart';

/// Remote data source for live camera operations
abstract class LiveCameraRemoteDataSource {
  /// Get nearby live cameras for a specific location
  Future<List<LiveCameraModel>> getNearbyCameras(LocationEntity location);
  
  /// Get all available live cameras
  Future<List<LiveCameraModel>> getAllCameras();
  
  /// Get camera by ID
  Future<LiveCameraModel?> getCameraById(String cameraId);
  
  /// Get cameras by type
  Future<List<LiveCameraModel>> getCamerasByType(CameraType type);
  
  /// Search cameras by name or description
  Future<List<LiveCameraModel>> searchCameras(String query);
  
  /// Get camera stream URL
  Future<String> getCameraStreamUrl(String cameraId);
  
  /// Check if camera is currently active
  Future<bool> isCameraActive(String cameraId);
  
  /// Get camera thumbnail
  Future<String?> getCameraThumbnail(String cameraId);
}

/// Implementation of LiveCameraRemoteDataSource
class LiveCameraRemoteDataSourceImpl implements LiveCameraRemoteDataSource {
  const LiveCameraRemoteDataSourceImpl();
  
  @override
  Future<List<LiveCameraModel>> getNearbyCameras(LocationEntity location) async {
    try {
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock data for demonstration
      return _getMockCameras(location);
    } catch (e) {
      throw CameraException('Yakındaki kameralar alınamadı: $e');
    }
  }
  
  @override
  Future<List<LiveCameraModel>> getAllCameras() async {
    try {
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock data for demonstration
      return _getAllMockCameras();
    } catch (e) {
      throw CameraException('Kameralar alınamadı: $e');
    }
  }
  
  @override
  Future<LiveCameraModel?> getCameraById(String cameraId) async {
    try {
      // Simulate API call delay
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Mock data for demonstration
      final cameras = _getAllMockCameras();
      return cameras.firstWhere(
        (camera) => camera.id == cameraId,
        orElse: () => throw CameraException('Kamera bulunamadı'),
      );
    } catch (e) {
      throw CameraException('Kamera bilgisi alınamadı: $e');
    }
  }
  
  @override
  Future<List<LiveCameraModel>> getCamerasByType(CameraType type) async {
    try {
      // Simulate API call delay
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Mock data for demonstration
      final cameras = _getAllMockCameras();
      return cameras.where((camera) => camera.cameraType == type).toList();
    } catch (e) {
      throw CameraException('Kamera türüne göre arama başarısız: $e');
    }
  }
  
  @override
  Future<List<LiveCameraModel>> searchCameras(String query) async {
    try {
      // Simulate API call delay
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Mock data for demonstration
      final cameras = _getAllMockCameras();
      return cameras.where((camera) => 
        camera.name.toLowerCase().contains(query.toLowerCase()) ||
        (camera.description?.toLowerCase().contains(query.toLowerCase()) ?? false)
      ).toList();
    } catch (e) {
      throw CameraException('Kamera arama başarısız: $e');
    }
  }
  
  @override
  Future<String> getCameraStreamUrl(String cameraId) async {
    try {
      // Simulate API call delay
      await Future.delayed(const Duration(milliseconds: 300));
      
      // Mock stream URLs for demonstration
      final streamUrls = {
        'camera_1': 'https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_1mb.mp4',
        'camera_2': 'https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_2mb.mp4',
        'camera_3': 'https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_5mb.mp4',
        'camera_4': 'https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_10mb.mp4',
        'camera_5': 'https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_20mb.mp4',
      };
      
      return streamUrls[cameraId] ?? 'https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_1mb.mp4';
    } catch (e) {
      throw CameraException('Kamera stream URL alınamadı: $e');
    }
  }
  
  @override
  Future<bool> isCameraActive(String cameraId) async {
    try {
      // Simulate API call delay
      await Future.delayed(const Duration(milliseconds: 200));
      
      // Mock active status for demonstration
      final activeCameras = ['camera_1', 'camera_2', 'camera_3'];
      return activeCameras.contains(cameraId);
    } catch (e) {
      throw CameraException('Kamera durumu kontrol edilemedi: $e');
    }
  }
  
  @override
  Future<String?> getCameraThumbnail(String cameraId) async {
    try {
      // Simulate API call delay
      await Future.delayed(const Duration(milliseconds: 300));
      
      // Mock thumbnail URLs for demonstration
      final thumbnailUrls = {
        'camera_1': 'https://picsum.photos/320/240?random=1',
        'camera_2': 'https://picsum.photos/320/240?random=2',
        'camera_3': 'https://picsum.photos/320/240?random=3',
        'camera_4': 'https://picsum.photos/320/240?random=4',
        'camera_5': 'https://picsum.photos/320/240?random=5',
      };
      
      return thumbnailUrls[cameraId];
    } catch (e) {
      throw CameraException('Kamera thumbnail alınamadı: $e');
    }
  }
  
  /// Get mock cameras for a specific location
  List<LiveCameraModel> _getMockCameras(LocationEntity location) {
    final baseLocation = LocationModel.fromEntity(location);
    
    return [
      LiveCameraModel(
        id: 'camera_1',
        name: 'Ana Cadde Trafik Kamerası',
        location: baseLocation,
        streamUrl: 'https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_1mb.mp4',
        isActive: true,
        cameraType: CameraType.traffic,
        description: 'Ana cadde trafik durumu',
        thumbnailUrl: 'https://picsum.photos/320/240?random=1',
        resolution: '1280x720',
        lastUpdated: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
      LiveCameraModel(
        id: 'camera_2',
        name: 'Güvenlik Kamerası - Giriş',
        location: baseLocation,
        streamUrl: 'https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_2mb.mp4',
        isActive: true,
        cameraType: CameraType.security,
        description: 'Ana giriş güvenlik kamerası',
        thumbnailUrl: 'https://picsum.photos/320/240?random=2',
        resolution: '1920x1080',
        lastUpdated: DateTime.now().subtract(const Duration(minutes: 2)),
      ),
      LiveCameraModel(
        id: 'camera_3',
        name: 'Hava Durumu Kamerası',
        location: baseLocation,
        streamUrl: 'https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_5mb.mp4',
        isActive: true,
        cameraType: CameraType.weather,
        description: 'Güncel hava durumu görüntüsü',
        thumbnailUrl: 'https://picsum.photos/320/240?random=3',
        resolution: '1280x720',
        lastUpdated: DateTime.now().subtract(const Duration(minutes: 1)),
      ),
    ];
  }
  
  /// Get all mock cameras
  List<LiveCameraModel> _getAllMockCameras() {
    final mockLocation = LocationModel(
      id: 'mock_location',
      name: 'Örnek Konum',
      address: 'Örnek Adres',
      coordinates: const CoordinatesModel(latitude: 41.0082, longitude: 28.9784),
      confidence: 0.95,
      detectedAt: DateTime.now(),
      description: 'Mock konum',
      city: 'İstanbul',
      country: 'Türkiye',
    );
    
    return [
      LiveCameraModel(
        id: 'camera_1',
        name: 'Ana Cadde Trafik Kamerası',
        location: mockLocation,
        streamUrl: 'https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_1mb.mp4',
        isActive: true,
        cameraType: CameraType.traffic,
        description: 'Ana cadde trafik durumu',
        thumbnailUrl: 'https://picsum.photos/320/240?random=1',
        resolution: '1280x720',
        lastUpdated: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
      LiveCameraModel(
        id: 'camera_2',
        name: 'Güvenlik Kamerası - Giriş',
        location: mockLocation,
        streamUrl: 'https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_2mb.mp4',
        isActive: true,
        cameraType: CameraType.security,
        description: 'Ana giriş güvenlik kamerası',
        thumbnailUrl: 'https://picsum.photos/320/240?random=2',
        resolution: '1920x1080',
        lastUpdated: DateTime.now().subtract(const Duration(minutes: 2)),
      ),
      LiveCameraModel(
        id: 'camera_3',
        name: 'Hava Durumu Kamerası',
        location: mockLocation,
        streamUrl: 'https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_5mb.mp4',
        isActive: true,
        cameraType: CameraType.weather,
        description: 'Güncel hava durumu görüntüsü',
        thumbnailUrl: 'https://picsum.photos/320/240?random=3',
        resolution: '1280x720',
        lastUpdated: DateTime.now().subtract(const Duration(minutes: 1)),
      ),
      LiveCameraModel(
        id: 'camera_4',
        name: 'Turist Kamerası - Merkez',
        location: mockLocation,
        streamUrl: 'https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_10mb.mp4',
        isActive: false,
        cameraType: CameraType.tourist,
        description: 'Şehir merkezi turist kamerası',
        thumbnailUrl: 'https://picsum.photos/320/240?random=4',
        resolution: '1920x1080',
        lastUpdated: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      LiveCameraModel(
        id: 'camera_5',
        name: 'İnşaat Kamerası - Proje',
        location: mockLocation,
        streamUrl: 'https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_20mb.mp4',
        isActive: true,
        cameraType: CameraType.construction,
        description: 'İnşaat projesi takip kamerası',
        thumbnailUrl: 'https://picsum.photos/320/240?random=5',
        resolution: '1280x720',
        lastUpdated: DateTime.now().subtract(const Duration(minutes: 10)),
      ),
    ];
  }
}

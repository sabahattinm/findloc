import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/domain/entities/location_entity.dart';
import '../../../../core/domain/entities/live_camera_entity.dart';
import '../../../../core/domain/usecases/detect_location_usecase.dart';
import '../../../../core/domain/usecases/subscription_usecase.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/camera_api_service.dart';

part 'location_detection_event.dart';
part 'location_detection_state.dart';

/// BLoC for managing location detection functionality
class LocationDetectionBloc
    extends Bloc<LocationDetectionEvent, LocationDetectionState> {
  LocationDetectionBloc({
    required this.detectLocationUseCase,
    required this.detectLocationFromUrlUseCase,
    required this.getLocationHistoryUseCase,
    required this.getLocationNearbyCamerasUseCase,
    required this.useScanUseCase,
    required this.checkScanAvailabilityUseCase,
  }) : super(const LocationDetectionInitial()) {
    on<DetectLocationFromImage>(_onDetectLocationFromImage);
    on<DetectLocationFromUrl>(_onDetectLocationFromUrl);
    on<LoadLocationHistory>(_onLoadLocationHistory);
    on<LoadNearbyCameras>(_onLoadNearbyCameras);
    on<PickImageFromCamera>(_onPickImageFromCamera);
    on<PickImageFromGallery>(_onPickImageFromGallery);
    on<ClearLocationHistory>(_onClearLocationHistory);
    on<ResetState>(_onResetState);
    on<ShowFullResults>(_onShowFullResults);
    on<SearchNearbyCameras>(_onSearchNearbyCameras);
    on<LoadDemoCameras>(_onLoadDemoCameras);
  }

  final DetectLocationUseCase detectLocationUseCase;
  final DetectLocationFromUrlUseCase detectLocationFromUrlUseCase;
  final GetLocationHistoryUseCase getLocationHistoryUseCase;
  final GetLocationNearbyCamerasUseCase getLocationNearbyCamerasUseCase;
  final UseScanUseCase useScanUseCase;
  final CheckScanAvailabilityUseCase checkScanAvailabilityUseCase;

  /// Handle image detection from file
  Future<void> _onDetectLocationFromImage(
    DetectLocationFromImage event,
    Emitter<LocationDetectionState> emit,
  ) async {
    emit(LocationDetectionLoading(imagePath: event.imageFile.path));

    try {
      // Check scan availability first
      final canScan = await checkScanAvailabilityUseCase();
      if (!canScan) {
        emit(const LocationDetectionError(
          'Tarama limitiniz doldu. Premium üyelik satın alın.',
        ));
        return;
      }

      // Use a scan
      await useScanUseCase();

      // Wait for animation to complete (12 seconds for detailed, 8 seconds for quick)
      final animationDuration = event.isDetailedAnalysis ? 12 : 8;
      await Future.delayed(Duration(seconds: animationDuration));

      // Detect location using two-stage analysis for better accuracy
      final location = await detectLocationUseCase(
        DetectLocationParams(
          imageFile: event.imageFile,
          isDetailedAnalysis: event.isDetailedAnalysis,
          useTwoStageAnalysis: true, // Enable two-stage analysis
        ),
      );

      // For first scan, show blurred results
      emit(LocationDetectionBlurred(location: location));
    } on Failure catch (failure) {
      emit(LocationDetectionError(failure.message ?? 'Bir hata oluştu'));
    } catch (e) {
      emit(LocationDetectionError('Beklenmeyen bir hata oluştu: $e'));
    }
  }

  /// Handle URL detection
  Future<void> _onDetectLocationFromUrl(
    DetectLocationFromUrl event,
    Emitter<LocationDetectionState> emit,
  ) async {
    emit(LocationDetectionLoading(imagePath: event.imageUrl));

    try {
      // Check scan availability first
      final canScan = await checkScanAvailabilityUseCase();
      if (!canScan) {
        emit(const LocationDetectionError(
          'Tarama limitiniz doldu. Premium üyelik satın alın.',
        ));
        return;
      }

      // Use a scan
      await useScanUseCase();

      // Wait for animation to complete (12 seconds for detailed, 8 seconds for quick)
      final animationDuration = event.isDetailedAnalysis ? 12 : 8;
      await Future.delayed(Duration(seconds: animationDuration));

      // Detect location from URL using two-stage analysis
      final location = await detectLocationFromUrlUseCase(
        DetectLocationFromUrlParams(
          imageUrl: event.imageUrl,
          isDetailedAnalysis: event.isDetailedAnalysis,
          useTwoStageAnalysis: true, // Enable two-stage analysis
        ),
      );

      // For first scan, show blurred results
      emit(LocationDetectionBlurred(location: location));
    } on Failure catch (failure) {
      emit(LocationDetectionError(failure.message ?? 'Bir hata oluştu'));
    } catch (e) {
      emit(LocationDetectionError('Beklenmeyen bir hata oluştu: $e'));
    }
  }

  /// Handle loading location history
  Future<void> _onLoadLocationHistory(
    LoadLocationHistory event,
    Emitter<LocationDetectionState> emit,
  ) async {
    try {
      final history = await getLocationHistoryUseCase();
      emit(LocationHistoryLoaded(history: history));
    } on Failure catch (failure) {
      emit(LocationDetectionError(failure.message ?? 'Geçmiş yüklenemedi'));
    } catch (e) {
      emit(LocationDetectionError('Beklenmeyen bir hata oluştu: $e'));
    }
  }

  /// Handle loading nearby cameras
  Future<void> _onLoadNearbyCameras(
    LoadNearbyCameras event,
    Emitter<LocationDetectionState> emit,
  ) async {
    emit(const NearbyCamerasLoading());

    try {
      // Try to get real cameras from API first
      final realCameras = await _getRealCameras(event.location);

      if (realCameras.isNotEmpty) {
        emit(NearbyCamerasLoaded(cameras: realCameras));
      } else {
        // Fallback to mock data if no real cameras found
        final mockCameras =
            await getLocationNearbyCamerasUseCase(event.location);
        emit(NearbyCamerasLoaded(cameras: mockCameras));
      }
    } on Failure catch (failure) {
      emit(LocationDetectionError(failure.message ?? 'Kameralar yüklenemedi'));
    } catch (e) {
      emit(LocationDetectionError('Beklenmeyen bir hata oluştu: $e'));
    }
  }

  /// Get real cameras from API
  Future<List<LiveCameraEntity>> _getRealCameras(
      LocationEntity location) async {
    try {
      final cameraData = await CameraApiService.getNearbyCameras(
        latitude: location.coordinates.latitude,
        longitude: location.coordinates.longitude,
        radiusKm: 10.0,
      );

      // Convert API data to entities
      final List<LiveCameraEntity> cameras = [];
      for (final data in cameraData) {
        cameras.add(LiveCameraEntity(
          id: data['id'] ?? '',
          name: data['name'] ?? '',
          location: LocationEntity(
            id: 'camera_${data['id']}',
            name: data['name'] ?? '',
            address: '${data['city'] ?? ''}, ${data['country'] ?? ''}',
            coordinates: Coordinates(
              latitude: data['latitude'] ?? 0.0,
              longitude: data['longitude'] ?? 0.0,
            ),
            confidence: 0.9,
            detectedAt: DateTime.now(),
            city: data['city'] ?? '',
            country: data['country'] ?? '',
          ),
          streamUrl: data['url'] ?? '',
          isActive: data['status'] == 'active',
          cameraType: _getCameraTypeFromString(data['type'] ?? 'other'),
          description: data['description'] ?? '',
          thumbnailUrl: data['thumbnail'],
          resolution: data['resolution'],
        ));
      }

      return cameras;
    } catch (e) {
      return [];
    }
  }

  /// Convert string to CameraType enum
  CameraType _getCameraTypeFromString(String type) {
    switch (type.toLowerCase()) {
      case 'traffic':
        return CameraType.traffic;
      case 'security':
        return CameraType.security;
      case 'tourist':
        return CameraType.tourist;
      case 'webcam':
        return CameraType.webcam;
      default:
        return CameraType.other;
    }
  }

  /// Handle picking image from camera
  Future<void> _onPickImageFromCamera(
    PickImageFromCamera event,
    Emitter<LocationDetectionState> emit,
  ) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 4096,
        maxHeight: 4096,
        imageQuality: 95,
      );

      if (image != null) {
        final file = File(image.path);
        add(DetectLocationFromImage(imageFile: file, isDetailedAnalysis: true));
      }
    } catch (e) {
      emit(LocationDetectionError('Kamera erişimi başarısız: $e'));
    }
  }

  /// Handle picking image from gallery
  Future<void> _onPickImageFromGallery(
    PickImageFromGallery event,
    Emitter<LocationDetectionState> emit,
  ) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 4096,
        maxHeight: 4096,
        imageQuality: 95,
      );

      if (image != null) {
        final file = File(image.path);
        add(DetectLocationFromImage(imageFile: file, isDetailedAnalysis: true));
      }
    } catch (e) {
      emit(LocationDetectionError('Galeri erişimi başarısız: $e'));
    }
  }

  /// Handle clearing location history
  Future<void> _onClearLocationHistory(
    ClearLocationHistory event,
    Emitter<LocationDetectionState> emit,
  ) async {
    try {
      // This would call a clear history use case
      emit(const LocationHistoryCleared());
    } catch (e) {
      emit(LocationDetectionError('Geçmiş temizlenemedi: $e'));
    }
  }

  /// Handle resetting state
  void _onResetState(
    ResetState event,
    Emitter<LocationDetectionState> emit,
  ) {
    emit(const LocationDetectionInitial());
  }

  /// Handle showing full results (for testing)
  void _onShowFullResults(
    ShowFullResults event,
    Emitter<LocationDetectionState> emit,
  ) {
    emit(LocationDetectionSuccess(location: event.location));
  }

  /// Handle searching nearby cameras using current location
  Future<void> _onSearchNearbyCameras(
    SearchNearbyCameras event,
    Emitter<LocationDetectionState> emit,
  ) async {
    try {
      emit(const NearbyCamerasLoading());

      // Demo kameraları yükle (gerçek konum servisi yerine)
      await Future.delayed(const Duration(seconds: 2));

      final demoCameras = _getDemoCameras();
      emit(NearbyCamerasLoaded(cameras: demoCameras));
    } catch (e) {
      emit(LocationDetectionError('Kamera arama başarısız: $e'));
    }
  }

  /// Handle loading demo cameras
  Future<void> _onLoadDemoCameras(
    LoadDemoCameras event,
    Emitter<LocationDetectionState> emit,
  ) async {
    try {
      emit(const NearbyCamerasLoading());

      // Demo kameraları yükle
      await Future.delayed(const Duration(seconds: 1));

      final demoCameras = _getDemoCameras();
      emit(NearbyCamerasLoaded(cameras: demoCameras));
    } catch (e) {
      emit(LocationDetectionError('Demo kameralar yüklenemedi: $e'));
    }
  }

  /// Demo kameraları oluştur
  List<LiveCameraEntity> _getDemoCameras() {
    return [
      LiveCameraEntity(
        id: 'demo_camera_1',
        name: 'İstanbul Boğazı Kamerası',
        location: LocationEntity(
          id: 'location_1',
          name: 'İstanbul Boğazı',
          address: 'İstanbul Boğazı, İstanbul, Türkiye',
          coordinates: Coordinates(latitude: 41.0082, longitude: 28.9784),
          confidence: 0.95,
          detectedAt: DateTime.now(),
          city: 'İstanbul',
          country: 'Türkiye',
        ),
        streamUrl: 'https://demo.stream.url/istanbul',
        isActive: true,
        cameraType: CameraType.tourist,
        description: 'İstanbul Boğazı manzarası',
        resolution: '1920x1080',
      ),
      LiveCameraEntity(
        id: 'demo_camera_2',
        name: 'Ankara Kızılay Trafik Kamerası',
        location: LocationEntity(
          id: 'location_2',
          name: 'Kızılay Meydanı',
          address: 'Kızılay Meydanı, Ankara, Türkiye',
          coordinates: Coordinates(latitude: 39.9208, longitude: 32.8541),
          confidence: 0.90,
          detectedAt: DateTime.now(),
          city: 'Ankara',
          country: 'Türkiye',
        ),
        streamUrl: 'https://demo.stream.url/ankara',
        isActive: true,
        cameraType: CameraType.traffic,
        description: 'Kızılay trafik durumu',
        resolution: '1280x720',
      ),
      LiveCameraEntity(
        id: 'demo_camera_3',
        name: 'İzmir Konak Meydanı',
        location: LocationEntity(
          id: 'location_3',
          name: 'Konak Meydanı',
          address: 'Konak Meydanı, İzmir, Türkiye',
          coordinates: Coordinates(latitude: 38.4192, longitude: 27.1287),
          confidence: 0.85,
          detectedAt: DateTime.now(),
          city: 'İzmir',
          country: 'Türkiye',
        ),
        streamUrl: 'https://demo.stream.url/izmir',
        isActive: false,
        cameraType: CameraType.security,
        description: 'Konak Meydanı güvenlik kamerası',
        resolution: '1920x1080',
      ),
    ];
  }
}

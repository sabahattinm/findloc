import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/domain/entities/live_camera_entity.dart';
import '../../../../core/domain/entities/location_entity.dart';
import '../../../../core/domain/usecases/live_camera_usecase.dart';
import '../../../../core/errors/failures.dart';

part 'live_camera_event.dart';
part 'live_camera_state.dart';

/// BLoC for managing live camera functionality
class LiveCameraBloc extends Bloc<LiveCameraEvent, LiveCameraState> {
  LiveCameraBloc({
    required this.getNearbyCamerasUseCase,
    required this.getAllCamerasUseCase,
    required this.getCameraByIdUseCase,
    required this.getCamerasByTypeUseCase,
    required this.searchCamerasUseCase,
    required this.getCameraStreamUrlUseCase,
    required this.checkCameraStatusUseCase,
    required this.getCameraThumbnailUseCase,
  }) : super(const LiveCameraInitial()) {
    on<LoadNearbyCameras>(_onLoadNearbyCameras);
    on<LoadAllCameras>(_onLoadAllCameras);
    on<LoadCameraById>(_onLoadCameraById);
    on<LoadCamerasByType>(_onLoadCamerasByType);
    on<SearchCameras>(_onSearchCameras);
    on<LoadCameraStream>(_onLoadCameraStream);
    on<CheckCameraStatus>(_onCheckCameraStatus);
    on<LoadCameraThumbnail>(_onLoadCameraThumbnail);
    on<ResetState>(_onResetState);
  }

  final GetNearbyCamerasUseCase getNearbyCamerasUseCase;
  final GetAllCamerasUseCase getAllCamerasUseCase;
  final GetCameraByIdUseCase getCameraByIdUseCase;
  final GetCamerasByTypeUseCase getCamerasByTypeUseCase;
  final SearchCamerasUseCase searchCamerasUseCase;
  final GetCameraStreamUrlUseCase getCameraStreamUrlUseCase;
  final CheckCameraStatusUseCase checkCameraStatusUseCase;
  final GetCameraThumbnailUseCase getCameraThumbnailUseCase;

  /// Handle loading nearby cameras
  Future<void> _onLoadNearbyCameras(
    LoadNearbyCameras event,
    Emitter<LiveCameraState> emit,
  ) async {
    emit(const LiveCameraLoading());

    try {
      final cameras = await getNearbyCamerasUseCase(event.location);
      emit(LiveCameraLoaded(cameras: cameras));
    } on Failure catch (failure) {
      emit(LiveCameraError(failure.message ?? 'Yakındaki kameralar yüklenemedi'));
    } catch (e) {
      emit(LiveCameraError('Beklenmeyen bir hata oluştu: $e'));
    }
  }

  /// Handle loading all cameras
  Future<void> _onLoadAllCameras(
    LoadAllCameras event,
    Emitter<LiveCameraState> emit,
  ) async {
    emit(const LiveCameraLoading());

    try {
      final cameras = await getAllCamerasUseCase();
      emit(LiveCameraLoaded(cameras: cameras));
    } on Failure catch (failure) {
      emit(LiveCameraError(failure.message ?? 'Kameralar yüklenemedi'));
    } catch (e) {
      emit(LiveCameraError('Beklenmeyen bir hata oluştu: $e'));
    }
  }

  /// Handle loading camera by ID
  Future<void> _onLoadCameraById(
    LoadCameraById event,
    Emitter<LiveCameraState> emit,
  ) async {
    emit(const LiveCameraLoading());

    try {
      final camera = await getCameraByIdUseCase(event.cameraId);
      if (camera != null) {
        emit(LiveCameraLoaded(cameras: [camera]));
      } else {
        emit(const LiveCameraError('Kamera bulunamadı'));
      }
    } on Failure catch (failure) {
      emit(LiveCameraError(failure.message ?? 'Kamera bilgisi alınamadı'));
    } catch (e) {
      emit(LiveCameraError('Beklenmeyen bir hata oluştu: $e'));
    }
  }

  /// Handle loading cameras by type
  Future<void> _onLoadCamerasByType(
    LoadCamerasByType event,
    Emitter<LiveCameraState> emit,
  ) async {
    emit(const LiveCameraLoading());

    try {
      final cameras = await getCamerasByTypeUseCase(event.type);
      emit(LiveCameraLoaded(cameras: cameras));
    } on Failure catch (failure) {
      emit(LiveCameraError(failure.message ?? 'Kamera türüne göre arama başarısız'));
    } catch (e) {
      emit(LiveCameraError('Beklenmeyen bir hata oluştu: $e'));
    }
  }

  /// Handle searching cameras
  Future<void> _onSearchCameras(
    SearchCameras event,
    Emitter<LiveCameraState> emit,
  ) async {
    emit(const LiveCameraLoading());

    try {
      final cameras = await searchCamerasUseCase(event.query);
      emit(LiveCameraLoaded(cameras: cameras));
    } on Failure catch (failure) {
      emit(LiveCameraError(failure.message ?? 'Kamera arama başarısız'));
    } catch (e) {
      emit(LiveCameraError('Beklenmeyen bir hata oluştu: $e'));
    }
  }

  /// Handle loading camera stream
  Future<void> _onLoadCameraStream(
    LoadCameraStream event,
    Emitter<LiveCameraState> emit,
  ) async {
    emit(const LiveCameraLoading());

    try {
      final streamUrl = await getCameraStreamUrlUseCase(event.cameraId);
      emit(LiveCameraStreamLoaded(streamUrl: streamUrl));
    } on Failure catch (failure) {
      emit(LiveCameraError(failure.message ?? 'Kamera stream yüklenemedi'));
    } catch (e) {
      emit(LiveCameraError('Beklenmeyen bir hata oluştu: $e'));
    }
  }

  /// Handle checking camera status
  Future<void> _onCheckCameraStatus(
    CheckCameraStatus event,
    Emitter<LiveCameraState> emit,
  ) async {
    try {
      final isActive = await checkCameraStatusUseCase(event.cameraId);
      emit(LiveCameraStatusChecked(isActive: isActive));
    } on Failure catch (failure) {
      emit(LiveCameraError(failure.message ?? 'Kamera durumu kontrol edilemedi'));
    } catch (e) {
      emit(LiveCameraError('Beklenmeyen bir hata oluştu: $e'));
    }
  }

  /// Handle loading camera thumbnail
  Future<void> _onLoadCameraThumbnail(
    LoadCameraThumbnail event,
    Emitter<LiveCameraState> emit,
  ) async {
    try {
      final thumbnailUrl = await getCameraThumbnailUseCase(event.cameraId);
      emit(LiveCameraThumbnailLoaded(thumbnailUrl: thumbnailUrl));
    } on Failure catch (failure) {
      emit(LiveCameraError(failure.message ?? 'Kamera thumbnail yüklenemedi'));
    } catch (e) {
      emit(LiveCameraError('Beklenmeyen bir hata oluştu: $e'));
    }
  }

  /// Handle resetting state
  void _onResetState(
    ResetState event,
    Emitter<LiveCameraState> emit,
  ) {
    emit(const LiveCameraInitial());
  }
}

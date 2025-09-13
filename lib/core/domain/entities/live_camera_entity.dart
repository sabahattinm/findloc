import 'location_entity.dart';

/// Entity representing a live camera feed
class LiveCameraEntity {
  const LiveCameraEntity({
    required this.id,
    required this.name,
    required this.location,
    required this.streamUrl,
    required this.isActive,
    required this.cameraType,
    this.description,
    this.thumbnailUrl,
    this.resolution,
    this.lastUpdated,
  });

  final String id;
  final String name;
  final LocationEntity location;
  final String streamUrl;
  final bool isActive;
  final CameraType cameraType;
  final String? description;
  final String? thumbnailUrl;
  final String? resolution;
  final DateTime? lastUpdated;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LiveCameraEntity &&
        other.id == id &&
        other.name == name &&
        other.location == location &&
        other.streamUrl == streamUrl &&
        other.isActive == isActive &&
        other.cameraType == cameraType &&
        other.description == description &&
        other.thumbnailUrl == thumbnailUrl &&
        other.resolution == resolution &&
        other.lastUpdated == lastUpdated;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      name,
      location,
      streamUrl,
      isActive,
      cameraType,
      description,
      thumbnailUrl,
      resolution,
      lastUpdated,
    );
  }
}

/// Enum representing different camera types
enum CameraType { traffic, security, weather, tourist, construction, webcam, other }

/// Extension for camera type details
extension CameraTypeExtension on CameraType {
  String get displayName {
    switch (this) {
      case CameraType.traffic:
        return 'Trafik Kamerası';
      case CameraType.security:
        return 'Güvenlik Kamerası';
      case CameraType.weather:
        return 'Hava Durumu Kamerası';
      case CameraType.tourist:
        return 'Turist Kamerası';
      case CameraType.construction:
        return 'İnşaat Kamerası';
      case CameraType.webcam:
        return 'Web Kamerası';
      case CameraType.other:
        return 'Diğer';
    }
  }

  String get icon {
    switch (this) {
      case CameraType.traffic:
        return '🚦';
      case CameraType.security:
        return '🔒';
      case CameraType.weather:
        return '🌤️';
      case CameraType.tourist:
        return '📸';
      case CameraType.construction:
        return '🏗️';
      case CameraType.webcam:
        return '📹';
      case CameraType.other:
        return '📹';
    }
  }
}
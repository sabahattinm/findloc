import '../../domain/entities/live_camera_entity.dart';
import 'location_model.dart';

/// Data model for live camera information
class LiveCameraModel {
  const LiveCameraModel({
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
  final LocationModel location;
  final String streamUrl;
  final bool isActive;
  final CameraType cameraType;
  final String? description;
  final String? thumbnailUrl;
  final String? resolution;
  final DateTime? lastUpdated;
  
  /// Create LiveCameraModel from JSON
  factory LiveCameraModel.fromJson(Map<String, dynamic> json) {
    return LiveCameraModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      location: LocationModel.fromJson(json['location'] ?? {}),
      streamUrl: json['streamUrl'] ?? '',
      isActive: json['isActive'] ?? false,
      cameraType: CameraType.values.firstWhere(
        (e) => e.name == json['cameraType'],
        orElse: () => CameraType.other,
      ),
      description: json['description'],
      thumbnailUrl: json['thumbnailUrl'],
      resolution: json['resolution'],
      lastUpdated: json['lastUpdated'] != null 
          ? DateTime.parse(json['lastUpdated'])
          : null,
    );
  }
  
  /// Convert LiveCameraModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'location': location.toJson(),
      'streamUrl': streamUrl,
      'isActive': isActive,
      'cameraType': cameraType.name,
      'description': description,
      'thumbnailUrl': thumbnailUrl,
      'resolution': resolution,
      'lastUpdated': lastUpdated?.toIso8601String(),
    };
  }
  
  /// Create LiveCameraModel from entity
  factory LiveCameraModel.fromEntity(LiveCameraEntity entity) {
    return LiveCameraModel(
      id: entity.id,
      name: entity.name,
      location: LocationModel.fromEntity(entity.location),
      streamUrl: entity.streamUrl,
      isActive: entity.isActive,
      cameraType: entity.cameraType,
      description: entity.description,
      thumbnailUrl: entity.thumbnailUrl,
      resolution: entity.resolution,
      lastUpdated: entity.lastUpdated,
    );
  }
  
  /// Convert to entity
  LiveCameraEntity toEntity() {
    return LiveCameraEntity(
      id: id,
      name: name,
      location: location.toEntity(),
      streamUrl: streamUrl,
      isActive: isActive,
      cameraType: cameraType,
      description: description,
      thumbnailUrl: thumbnailUrl,
      resolution: resolution,
      lastUpdated: lastUpdated,
    );
  }
}
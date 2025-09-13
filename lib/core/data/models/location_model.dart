import '../../domain/entities/location_entity.dart';

/// Data model for location information
class LocationModel {
  const LocationModel({
    required this.id,
    required this.name,
    required this.address,
    required this.coordinates,
    required this.confidence,
    required this.detectedAt,
    this.description,
    this.landmarks,
    this.city,
    this.country,
    this.postalCode,
    this.region,
    this.accuracy,
    // Yol kesişimi analizi için yeni alanlar
    this.roadType,
    this.roadStructure,
    this.roadWidth,
    this.intersectionType,
    this.trafficSigns,
    this.roadMarkings,
    this.directionSigns,
    this.trafficDensity,
    this.roadCondition,
    this.nearbyBuildings,
    this.streetFurniture,
    this.lighting,
    this.vegetation,
  });

  final String id;
  final String name;
  final String address;
  final CoordinatesModel coordinates;
  final double confidence;
  final DateTime detectedAt;
  final String? description;
  final List<String>? landmarks;
  final String? city;
  final String? country;
  final String? postalCode;
  final String? region;
  final double? accuracy;

  // Yol kesişimi analizi için yeni alanlar
  final String? roadType;
  final String? roadStructure;
  final String? roadWidth;
  final String? intersectionType;
  final String? trafficSigns;
  final String? roadMarkings;
  final String? directionSigns;
  final String? trafficDensity;
  final String? roadCondition;
  final String? nearbyBuildings;
  final String? streetFurniture;
  final String? lighting;
  final String? vegetation;

  /// Create LocationModel from JSON
  factory LocationModel.fromJson(Map<String, dynamic> json) {
    // Generate unique ID if not provided
    final id = json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString();

    // Parse coordinates with fallback
    Map<String, dynamic> coords = json['coordinates'] ?? {};
    if (coords.isEmpty) {
      coords = {'latitude': 0.0, 'longitude': 0.0};
    }

    // Parse detectedAt with fallback
    DateTime detectedAt;
    try {
      detectedAt = DateTime.parse(
          json['detectedAt'] ?? DateTime.now().toIso8601String());
    } catch (e) {
      detectedAt = DateTime.now();
    }

    return LocationModel(
      id: id,
      name: json['name'] ?? json['locationName'] ?? 'Bilinmeyen Konum',
      address: json['address'] ??
          json['description'] ??
          'Adres bilgisi mevcut değil',
      coordinates: CoordinatesModel.fromJson(coords),
      confidence: (json['confidence'] ?? 0.0).toDouble(),
      detectedAt: detectedAt,
      description: json['description'] ??
          json['name'] ??
          'Konum açıklaması mevcut değil',
      landmarks: json['landmarks']?.cast<String>() ??
          json['nearbyLandmarks']?.cast<String>(),
      city: json['city'] ?? 'Bilinmeyen Şehir',
      country: json['country'] ?? 'Bilinmeyen Ülke',
      postalCode: json['postalCode'],
      region: json['region'],
      accuracy: (json['accuracy'] ?? 0.0).toDouble(),
      // Yol kesişimi analizi için yeni alanlar
      roadType: json['roadType'],
      roadStructure: json['roadStructure'],
      roadWidth: json['roadWidth'],
      intersectionType: json['intersectionType'],
      trafficSigns: json['trafficSigns'],
      roadMarkings: json['roadMarkings'],
      directionSigns: json['directionSigns'],
      trafficDensity: json['trafficDensity'],
      roadCondition: json['roadCondition'],
      nearbyBuildings: json['nearbyBuildings'],
      streetFurniture: json['streetFurniture'],
      lighting: json['lighting'],
      vegetation: json['vegetation'],
    );
  }

  /// Convert LocationModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'coordinates': coordinates.toJson(),
      'confidence': confidence,
      'detectedAt': detectedAt.toIso8601String(),
      'description': description,
      'landmarks': landmarks,
      'city': city,
      'country': country,
      'postalCode': postalCode,
      'region': region,
      'accuracy': accuracy,
    };
  }

  /// Create LocationModel from entity
  factory LocationModel.fromEntity(LocationEntity entity) {
    return LocationModel(
      id: entity.id,
      name: entity.name,
      address: entity.address,
      coordinates: CoordinatesModel.fromEntity(entity.coordinates),
      confidence: entity.confidence,
      detectedAt: entity.detectedAt,
      description: entity.description,
      landmarks: entity.landmarks,
      city: entity.city,
      country: entity.country,
      postalCode: entity.postalCode,
      region: entity.region,
      accuracy: entity.accuracy,
    );
  }

  /// Convert to entity
  LocationEntity toEntity() {
    return LocationEntity(
      id: id,
      name: name,
      address: address,
      coordinates: coordinates.toEntity(),
      confidence: confidence,
      detectedAt: detectedAt,
      description: description,
      landmarks: landmarks,
      city: city,
      country: country,
      postalCode: postalCode,
      region: region,
      accuracy: accuracy,
    );
  }
}

/// Data model for coordinates
class CoordinatesModel {
  const CoordinatesModel({required this.latitude, required this.longitude});

  final double latitude;
  final double longitude;

  /// Create CoordinatesModel from JSON
  factory CoordinatesModel.fromJson(Map<String, dynamic> json) {
    return CoordinatesModel(
      latitude: (json['latitude'] ?? json['lat'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? json['lng'] ?? 0.0).toDouble(),
    );
  }

  /// Convert CoordinatesModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  /// Create CoordinatesModel from entity
  factory CoordinatesModel.fromEntity(Coordinates entity) {
    return CoordinatesModel(
      latitude: entity.latitude,
      longitude: entity.longitude,
    );
  }

  /// Convert to entity
  Coordinates toEntity() {
    return Coordinates(latitude: latitude, longitude: longitude);
  }
}

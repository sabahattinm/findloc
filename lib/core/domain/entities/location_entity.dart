/// Entity representing a detected location from image analysis
class LocationEntity {
  const LocationEntity({
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
  });

  final String id;
  final String name;
  final String address;
  final Coordinates coordinates;
  final double confidence; // 0.0 to 1.0
  final DateTime detectedAt;
  final String? description;
  final List<String>? landmarks;
  final String? city;
  final String? country;
  final String? postalCode;
  final String? region;
  final double? accuracy; // in meters

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LocationEntity &&
        other.id == id &&
        other.name == name &&
        other.address == address &&
        other.coordinates == coordinates &&
        other.confidence == confidence &&
        other.detectedAt == detectedAt &&
        other.description == description &&
        other.landmarks == landmarks &&
        other.city == city &&
        other.country == country &&
        other.postalCode == postalCode &&
        other.region == region &&
        other.accuracy == accuracy;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      name,
      address,
      coordinates,
      confidence,
      detectedAt,
      description,
      landmarks,
      city,
      country,
      postalCode,
      region,
      accuracy,
    );
  }
}

/// Entity representing geographical coordinates
class Coordinates {
  const Coordinates({required this.latitude, required this.longitude});

  final double latitude;
  final double longitude;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Coordinates &&
        other.latitude == latitude &&
        other.longitude == longitude;
  }

  @override
  int get hashCode => Object.hash(latitude, longitude);
}
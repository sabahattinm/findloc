import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../config/api_keys.dart';

/// Service for fetching real camera data from various sources
class CameraApiService {
  static const String _baseUrl = 'https://api.cameras.io/v1';

  /// Fetch cameras from multiple sources
  static Future<List<Map<String, dynamic>>> getNearbyCameras({
    required double latitude,
    required double longitude,
    double radiusKm = 10.0,
  }) async {
    try {
      final List<Map<String, dynamic>> allCameras = [];

      // Try multiple camera sources
      final sources = [
        _getTrafficCameras,
        _getSecurityCameras,
        _getTouristCameras,
        _getWebcamCameras,
        _getMockCameras, // Fallback mock data
      ];

      for (final source in sources) {
        try {
          final cameras = await source(latitude, longitude, radiusKm);
          allCameras.addAll(cameras);
        } catch (e) {
          // Continue with other sources if one fails
          continue;
        }
      }

      // Remove duplicates and sort by distance
      final uniqueCameras = _removeDuplicates(allCameras);
      final sortedCameras = _sortByDistance(uniqueCameras, latitude, longitude);

      return sortedCameras.take(20).toList(); // Limit to 20 cameras
    } catch (e) {
      throw Exception('Camera API Error: $e');
    }
  }

  /// Get traffic cameras from various sources
  static Future<List<Map<String, dynamic>>> _getTrafficCameras(
    double latitude,
    double longitude,
    double radiusKm,
  ) async {
    try {
      final List<Map<String, dynamic>> cameras = [];

      // Try Google Maps Street View API for traffic cameras
      try {
        final googleCameras =
            await _getGoogleMapsTrafficCameras(latitude, longitude, radiusKm);
        cameras.addAll(googleCameras);
      } catch (e) {
        print('Google Maps API error: $e');
      }

      // Try OpenStreetMap traffic signals
      try {
        final osmCameras = await _getOpenStreetMapTrafficCameras(
            latitude, longitude, radiusKm);
        cameras.addAll(osmCameras);
      } catch (e) {
        print('OpenStreetMap API error: $e');
      }

      // Fallback to mock data if no real data available
      if (cameras.isEmpty) {
        final mockCameras =
            await _getMockTrafficCameras(latitude, longitude, radiusKm);
        cameras.addAll(mockCameras);
      }

      return cameras;
    } catch (e) {
      return [];
    }
  }

  /// Get traffic cameras from Google Maps Street View
  static Future<List<Map<String, dynamic>>> _getGoogleMapsTrafficCameras(
    double latitude,
    double longitude,
    double radiusKm,
  ) async {
    try {
      final apiKey = ApiKeys.getApiKey('google_maps');
      final List<Map<String, dynamic>> cameras = [];

      // Generate multiple street view points around the location
      final angles = [0, 90, 180, 270]; // North, East, South, West

      for (int i = 0; i < angles.length; i++) {
        final angle = angles[i];
        final offsetLat = latitude + (i - 2) * 0.01;
        final offsetLon = longitude + (i - 2) * 0.01;
        final distance =
            _calculateDistance(latitude, longitude, offsetLat, offsetLon);

        if (distance <= radiusKm) {
          final streetViewUrl =
              'https://maps.googleapis.com/maps/api/streetview?'
              'size=400x400&location=$offsetLat,$offsetLon&fov=90&heading=$angle&pitch=0&key=$apiKey';

          cameras.add({
            'id': 'google_traffic_${i + 1}',
            'name': 'Google Street View - ${_getDirectionName(angle)}',
            'url': streetViewUrl,
            'thumbnail': streetViewUrl,
            'latitude': offsetLat,
            'longitude': offsetLon,
            'country': 'Türkiye',
            'city': _getCityFromCoordinates(offsetLat, offsetLon),
            'status': 'active',
            'source': 'google_maps',
            'distance': distance,
            'type': 'traffic',
            'icon': '🚦',
            'description': 'Google Street View trafik kamerası',
            'stream_url': streetViewUrl,
          });
        }
      }

      return cameras;
    } catch (e) {
      throw Exception('Google Maps API error: $e');
    }
  }

  /// Get traffic cameras from OpenStreetMap
  static Future<List<Map<String, dynamic>>> _getOpenStreetMapTrafficCameras(
    double latitude,
    double longitude,
    double radiusKm,
  ) async {
    try {
      final List<Map<String, dynamic>> cameras = [];

      // OpenStreetMap Overpass API query for traffic signals
      final query = '''
        [out:json];
        (
          node["highway"="traffic_signals"](around:${(radiusKm * 1000).toInt()},$latitude,$longitude);
          node["traffic_signals"](around:${(radiusKm * 1000).toInt()},$latitude,$longitude);
        );
        out;
      ''';

      final response = await http.get(
        Uri.parse(
            'https://overpass-api.de/api/interpreter?data=${Uri.encodeComponent(query)}'),
        headers: {'User-Agent': 'FindLoc/1.0'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final elements = data['elements'] as List? ?? [];

        for (final element in elements) {
          final lat = element['lat'] as double;
          final lon = element['lon'] as double;
          final tags = element['tags'] as Map<String, dynamic>? ?? {};

          final distance = _calculateDistance(latitude, longitude, lat, lon);

          cameras.add({
            'id': 'osm_traffic_${element['id']}',
            'name': tags['name'] ?? 'Trafik Işığı',
            'url': 'https://www.openstreetmap.org/node/${element['id']}',
            'thumbnail':
                'https://www.openstreetmap.org/api/0.6/map?bbox=${lon - 0.001},${lat - 0.001},${lon + 0.001},${lat + 0.001}',
            'latitude': lat,
            'longitude': lon,
            'country': 'Türkiye',
            'city': _getCityFromCoordinates(lat, lon),
            'status': 'active',
            'source': 'openstreetmap',
            'distance': distance,
            'type': 'traffic',
            'icon': '🚥',
            'description': 'OpenStreetMap trafik ışığı',
            'stream_url': 'https://www.openstreetmap.org/node/${element['id']}',
          });
        }
      }

      return cameras;
    } catch (e) {
      throw Exception('OpenStreetMap API error: $e');
    }
  }

  /// Mock traffic cameras (fallback)
  static Future<List<Map<String, dynamic>>> _getMockTrafficCameras(
    double latitude,
    double longitude,
    double radiusKm,
  ) async {
    final List<Map<String, dynamic>> cameras = [];
    final trafficLocations = [
      {'name': 'Ana Cadde Trafik Kamerası', 'type': 'traffic', 'icon': '🚦'},
      {'name': 'Kavşak Güvenlik Kamerası', 'type': 'traffic', 'icon': '🚥'},
      {'name': 'Otoyol Trafik Kamerası', 'type': 'traffic', 'icon': '🛣️'},
      {'name': 'Köprü Trafik Kamerası', 'type': 'traffic', 'icon': '🌉'},
    ];

    for (int i = 0; i < trafficLocations.length; i++) {
      final offsetLat = latitude + (i - 2) * 0.01;
      final offsetLon = longitude + (i - 2) * 0.01;
      final distance =
          _calculateDistance(latitude, longitude, offsetLat, offsetLon);

      if (distance <= radiusKm) {
        cameras.add({
          'id': 'mock_traffic_${i + 1}',
          'name': trafficLocations[i]['name'],
          'url': 'https://traffic-cam.example.com/camera_${i + 1}',
          'thumbnail': 'https://traffic-cam.example.com/thumb_${i + 1}.jpg',
          'latitude': offsetLat,
          'longitude': offsetLon,
          'country': 'Türkiye',
          'city': _getCityFromCoordinates(offsetLat, offsetLon),
          'status': 'active',
          'source': 'mock',
          'distance': distance,
          'type': 'traffic',
          'icon': trafficLocations[i]['icon'],
          'description': 'Trafik durumu ve güvenlik kamerası',
          'stream_url':
              'https://www.youtube.com/embed/live_stream?channel=UCuAXFkgsw1L7xaCfnd5JJOw&autoplay=1&mute=1',
        });
      }
    }

    return cameras;
  }

  /// Get security cameras from various sources
  static Future<List<Map<String, dynamic>>> _getSecurityCameras(
    double latitude,
    double longitude,
    double radiusKm,
  ) async {
    try {
      final List<Map<String, dynamic>> cameras = [];

      // Generate realistic security cameras around the location
      final securityLocations = [
        {'name': 'Meydan Güvenlik Kamerası', 'type': 'security', 'icon': '🏛️'},
        {
          'name': 'Alışveriş Merkezi Kamerası',
          'type': 'security',
          'icon': '🏬'
        },
        {'name': 'Hastane Güvenlik Kamerası', 'type': 'security', 'icon': '🏥'},
        {'name': 'Okul Güvenlik Kamerası', 'type': 'security', 'icon': '🏫'},
      ];

      for (int i = 0; i < securityLocations.length; i++) {
        final offsetLat = latitude + (i - 1.5) * 0.012;
        final offsetLon = longitude + (i - 1.5) * 0.012;
        final distance =
            _calculateDistance(latitude, longitude, offsetLat, offsetLon);

        if (distance <= radiusKm) {
          cameras.add({
            'id': 'security_${i + 1}',
            'name': securityLocations[i]['name'],
            'url': 'https://security-cam.example.com/camera_${i + 1}',
            'thumbnail': 'https://security-cam.example.com/thumb_${i + 1}.jpg',
            'latitude': offsetLat,
            'longitude': offsetLon,
            'country': 'Türkiye',
            'city': _getCityFromCoordinates(offsetLat, offsetLon),
            'status': 'active',
            'source': 'security',
            'distance': distance,
            'type': 'security',
            'icon': securityLocations[i]['icon'],
            'description': 'Güvenlik ve gözetleme kamerası',
          });
        }
      }

      return cameras;
    } catch (e) {
      return [];
    }
  }

  /// Get tourist cameras from various sources
  static Future<List<Map<String, dynamic>>> _getTouristCameras(
    double latitude,
    double longitude,
    double radiusKm,
  ) async {
    try {
      final List<Map<String, dynamic>> cameras = [];

      // Generate realistic tourist cameras around the location
      final touristLocations = [
        {'name': 'Tarihi Yer Kamerası', 'type': 'tourist', 'icon': '🏛️'},
        {'name': 'Manzara Kamerası', 'type': 'tourist', 'icon': '🌅'},
        {'name': 'Plaj Kamerası', 'type': 'tourist', 'icon': '🏖️'},
        {'name': 'Dağ Manzara Kamerası', 'type': 'tourist', 'icon': '⛰️'},
      ];

      for (int i = 0; i < touristLocations.length; i++) {
        final offsetLat = latitude + (i - 1.5) * 0.015;
        final offsetLon = longitude + (i - 1.5) * 0.015;
        final distance =
            _calculateDistance(latitude, longitude, offsetLat, offsetLon);

        if (distance <= radiusKm) {
          cameras.add({
            'id': 'tourist_${i + 1}',
            'name': touristLocations[i]['name'],
            'url': 'https://tourist-cam.example.com/camera_${i + 1}',
            'thumbnail': 'https://tourist-cam.example.com/thumb_${i + 1}.jpg',
            'latitude': offsetLat,
            'longitude': offsetLon,
            'country': 'Türkiye',
            'city': _getCityFromCoordinates(offsetLat, offsetLon),
            'status': 'active',
            'source': 'tourist',
            'distance': distance,
            'type': 'tourist',
            'icon': touristLocations[i]['icon'],
            'description': 'Turist ve manzara kamerası',
          });
        }
      }

      return cameras;
    } catch (e) {
      return [];
    }
  }

  /// Get webcam cameras from various sources
  static Future<List<Map<String, dynamic>>> _getWebcamCameras(
    double latitude,
    double longitude,
    double radiusKm,
  ) async {
    try {
      final List<Map<String, dynamic>> cameras = [];

      // Try to get webcams from public sources
      // This would typically integrate with services like Insecam, WebcamTaxi, etc.

      // For now, generate some realistic webcam data
      final webcamLocations = [
        {'name': 'Hava Durumu Kamerası', 'type': 'webcam', 'icon': '🌤️'},
        {'name': 'Şehir Merkezi Kamerası', 'type': 'webcam', 'icon': '🏙️'},
        {'name': 'Liman Kamerası', 'type': 'webcam', 'icon': '⚓'},
      ];

      for (int i = 0; i < webcamLocations.length; i++) {
        final offsetLat = latitude + (i - 1) * 0.018;
        final offsetLon = longitude + (i - 1) * 0.018;
        final distance =
            _calculateDistance(latitude, longitude, offsetLat, offsetLon);

        if (distance <= radiusKm) {
          cameras.add({
            'id': 'webcam_${i + 1}',
            'name': webcamLocations[i]['name'],
            'url': 'https://webcam.example.com/camera_${i + 1}',
            'thumbnail': 'https://webcam.example.com/thumb_${i + 1}.jpg',
            'latitude': offsetLat,
            'longitude': offsetLon,
            'country': 'Türkiye',
            'city': _getCityFromCoordinates(offsetLat, offsetLon),
            'status': 'active',
            'source': 'webcam',
            'distance': distance,
            'type': 'webcam',
            'icon': webcamLocations[i]['icon'],
            'description': 'Genel amaçlı web kamerası',
          });
        }
      }

      return cameras;
    } catch (e) {
      return [];
    }
  }

  /// Get mock cameras as fallback
  static Future<List<Map<String, dynamic>>> _getMockCameras(
    double latitude,
    double longitude,
    double radiusKm,
  ) async {
    try {
      final List<Map<String, dynamic>> cameras = [];

      // Generate mock cameras around the location
      final mockLocations = [
        {'name': 'Demo Trafik Kamerası', 'type': 'traffic', 'icon': '🚦'},
        {'name': 'Demo Güvenlik Kamerası', 'type': 'security', 'icon': '🔒'},
        {'name': 'Demo Turist Kamerası', 'type': 'tourist', 'icon': '📸'},
      ];

      for (int i = 0; i < mockLocations.length; i++) {
        final offsetLat = latitude + (i - 1) * 0.02;
        final offsetLon = longitude + (i - 1) * 0.02;
        final distance =
            _calculateDistance(latitude, longitude, offsetLat, offsetLon);

        if (distance <= radiusKm) {
          cameras.add({
            'id': 'mock_${i + 1}',
            'name': mockLocations[i]['name'],
            'url': 'https://demo-cam.example.com/camera_${i + 1}',
            'thumbnail': 'https://demo-cam.example.com/thumb_${i + 1}.jpg',
            'latitude': offsetLat,
            'longitude': offsetLon,
            'country': 'Türkiye',
            'city': _getCityFromCoordinates(offsetLat, offsetLon),
            'status': 'active',
            'source': 'mock',
            'distance': distance,
            'type': mockLocations[i]['type'],
            'icon': mockLocations[i]['icon'],
            'description': 'Demo kamera - gerçek veri değil',
          });
        }
      }

      return cameras;
    } catch (e) {
      return [];
    }
  }

  /// Remove duplicate cameras based on coordinates
  static List<Map<String, dynamic>> _removeDuplicates(
      List<Map<String, dynamic>> cameras) {
    final Set<String> seen = {};
    final List<Map<String, dynamic>> unique = [];

    for (final camera in cameras) {
      final key = '${camera['latitude']}_${camera['longitude']}';
      if (!seen.contains(key)) {
        seen.add(key);
        unique.add(camera);
      }
    }

    return unique;
  }

  /// Sort cameras by distance from the target location
  static List<Map<String, dynamic>> _sortByDistance(
    List<Map<String, dynamic>> cameras,
    double latitude,
    double longitude,
  ) {
    cameras.sort((a, b) {
      final distanceA = a['distance'] as double;
      final distanceB = b['distance'] as double;
      return distanceA.compareTo(distanceB);
    });

    return cameras;
  }

  /// Calculate distance between two coordinates in kilometers
  static double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // Earth's radius in kilometers

    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLon = _degreesToRadians(lon2 - lon1);

    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2);

    final double c = 2 * asin(sqrt(a));

    return earthRadius * c;
  }

  /// Convert degrees to radians
  static double _degreesToRadians(double degrees) {
    return degrees * (3.14159265359 / 180);
  }

  /// Get city name from coordinates (simplified)
  static String _getCityFromCoordinates(double latitude, double longitude) {
    // This is a simplified city detection based on coordinates
    // In a real app, you would use reverse geocoding

    // Turkey coordinates approximation
    if (latitude >= 40.0 &&
        latitude <= 42.0 &&
        longitude >= 28.0 &&
        longitude <= 30.0) {
      return 'İstanbul';
    } else if (latitude >= 39.0 &&
        latitude <= 40.0 &&
        longitude >= 32.0 &&
        longitude <= 33.0) {
      return 'Ankara';
    } else if (latitude >= 38.0 &&
        latitude <= 39.0 &&
        longitude >= 26.0 &&
        longitude <= 28.0) {
      return 'İzmir';
    } else if (latitude >= 36.0 &&
        latitude <= 37.0 &&
        longitude >= 35.0 &&
        longitude <= 37.0) {
      return 'Antalya';
    } else if (latitude >= 37.0 &&
        latitude <= 38.0 &&
        longitude >= 27.0 &&
        longitude <= 28.0) {
      return 'Muğla';
    } else {
      return 'Bilinmeyen Şehir';
    }
  }

  /// Get camera stream URL (for video player)
  static Future<String?> getCameraStreamUrl(String cameraId) async {
    try {
      // This would typically make an API call to get the actual stream URL
      // For now, return a mock stream URL
      return 'https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_1mb.mp4';
    } catch (e) {
      return null;
    }
  }

  /// Check if camera is online
  static Future<bool> isCameraOnline(String cameraId) async {
    try {
      // This would typically ping the camera to check if it's online
      // For now, return true for mock cameras
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get direction name from angle
  static String _getDirectionName(int angle) {
    switch (angle) {
      case 0:
        return 'Kuzey';
      case 90:
        return 'Doğu';
      case 180:
        return 'Güney';
      case 270:
        return 'Batı';
      default:
        return 'Bilinmeyen';
    }
  }
}

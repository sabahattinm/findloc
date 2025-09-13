import 'package:flutter_dotenv/flutter_dotenv.dart';

/// API Keys configuration for camera services
class ApiKeys {
  // Google Maps API
  static String get googleMapsApiKey =>
      dotenv.env['GOOGLE_MAPS_API_KEY'] ??
      'AIzaSyBxMNR35kci2cYlsm1y-0epDfw66ScKV1w';

  // OpenWeatherMap API
  static String get openWeatherApiKey =>
      dotenv.env['OPENWEATHER_API_KEY'] ?? 'YOUR_OPENWEATHER_API_KEY';

  // Webcams.travel API
  static String get webcamsTravelApiKey =>
      dotenv.env['WEBCAMS_TRAVEL_API_KEY'] ?? 'YOUR_WEBCAMS_TRAVEL_API_KEY';

  // Security Camera APIs
  static String get securityCameraApiKey =>
      dotenv.env['SECURITY_CAMERA_API_KEY'] ?? 'YOUR_SECURITY_CAMERA_API_KEY';

  // Traffic Camera APIs
  static String get trafficCameraApiKey =>
      dotenv.env['TRAFFIC_CAMERA_API_KEY'] ?? 'YOUR_TRAFFIC_CAMERA_API_KEY';

  // Tourism Board APIs
  static String get tourismApiKey =>
      dotenv.env['TOURISM_API_KEY'] ?? 'YOUR_TOURISM_API_KEY';

  // Weather Station APIs
  static String get weatherStationApiKey =>
      dotenv.env['WEATHER_STATION_API_KEY'] ?? 'YOUR_WEATHER_STATION_API_KEY';

  /// Check if all required API keys are configured
  static bool get areAllKeysConfigured {
    return googleMapsApiKey != 'YOUR_GOOGLE_MAPS_API_KEY' &&
        openWeatherApiKey != 'YOUR_OPENWEATHER_API_KEY' &&
        webcamsTravelApiKey != 'YOUR_WEBCAMS_TRAVEL_API_KEY';
  }

  /// Get API key with validation
  static String getApiKey(String keyName) {
    switch (keyName) {
      case 'google_maps':
        if (googleMapsApiKey == 'YOUR_GOOGLE_MAPS_API_KEY') {
          throw Exception('Google Maps API key not configured');
        }
        return googleMapsApiKey;
      case 'openweather':
        if (openWeatherApiKey == 'YOUR_OPENWEATHER_API_KEY') {
          throw Exception('OpenWeather API key not configured');
        }
        return openWeatherApiKey;
      case 'webcams_travel':
        if (webcamsTravelApiKey == 'YOUR_WEBCAMS_TRAVEL_API_KEY') {
          throw Exception('Webcams Travel API key not configured');
        }
        return webcamsTravelApiKey;
      default:
        throw Exception('Unknown API key: $keyName');
    }
  }
}

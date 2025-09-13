import 'dart:convert';
import 'dart:io';
import '../models/location_model.dart';
import '../../network/api_client.dart';
import '../../errors/exceptions.dart';

/// Remote data source for location detection using Gemini Vision API
abstract class LocationRemoteDataSource {
  /// Detect location from image using Gemini Vision API
  Future<LocationModel> detectLocationFromImage(
    File imageFile, {
    bool isDetailedAnalysis = true,
    bool useTwoStageAnalysis = false,
  });

  /// Detect location from image URL
  Future<LocationModel> detectLocationFromUrl(
    String imageUrl, {
    bool isDetailedAnalysis = true,
    bool useTwoStageAnalysis = false,
  });
}

/// Implementation of LocationRemoteDataSource
class LocationRemoteDataSourceImpl implements LocationRemoteDataSource {
  const LocationRemoteDataSourceImpl();

  @override
  Future<LocationModel> detectLocationFromImage(
    File imageFile, {
    bool isDetailedAnalysis = true,
    bool useTwoStageAnalysis = false,
  }) async {
    try {
      // Read and encode image
      final imageBytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(imageBytes);

      // Determine MIME type
      final mimeType = _getMimeType(imageFile.path);

      // Call Gemini API - use two-stage analysis if enabled
      return useTwoStageAnalysis
          ? await ApiClient.detectLocationTwoStage(imageFile)
          : await ApiClient.detectLocationFromImage(imageFile);
    } catch (e) {
      throw LocationDetectionException('Konum tespit edilemedi: $e');
    }
  }

  @override
  Future<LocationModel> detectLocationFromUrl(
    String imageUrl, {
    bool isDetailedAnalysis = true,
    bool useTwoStageAnalysis = false,
  }) async {
    try {
      // Call Gemini API - use two-stage analysis if enabled
      return useTwoStageAnalysis
          ? await ApiClient.detectLocationTwoStageFromUrl(imageUrl)
          : await ApiClient.detectLocationFromUrl(imageUrl);
    } catch (e) {
      throw LocationDetectionException('Konum tespit edilemedi: $e');
    }
  }

  /// Get MIME type from file path
  String _getMimeType(String filePath) {
    final extension = filePath.split('.').last.toLowerCase();
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      default:
        return 'image/jpeg';
    }
  }

  /// Parse location from Gemini response
  LocationModel _parseLocationFromResponse(Map<String, dynamic> response) {
    try {
      if (response['candidates'] == null || response['candidates'].isEmpty) {
        throw const LocationDetectionException('Konum tespit edilemedi');
      }

      final candidate = response['candidates'][0];
      final content = candidate['content'];

      if (content['parts'] == null || content['parts'].isEmpty) {
        throw const LocationDetectionException('Konum tespit edilemedi');
      }

      final text = content['parts'][0]['text'] ?? '';

      // Try to parse JSON from response
      final jsonStart = text.indexOf('{');
      final jsonEnd = text.lastIndexOf('}');

      if (jsonStart == -1 || jsonEnd == -1) {
        throw const LocationDetectionException('Geçersiz yanıt formatı');
      }

      final jsonString = text.substring(jsonStart, jsonEnd + 1);
      final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;

      return LocationModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: jsonData['name'] ?? 'Bilinmeyen Konum',
        address: jsonData['address'] ?? 'Adres bulunamadı',
        coordinates: CoordinatesModel(
          latitude: (jsonData['coordinates']?['latitude'] ?? 0.0).toDouble(),
          longitude: (jsonData['coordinates']?['longitude'] ?? 0.0).toDouble(),
        ),
        confidence: (jsonData['confidence'] ?? 0.0).toDouble(),
        detectedAt: DateTime.now(),
        description: jsonData['description'],
        landmarks: jsonData['landmarks']?.cast<String>(),
        city: jsonData['city'],
        country: jsonData['country'],
        postalCode: jsonData['postalCode'],
        region: jsonData['region'],
        accuracy: (jsonData['accuracy'] ?? 0.0).toDouble(),
      );
    } catch (e) {
      throw LocationDetectionException('Konum ayrıştırılamadı: $e');
    }
  }
}

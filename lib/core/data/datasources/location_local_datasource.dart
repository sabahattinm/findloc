import 'dart:convert';
import '../models/location_model.dart';
import '../../errors/exceptions.dart';

/// Local data source for location data using simple storage
abstract class LocationLocalDataSource {
  /// Get location history from local storage
  Future<List<LocationModel>> getLocationHistory();
  
  /// Save location to history
  Future<void> saveLocationToHistory(LocationModel location);
  
  /// Clear location history
  Future<void> clearLocationHistory();
  
  /// Get cached location data
  Future<LocationModel?> getCachedLocation(String locationId);
  
  /// Cache location data
  Future<void> cacheLocation(LocationModel location);
  
  /// Clear cache
  Future<void> clearCache();
}

/// Implementation of LocationLocalDataSource using simple in-memory storage
class LocationLocalDataSourceImpl implements LocationLocalDataSource {
  const LocationLocalDataSourceImpl();
  
  static final List<LocationModel> _locationHistory = [];
  static final Map<String, LocationModel> _locationCache = {};
  
  @override
  Future<List<LocationModel>> getLocationHistory() async {
    try {
      return List.from(_locationHistory);
    } catch (e) {
      throw CacheException('Konum geçmişi alınamadı: $e');
    }
  }
  
  @override
  Future<void> saveLocationToHistory(LocationModel location) async {
    try {
      // Add new location to the beginning of the list
      _locationHistory.insert(0, location);
      
      // Keep only last 50 locations
      if (_locationHistory.length > 50) {
        _locationHistory.removeRange(50, _locationHistory.length);
      }
    } catch (e) {
      throw CacheException('Konum geçmişe kaydedilemedi: $e');
    }
  }
  
  @override
  Future<void> clearLocationHistory() async {
    try {
      _locationHistory.clear();
    } catch (e) {
      throw CacheException('Konum geçmişi temizlenemedi: $e');
    }
  }
  
  @override
  Future<LocationModel?> getCachedLocation(String locationId) async {
    try {
      return _locationCache[locationId];
    } catch (e) {
      throw CacheException('Önbellek verisi alınamadı: $e');
    }
  }
  
  @override
  Future<void> cacheLocation(LocationModel location) async {
    try {
      _locationCache[location.id] = location;
    } catch (e) {
      throw CacheException('Konum önbelleğe kaydedilemedi: $e');
    }
  }
  
  @override
  Future<void> clearCache() async {
    try {
      _locationCache.clear();
    } catch (e) {
      throw CacheException('Önbellek temizlenemedi: $e');
    }
  }
}
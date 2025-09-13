import '../models/subscription_model.dart';
import '../../errors/exceptions.dart';

/// Local data source for subscription data using simple storage
abstract class SubscriptionLocalDataSource {
  /// Get current subscription from local storage
  Future<SubscriptionModel?> getCurrentSubscription();

  /// Save subscription to local storage
  Future<void> saveSubscription(SubscriptionModel subscription);

  /// Get subscription history
  Future<List<SubscriptionModel>> getSubscriptionHistory();

  /// Save subscription to history
  Future<void> saveSubscriptionToHistory(SubscriptionModel subscription);

  /// Clear subscription data
  Future<void> clearSubscriptionData();

  /// Get usage data
  Future<Map<String, dynamic>> getUsageData();

  /// Save usage data
  Future<void> saveUsageData(Map<String, dynamic> usageData);

  /// Increment scan usage
  Future<void> incrementScanUsage();

  /// Reset scan usage
  Future<void> resetScanUsage();
}

/// Implementation of SubscriptionLocalDataSource using simple in-memory storage
class SubscriptionLocalDataSourceImpl implements SubscriptionLocalDataSource {
  const SubscriptionLocalDataSourceImpl();

  static SubscriptionModel? _currentSubscription;
  static final List<SubscriptionModel> _subscriptionHistory = [];
  static Map<String, dynamic> _usageData = {
    'scansUsed': 0,
    'lastResetDate': DateTime.now().toIso8601String(),
    'trialUsed': false,
  };

  @override
  Future<SubscriptionModel?> getCurrentSubscription() async {
    try {
      return _currentSubscription;
    } catch (e) {
      throw CacheException('Abonelik bilgisi alınamadı: $e');
    }
  }

  @override
  Future<void> saveSubscription(SubscriptionModel subscription) async {
    try {
      _currentSubscription = subscription;
    } catch (e) {
      throw CacheException('Abonelik kaydedilemedi: $e');
    }
  }

  @override
  Future<List<SubscriptionModel>> getSubscriptionHistory() async {
    try {
      return List.from(_subscriptionHistory);
    } catch (e) {
      throw CacheException('Abonelik geçmişi alınamadı: $e');
    }
  }

  @override
  Future<void> saveSubscriptionToHistory(SubscriptionModel subscription) async {
    try {
      // Add new subscription to the beginning of the list
      _subscriptionHistory.insert(0, subscription);

      // Keep only last 20 subscriptions
      if (_subscriptionHistory.length > 20) {
        _subscriptionHistory.removeRange(20, _subscriptionHistory.length);
      }
    } catch (e) {
      throw CacheException('Abonelik geçmişe kaydedilemedi: $e');
    }
  }

  @override
  Future<void> clearSubscriptionData() async {
    try {
      _currentSubscription = null;
      _subscriptionHistory.clear();
      _usageData = {
        'scansUsed': 0,
        'lastResetDate': DateTime.now().toIso8601String(),
        'trialUsed': false,
      };
    } catch (e) {
      throw CacheException('Abonelik verileri temizlenemedi: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getUsageData() async {
    try {
      return Map.from(_usageData);
    } catch (e) {
      throw CacheException('Kullanım verileri alınamadı: $e');
    }
  }

  @override
  Future<void> saveUsageData(Map<String, dynamic> usageData) async {
    try {
      _usageData = Map.from(usageData);
    } catch (e) {
      throw CacheException('Kullanım verileri kaydedilemedi: $e');
    }
  }

  @override
  Future<void> incrementScanUsage() async {
    try {
      final currentScans = _usageData['scansUsed'] as int;
      _usageData['scansUsed'] = currentScans + 1;
    } catch (e) {
      throw CacheException('Tarama sayısı artırılamadı: $e');
    }
  }

  @override
  Future<void> resetScanUsage() async {
    try {
      _usageData['scansUsed'] = 0;
      _usageData['lastResetDate'] = DateTime.now().toIso8601String();
    } catch (e) {
      throw CacheException('Tarama sayısı sıfırlanamadı: $e');
    }
  }
}
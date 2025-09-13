import '../entities/subscription_entity.dart';
import '../../errors/failures.dart';

/// Repository interface for subscription operations
abstract class SubscriptionRepository {
  /// Get current user subscription
  Future<SubscriptionEntity> getCurrentSubscription();

  /// Purchase a subscription plan
  Future<SubscriptionEntity> purchaseSubscription(SubscriptionPlan plan);

  /// Restore previous purchases
  Future<List<SubscriptionEntity>> restorePurchases();

  /// Cancel subscription
  Future<void> cancelSubscription(String subscriptionId);

  /// Check if user has active subscription
  Future<bool> hasActiveSubscription();

  /// Use a scan (increment usage counter)
  Future<void> useScan();

  /// Get remaining scans for current subscription
  Future<int> getRemainingScans();

  /// Start free trial
  Future<SubscriptionEntity> startFreeTrial();

  /// Check if user can use free trial
  Future<bool> canUseFreeTrial();

  /// Get subscription history
  Future<List<SubscriptionEntity>> getSubscriptionHistory();

  /// Update subscription status
  Future<void> updateSubscriptionStatus(SubscriptionEntity subscription);
}

/// Entity representing user subscription information
class SubscriptionEntity {
  const SubscriptionEntity({
    required this.id,
    required this.planType,
    required this.isActive,
    required this.startDate,
    required this.endDate,
    required this.scansUsed,
    required this.scansLimit,
    required this.price,
    this.autoRenew = false,
    this.trialUsed = false,
  });

  final String id;
  final SubscriptionPlan planType;
  final bool isActive;
  final DateTime startDate;
  final DateTime endDate;
  final int scansUsed;
  final int scansLimit;
  final double price;
  final bool autoRenew;
  final bool trialUsed;

  /// Check if subscription is expired
  bool get isExpired => DateTime.now().isAfter(endDate);

  /// Check if user has remaining scans
  bool get hasRemainingScans => scansUsed < scansLimit;

  /// Get remaining scans count
  int get remainingScans => scansLimit - scansUsed;

  /// Check if user can use free trial
  bool get canUseTrial => !trialUsed && planType == SubscriptionPlan.free;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SubscriptionEntity &&
        other.id == id &&
        other.planType == planType &&
        other.isActive == isActive &&
        other.startDate == startDate &&
        other.endDate == endDate &&
        other.scansUsed == scansUsed &&
        other.scansLimit == scansLimit &&
        other.price == price &&
        other.autoRenew == autoRenew &&
        other.trialUsed == trialUsed;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      planType,
      isActive,
      startDate,
      endDate,
      scansUsed,
      scansLimit,
      price,
      autoRenew,
      trialUsed,
    );
  }
}

/// Enum representing different subscription plans
enum SubscriptionPlan { free, weekly, monthly, unlimited }

/// Extension for subscription plan details
extension SubscriptionPlanExtension on SubscriptionPlan {
  String get displayName {
    switch (this) {
      case SubscriptionPlan.free:
        return 'Ücretsiz';
      case SubscriptionPlan.weekly:
        return 'Haftalık';
      case SubscriptionPlan.monthly:
        return 'Aylık';
      case SubscriptionPlan.unlimited:
        return 'Sınırsız';
    }
  }

  String get description {
    switch (this) {
      case SubscriptionPlan.free:
        return '3 ücretsiz tarama';
      case SubscriptionPlan.weekly:
        return '5 tarama / hafta';
      case SubscriptionPlan.monthly:
        return '25 tarama / ay';
      case SubscriptionPlan.unlimited:
        return 'Sınırsız tarama';
    }
  }

  double get price {
    switch (this) {
      case SubscriptionPlan.free:
        return 0.0;
      case SubscriptionPlan.weekly:
        return 249.0;
      case SubscriptionPlan.monthly:
        return 749.0;
      case SubscriptionPlan.unlimited:
        return 1999.0;
    }
  }

  int get scanLimit {
    switch (this) {
      case SubscriptionPlan.free:
        return 3;
      case SubscriptionPlan.weekly:
        return 5;
      case SubscriptionPlan.monthly:
        return 25;
      case SubscriptionPlan.unlimited:
        return -1; // -1 means unlimited
    }
  }
}
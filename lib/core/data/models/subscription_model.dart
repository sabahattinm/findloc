import '../../domain/entities/subscription_entity.dart';

/// Data model for subscription information
class SubscriptionModel {
  const SubscriptionModel({
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

  /// Create SubscriptionModel from JSON
  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionModel(
      id: json['id'] ?? '',
      planType: SubscriptionPlan.values.firstWhere(
        (e) => e.name == json['planType'],
        orElse: () => SubscriptionPlan.free,
      ),
      isActive: json['isActive'] ?? false,
      startDate:
          DateTime.parse(json['startDate'] ?? DateTime.now().toIso8601String()),
      endDate:
          DateTime.parse(json['endDate'] ?? DateTime.now().toIso8601String()),
      scansUsed: json['scansUsed'] ?? 0,
      scansLimit: json['scansLimit'] ?? 0,
      price: (json['price'] ?? 0.0).toDouble(),
      autoRenew: json['autoRenew'] ?? false,
      trialUsed: json['trialUsed'] ?? false,
    );
  }

  /// Convert SubscriptionModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'planType': planType.name,
      'isActive': isActive,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'scansUsed': scansUsed,
      'scansLimit': scansLimit,
      'price': price,
      'autoRenew': autoRenew,
      'trialUsed': trialUsed,
    };
  }

  /// Create SubscriptionModel from entity
  factory SubscriptionModel.fromEntity(SubscriptionEntity entity) {
    return SubscriptionModel(
      id: entity.id,
      planType: entity.planType,
      isActive: entity.isActive,
      startDate: entity.startDate,
      endDate: entity.endDate,
      scansUsed: entity.scansUsed,
      scansLimit: entity.scansLimit,
      price: entity.price,
      autoRenew: entity.autoRenew,
      trialUsed: entity.trialUsed,
    );
  }

  /// Convert to entity
  SubscriptionEntity toEntity() {
    return SubscriptionEntity(
      id: id,
      planType: planType,
      isActive: isActive,
      startDate: startDate,
      endDate: endDate,
      scansUsed: scansUsed,
      scansLimit: scansLimit,
      price: price,
      autoRenew: autoRenew,
      trialUsed: trialUsed,
    );
  }
}

import '../../domain/entities/subscription_entity.dart';
import '../../domain/repositories/subscription_repository.dart';
import '../datasources/subscription_local_datasource.dart';
import '../models/subscription_model.dart';
import '../../errors/failures.dart';
import '../../errors/exceptions.dart';

/// Implementation of SubscriptionRepository
class SubscriptionRepositoryImpl implements SubscriptionRepository {
  const SubscriptionRepositoryImpl({
    required this.localDataSource,
  });

  final SubscriptionLocalDataSource localDataSource;

  @override
  Future<SubscriptionEntity> getCurrentSubscription() async {
    try {
      final subscription = await localDataSource.getCurrentSubscription();
      if (subscription != null) {
        return subscription.toEntity();
      }
      
      // Return default free subscription if none exists
      final now = DateTime.now();
      return SubscriptionEntity(
        id: 'free_default',
        planType: SubscriptionPlan.free,
        isActive: true,
        startDate: now,
        endDate: now.add(const Duration(days: 30)),
        scansUsed: 0,
        scansLimit: 3,
        price: 0.0,
        autoRenew: false,
        trialUsed: false,
      );
    } on AppException catch (e) {
      throw _mapExceptionToFailure(e);
    } catch (e) {
      throw UnknownFailure('Bilinmeyen hata: $e');
    }
  }

  @override
  Future<SubscriptionEntity> purchaseSubscription(SubscriptionPlan plan) async {
    try {
      // Create new subscription
      final subscription = SubscriptionModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        planType: plan,
        isActive: true,
        startDate: DateTime.now(),
        endDate: _calculateEndDate(plan),
        scansUsed: 0,
        scansLimit: plan.scanLimit,
        price: plan.price,
        autoRenew: true,
        trialUsed: false,
      );

      // Save subscription
      await localDataSource.saveSubscription(subscription);
      await localDataSource.saveSubscriptionToHistory(subscription);

      return subscription.toEntity();
    } on AppException catch (e) {
      throw _mapExceptionToFailure(e);
    } catch (e) {
      throw UnknownFailure('Bilinmeyen hata: $e');
    }
  }

  @override
  Future<List<SubscriptionEntity>> restorePurchases() async {
    try {
      final history = await localDataSource.getSubscriptionHistory();
      return history.map((model) => model.toEntity()).toList();
    } on AppException catch (e) {
      throw _mapExceptionToFailure(e);
    } catch (e) {
      throw UnknownFailure('Bilinmeyen hata: $e');
    }
  }

  @override
  Future<void> cancelSubscription(String subscriptionId) async {
    try {
      // This would typically call an external service
      // For now, just mark as inactive
      final currentSubscription = await localDataSource.getCurrentSubscription();
      if (currentSubscription != null && currentSubscription.id == subscriptionId) {
        final updatedSubscription = SubscriptionModel(
          id: currentSubscription.id,
          planType: currentSubscription.planType,
          isActive: false,
          startDate: currentSubscription.startDate,
          endDate: currentSubscription.endDate,
          scansUsed: currentSubscription.scansUsed,
          scansLimit: currentSubscription.scansLimit,
          price: currentSubscription.price,
          autoRenew: false,
          trialUsed: currentSubscription.trialUsed,
        );
        
        await localDataSource.saveSubscription(updatedSubscription);
      }
    } on AppException catch (e) {
      throw _mapExceptionToFailure(e);
    } catch (e) {
      throw UnknownFailure('Bilinmeyen hata: $e');
    }
  }

  @override
  Future<bool> hasActiveSubscription() async {
    try {
      final subscription = await localDataSource.getCurrentSubscription();
      return subscription?.isActive == true && !subscription!.isExpired;
    } on AppException catch (e) {
      throw _mapExceptionToFailure(e);
    } catch (e) {
      throw UnknownFailure('Bilinmeyen hata: $e');
    }
  }

  @override
  Future<void> useScan() async {
    try {
      await localDataSource.incrementScanUsage();
    } on AppException catch (e) {
      throw _mapExceptionToFailure(e);
    } catch (e) {
      throw UnknownFailure('Bilinmeyen hata: $e');
    }
  }

  @override
  Future<int> getRemainingScans() async {
    try {
      final subscription = await localDataSource.getCurrentSubscription();
      final usageData = await localDataSource.getUsageData();
      
      if (subscription == null) {
        return 3; // Default free scans
      }
      
      final scansUsed = usageData['scansUsed'] as int;
      final scansLimit = subscription.scansLimit;
      
      if (scansLimit == -1) {
        return -1; // Unlimited
      }
      
      return (scansLimit - scansUsed).clamp(0, scansLimit);
    } on AppException catch (e) {
      throw _mapExceptionToFailure(e);
    } catch (e) {
      throw UnknownFailure('Bilinmeyen hata: $e');
    }
  }

  @override
  Future<SubscriptionEntity> startFreeTrial() async {
    try {
      final usageData = await localDataSource.getUsageData();
      if (usageData['trialUsed'] == true) {
        throw const SubscriptionFailure('Ücretsiz deneme zaten kullanıldı');
      }

      // Create trial subscription
      final trialSubscription = SubscriptionModel(
        id: 'trial_${DateTime.now().millisecondsSinceEpoch}',
        planType: SubscriptionPlan.free,
        isActive: true,
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 7)),
        scansUsed: 0,
        scansLimit: 3,
        price: 0.0,
        autoRenew: false,
        trialUsed: true,
      );

      // Save subscription and mark trial as used
      await localDataSource.saveSubscription(trialSubscription);
      await localDataSource.saveSubscriptionToHistory(trialSubscription);
      
      final updatedUsageData = Map<String, dynamic>.from(usageData);
      updatedUsageData['trialUsed'] = true;
      await localDataSource.saveUsageData(updatedUsageData);

      return trialSubscription.toEntity();
    } on AppException catch (e) {
      throw _mapExceptionToFailure(e);
    } catch (e) {
      throw UnknownFailure('Bilinmeyen hata: $e');
    }
  }

  @override
  Future<bool> canUseFreeTrial() async {
    try {
      final usageData = await localDataSource.getUsageData();
      return usageData['trialUsed'] != true;
    } on AppException catch (e) {
      throw _mapExceptionToFailure(e);
    } catch (e) {
      throw UnknownFailure('Bilinmeyen hata: $e');
    }
  }

  @override
  Future<List<SubscriptionEntity>> getSubscriptionHistory() async {
    try {
      final history = await localDataSource.getSubscriptionHistory();
      return history.map((model) => model.toEntity()).toList();
    } on AppException catch (e) {
      throw _mapExceptionToFailure(e);
    } catch (e) {
      throw UnknownFailure('Bilinmeyen hata: $e');
    }
  }

  @override
  Future<void> updateSubscriptionStatus(SubscriptionEntity subscription) async {
    try {
      final subscriptionModel = SubscriptionModel.fromEntity(subscription);
      await localDataSource.saveSubscription(subscriptionModel);
    } on AppException catch (e) {
      throw _mapExceptionToFailure(e);
    } catch (e) {
      throw UnknownFailure('Bilinmeyen hata: $e');
    }
  }

  /// Calculate end date based on subscription plan
  DateTime _calculateEndDate(SubscriptionPlan plan) {
    final now = DateTime.now();
    switch (plan) {
      case SubscriptionPlan.free:
        return now.add(const Duration(days: 30));
      case SubscriptionPlan.weekly:
        return now.add(const Duration(days: 7));
      case SubscriptionPlan.monthly:
        return now.add(const Duration(days: 30));
      case SubscriptionPlan.unlimited:
        return now.add(const Duration(days: 365));
    }
  }

  /// Map exceptions to failures
  Failure _mapExceptionToFailure(AppException exception) {
    if (exception is NetworkException) {
      return NetworkFailure(exception.message);
    } else if (exception is ServerException) {
      return ServerFailure(exception.message);
    } else if (exception is CacheException) {
      return CacheFailure(exception.message);
    } else if (exception is AuthException) {
      return AuthFailure(exception.message);
    } else if (exception is SubscriptionException) {
      return SubscriptionFailure(exception.message);
    } else {
      return UnknownFailure(exception.message);
    }
  }
}

import '../../domain/entities/subscription_entity.dart';
import '../../domain/repositories/subscription_repository.dart';
import '../../errors/failures.dart';

/// Use case for managing subscriptions
class GetCurrentSubscriptionUseCase {
  const GetCurrentSubscriptionUseCase(this._repository);
  
  final SubscriptionRepository _repository;
  
  /// Execute getting current subscription
  Future<SubscriptionEntity> call() async {
    return await _repository.getCurrentSubscription();
  }
}

/// Use case for purchasing subscription
class PurchaseSubscriptionUseCase {
  const PurchaseSubscriptionUseCase(this._repository);
  
  final SubscriptionRepository _repository;
  
  /// Execute subscription purchase
  Future<SubscriptionEntity> call(PurchaseSubscriptionParams params) async {
    return await _repository.purchaseSubscription(params.plan);
  }
}

/// Parameters for subscription purchase
class PurchaseSubscriptionParams {
  const PurchaseSubscriptionParams({required this.plan});
  
  final SubscriptionPlan plan;
}

/// Use case for using a scan
class UseScanUseCase {
  const UseScanUseCase(this._repository);
  
  final SubscriptionRepository _repository;
  
  /// Execute using a scan
  Future<void> call() async {
    // Check if user has remaining scans
    final remainingScans = await _repository.getRemainingScans();
    if (remainingScans <= 0) {
      throw const SubscriptionFailure('Tarama limitiniz doldu');
    }
    
    await _repository.useScan();
  }
}

/// Use case for checking scan availability
class CheckScanAvailabilityUseCase {
  const CheckScanAvailabilityUseCase(this._repository);
  
  final SubscriptionRepository _repository;
  
  /// Execute checking scan availability
  Future<bool> call() async {
    final remainingScans = await _repository.getRemainingScans();
    return remainingScans > 0;
  }
}

/// Use case for starting free trial
class StartFreeTrialUseCase {
  const StartFreeTrialUseCase(this._repository);
  
  final SubscriptionRepository _repository;
  
  /// Execute starting free trial
  Future<SubscriptionEntity> call() async {
    // Check if user can use free trial
    final canUseTrial = await _repository.canUseFreeTrial();
    if (!canUseTrial) {
      throw const SubscriptionFailure('Ücretsiz deneme sürümü kullanılamıyor');
    }
    
    return await _repository.startFreeTrial();
  }
}

/// Use case for checking subscription status
class CheckSubscriptionStatusUseCase {
  const CheckSubscriptionStatusUseCase(this._repository);
  
  final SubscriptionRepository _repository;
  
  /// Execute checking subscription status
  Future<bool> call() async {
    return await _repository.hasActiveSubscription();
  }
}

/// Use case for restoring purchases
class RestorePurchasesUseCase {
  const RestorePurchasesUseCase(this._repository);
  
  final SubscriptionRepository _repository;
  
  /// Execute restoring purchases
  Future<List<SubscriptionEntity>> call() async {
    return await _repository.restorePurchases();
  }
}
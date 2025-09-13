import 'package:get_it/get_it.dart';

import '../network/network_info.dart';
import '../data/datasources/location_remote_datasource.dart';
import '../data/datasources/location_local_datasource.dart';
import '../data/datasources/subscription_local_datasource.dart';
import '../data/datasources/live_camera_remote_datasource.dart';
import '../data/repositories/location_repository_impl.dart';
import '../data/repositories/subscription_repository_impl.dart';
import '../data/repositories/live_camera_repository_impl.dart';
import '../domain/repositories/location_repository.dart';
import '../domain/repositories/subscription_repository.dart';
import '../domain/repositories/live_camera_repository.dart';
import '../domain/usecases/detect_location_usecase.dart';
import '../domain/usecases/subscription_usecase.dart';
import '../domain/usecases/live_camera_usecase.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  // Register network dependencies
  getIt.registerLazySingleton<NetworkInfo>(() => const NetworkInfoImpl());

  // Register data sources
  getIt.registerLazySingleton<LocationRemoteDataSource>(
    () => const LocationRemoteDataSourceImpl(),
  );
  getIt.registerLazySingleton<LocationLocalDataSource>(
    () => const LocationLocalDataSourceImpl(),
  );
  getIt.registerLazySingleton<SubscriptionLocalDataSource>(
    () => const SubscriptionLocalDataSourceImpl(),
  );
  getIt.registerLazySingleton<LiveCameraRemoteDataSource>(
    () => const LiveCameraRemoteDataSourceImpl(),
  );

  // Register repositories
  getIt.registerLazySingleton<LocationRepository>(
    () => LocationRepositoryImpl(
      remoteDataSource: getIt<LocationRemoteDataSource>(),
      localDataSource: getIt<LocationLocalDataSource>(),
      networkInfo: getIt<NetworkInfo>(),
    ),
  );
  getIt.registerLazySingleton<SubscriptionRepository>(
    () => SubscriptionRepositoryImpl(
      localDataSource: getIt<SubscriptionLocalDataSource>(),
    ),
  );
  getIt.registerLazySingleton<LiveCameraRepository>(
    () => LiveCameraRepositoryImpl(
      remoteDataSource: getIt<LiveCameraRemoteDataSource>(),
    ),
  );

  // Register use cases
  getIt.registerLazySingleton<DetectLocationUseCase>(
    () => DetectLocationUseCase(getIt<LocationRepository>()),
  );
  getIt.registerLazySingleton<DetectLocationFromUrlUseCase>(
    () => DetectLocationFromUrlUseCase(getIt<LocationRepository>()),
  );
  getIt.registerLazySingleton<GetLocationHistoryUseCase>(
    () => GetLocationHistoryUseCase(getIt<LocationRepository>()),
  );
  getIt.registerLazySingleton<GetLocationNearbyCamerasUseCase>(
    () => GetLocationNearbyCamerasUseCase(getIt<LocationRepository>()),
  );

  // Register subscription use cases
  getIt.registerLazySingleton<GetCurrentSubscriptionUseCase>(
    () => GetCurrentSubscriptionUseCase(getIt<SubscriptionRepository>()),
  );
  getIt.registerLazySingleton<PurchaseSubscriptionUseCase>(
    () => PurchaseSubscriptionUseCase(getIt<SubscriptionRepository>()),
  );
  getIt.registerLazySingleton<UseScanUseCase>(
    () => UseScanUseCase(getIt<SubscriptionRepository>()),
  );
  getIt.registerLazySingleton<CheckScanAvailabilityUseCase>(
    () => CheckScanAvailabilityUseCase(getIt<SubscriptionRepository>()),
  );
  getIt.registerLazySingleton<StartFreeTrialUseCase>(
    () => StartFreeTrialUseCase(getIt<SubscriptionRepository>()),
  );
  getIt.registerLazySingleton<CheckSubscriptionStatusUseCase>(
    () => CheckSubscriptionStatusUseCase(getIt<SubscriptionRepository>()),
  );
  getIt.registerLazySingleton<RestorePurchasesUseCase>(
    () => RestorePurchasesUseCase(getIt<SubscriptionRepository>()),
  );

  // Register live camera use cases
  getIt.registerLazySingleton<GetNearbyCamerasUseCase>(
    () => GetNearbyCamerasUseCase(getIt<LiveCameraRepository>()),
  );
  getIt.registerLazySingleton<GetAllCamerasUseCase>(
    () => GetAllCamerasUseCase(getIt<LiveCameraRepository>()),
  );
  getIt.registerLazySingleton<GetCameraByIdUseCase>(
    () => GetCameraByIdUseCase(getIt<LiveCameraRepository>()),
  );
  getIt.registerLazySingleton<GetCamerasByTypeUseCase>(
    () => GetCamerasByTypeUseCase(getIt<LiveCameraRepository>()),
  );
  getIt.registerLazySingleton<SearchCamerasUseCase>(
    () => SearchCamerasUseCase(getIt<LiveCameraRepository>()),
  );
  getIt.registerLazySingleton<GetCameraStreamUrlUseCase>(
    () => GetCameraStreamUrlUseCase(getIt<LiveCameraRepository>()),
  );
  getIt.registerLazySingleton<CheckCameraStatusUseCase>(
    () => CheckCameraStatusUseCase(getIt<LiveCameraRepository>()),
  );
  getIt.registerLazySingleton<GetCameraThumbnailUseCase>(
    () => GetCameraThumbnailUseCase(getIt<LiveCameraRepository>()),
  );
}

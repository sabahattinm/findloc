import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/domain/usecases/detect_location_usecase.dart';
import '../../../../core/domain/usecases/subscription_usecase.dart';
import '../../../../core/theme/app_theme.dart';
import '../bloc/location_detection_bloc.dart';
import '../widgets/modern_location_detection_widget.dart';
import '../widgets/location_result_widget.dart';
import '../widgets/location_history_widget.dart';
import '../widgets/simple_camera_widget.dart';

/// Modern Professional Home Page
class ModernHomePage extends StatefulWidget {
  const ModernHomePage({super.key});

  @override
  State<ModernHomePage> createState() => _ModernHomePageState();
}

class _ModernHomePageState extends State<ModernHomePage>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LocationDetectionBloc(
        detectLocationUseCase: getIt<DetectLocationUseCase>(),
        detectLocationFromUrlUseCase: getIt<DetectLocationFromUrlUseCase>(),
        getLocationHistoryUseCase: getIt<GetLocationHistoryUseCase>(),
        getLocationNearbyCamerasUseCase:
            getIt<GetLocationNearbyCamerasUseCase>(),
        useScanUseCase: getIt<UseScanUseCase>(),
        checkScanAvailabilityUseCase: getIt<CheckScanAvailabilityUseCase>(),
      ),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          child: BlocListener<LocationDetectionBloc, LocationDetectionState>(
            listener: (context, state) {
              if (state is LocationDetectionSuccess) {
                // Konum tespit edildikten sonra sonuçlar sekmesine geç
                _tabController.animateTo(3); // Sonuçlar sekmesi (index 3)
              }
            },
            child: Column(
              children: [
                _buildModernAppBar(),
                _buildTabBar(),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      const ModernLocationDetectionWidget(),
                      const LocationHistoryWidget(),
                      SimpleCameraWidget(
                        onNavigateToDetection: () =>
                            _tabController.animateTo(0),
                      ),
                      BlocBuilder<LocationDetectionBloc,
                          LocationDetectionState>(
                        builder: (context, state) {
                          if (state is LocationDetectionSuccess) {
                            return LocationResultWidget(
                              location: state.location,
                              onNewDetection: () => _tabController.animateTo(0),
                            );
                          }
                          return const Center(
                            child: Text('Konum tespit edilmedi'),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernAppBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.location_on_rounded,
                  color: AppTheme.primaryBlue,
                  size: 24.w,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'FindLoc',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                    ),
                    Text(
                      'AI ile konum tespit et',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.7),
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppTheme.primaryBlue,
          borderRadius: BorderRadius.circular(12.r),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor:
            Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        labelStyle: TextStyle(
          fontSize: 13.sp,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 13.sp,
          fontWeight: FontWeight.w500,
        ),
        tabs: const [
          Tab(
            icon: Icon(Icons.camera_alt_rounded, size: 20),
            text: 'Tespit Et',
          ),
          Tab(
            icon: Icon(Icons.history_rounded, size: 20),
            text: 'Geçmiş',
          ),
          Tab(
            icon: Icon(Icons.videocam_rounded, size: 20),
            text: 'Kameralar',
          ),
          Tab(
            icon: Icon(Icons.location_on_rounded, size: 20),
            text: 'Sonuçlar',
          ),
        ],
      ),
    );
  }
}

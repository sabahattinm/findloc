import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/domain/usecases/detect_location_usecase.dart';
import '../../../../core/domain/usecases/subscription_usecase.dart';
import '../../../../core/theme/modern_theme.dart';
import '../bloc/location_detection_bloc.dart';
import '../widgets/modern_detection_widget.dart';
import '../widgets/modern_camera_widget.dart';
import '../widgets/modern_result_widget.dart';
import '../widgets/modern_history_widget.dart';

/// Modern yeniden tasarlanmış ana sayfa
class ModernRedesignedHomePage extends StatefulWidget {
  const ModernRedesignedHomePage({super.key});

  @override
  State<ModernRedesignedHomePage> createState() =>
      _ModernRedesignedHomePageState();
}

class _ModernRedesignedHomePageState extends State<ModernRedesignedHomePage> {
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
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
        backgroundColor: ModernTheme.primaryDarkBlue,
        body: BlocListener<LocationDetectionBloc, LocationDetectionState>(
          listener: (context, state) {
            if (state is LocationDetectionSuccess) {
              // Konum tespit edildikten sonra sonuçlar sayfasına geç
              _pageController.animateToPage(
                2, // Sonuçlar sayfası
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
              );
            }
          },
          child: SafeArea(
            child: Column(
              children: [
                _buildModernAppBar(),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                    children: const [
                      ModernDetectionWidget(),
                      ModernCameraWidget(),
                      ModernResultWidget(),
                      ModernHistoryWidget(),
                    ],
                  ),
                ),
                _buildModernBottomNav(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernAppBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: Row(
        children: [
          // Logo ve başlık
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              gradient: ModernTheme.primaryGradient,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: ModernTheme.primaryGreen.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              Icons.location_on_rounded,
              color: Colors.white,
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
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Akıllı Konum Tespit',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14.sp,
                  ),
                ),
              ],
            ),
          ),
          // Bildirim ikonu
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              Icons.notifications_outlined,
              color: Colors.white,
              size: 20.w,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernBottomNav() {
    return Container(
      margin: EdgeInsets.only(left: 20.w, right: 20.w, bottom: 20.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        gradient: ModernTheme.cardGradient,
        borderRadius: BorderRadius.circular(28.r),
        boxShadow: [
          BoxShadow(
            color: ModernTheme.primaryGreen.withOpacity(0.3),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(0, Icons.camera_alt_rounded, 'Tespit'),
          _buildNavItem(1, Icons.videocam_rounded, 'Kameralar'),
          _buildNavItem(2, Icons.location_on_rounded, 'Sonuçlar'),
          _buildNavItem(3, Icons.history_rounded, 'Geçmiş'),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () {
        _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          gradient: isSelected ? ModernTheme.primaryGradient : null,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: ModernTheme.primaryGreen.withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: EdgeInsets.all(6.w),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withOpacity(0.2)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                icon,
                color:
                    isSelected ? Colors.white : Colors.white.withOpacity(0.6),
                size: 20.w,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              label,
              style: TextStyle(
                color:
                    isSelected ? Colors.white : Colors.white.withOpacity(0.6),
                fontSize: 10.sp,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

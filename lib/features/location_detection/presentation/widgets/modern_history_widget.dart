import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/modern_theme.dart';
import '../bloc/location_detection_bloc.dart';

/// Modern geçmiş widget'ı
class ModernHistoryWidget extends StatefulWidget {
  const ModernHistoryWidget({super.key});

  @override
  State<ModernHistoryWidget> createState() => _ModernHistoryWidgetState();
}

class _ModernHistoryWidgetState extends State<ModernHistoryWidget> {
  @override
  void initState() {
    super.initState();
    // Widget yüklendiğinde geçmişi yükle
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LocationDetectionBloc>().add(const LoadLocationHistory());
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocationDetectionBloc, LocationDetectionState>(
      builder: (context, state) {
        if (state is LocationDetectionLoading) {
          return _buildLoadingState();
        } else if (state is LocationHistoryLoaded) {
          if (state.history.isEmpty) {
            return _buildEmptyState();
          }
          return _buildHistoryList(state.history);
        }

        return _buildInitialState();
      },
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ModernTheme.glowContainer(
            glowColor: ModernTheme.primaryBlue,
            child: Container(
              width: 80.w,
              height: 80.w,
              decoration: BoxDecoration(
                gradient: ModernTheme.primaryGradient,
                borderRadius: BorderRadius.circular(40.r),
              ),
              child: Icon(
                Icons.history_rounded,
                color: Colors.white,
                size: 40.w,
              ),
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            'Geçmiş Yükleniyor...',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120.w,
            height: 120.w,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(60.r),
            ),
            child: Icon(
              Icons.history_rounded,
              color: Colors.white.withOpacity(0.5),
              size: 60.w,
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            'Henüz Geçmiş Yok',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Tespit ettiğiniz konumlar burada görünecek',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14.sp,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInitialState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ModernTheme.glowContainer(
            glowColor: ModernTheme.primaryGreen,
            child: Container(
              width: 120.w,
              height: 120.w,
              decoration: BoxDecoration(
                gradient: ModernTheme.primaryGradient,
                borderRadius: BorderRadius.circular(60.r),
              ),
              child: Icon(
                Icons.history_rounded,
                color: Colors.white,
                size: 60.w,
              ),
            ),
          ),
          SizedBox(height: 32.h),
          Text(
            'Konum Geçmişi',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            'Tespit ettiğiniz konumların geçmişini görün',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 16.sp,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList(locations) {
    return Column(
      children: [
        // Başlık
        Container(
          padding: EdgeInsets.all(20.w),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  gradient: ModernTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.history_rounded,
                  color: Colors.white,
                  size: 20.w,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Konum Geçmişi',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${locations.length} konum bulundu',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Geçmiş listesi
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            itemCount: locations.length,
            itemBuilder: (context, index) {
              final location = locations[index];
              return _buildHistoryCard(location, index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryCard(location, int index) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      child: ModernTheme.gradientContainer(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: BoxDecoration(
                    gradient: ModernTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        location.name,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        location.address,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 12.sp,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: ModernTheme.primaryBlue.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    '${(location.confidence * 100).toInt()}%',
                    style: TextStyle(
                      color: ModernTheme.primaryBlue,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),

            // Konum bilgileri
            Row(
              children: [
                Icon(
                  Icons.location_city_rounded,
                  color: Colors.white.withOpacity(0.7),
                  size: 14.w,
                ),
                SizedBox(width: 8.w),
                Text(
                  location.city ?? 'Bilinmeyen',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12.sp,
                  ),
                ),
                SizedBox(width: 16.w),
                Icon(
                  Icons.flag_rounded,
                  color: Colors.white.withOpacity(0.7),
                  size: 14.w,
                ),
                SizedBox(width: 8.w),
                Text(
                  location.country ?? 'Bilinmeyen',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),

            // Aksiyon butonları
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 36.h,
                    decoration: BoxDecoration(
                      gradient: ModernTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          // Konumu tekrar tespit et
                        },
                        borderRadius: BorderRadius.circular(12.r),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.refresh_rounded,
                              color: Colors.white,
                              size: 14.w,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              'Tekrar Tespit',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Container(
                    height: 36.h,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          // Haritada aç
                        },
                        borderRadius: BorderRadius.circular(12.r),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.map_rounded,
                              color: Colors.white,
                              size: 14.w,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              'Harita',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

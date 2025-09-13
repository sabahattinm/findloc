import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/modern_theme.dart';
import '../bloc/location_detection_bloc.dart';

/// Modern sonuç widget'ı
class ModernResultWidget extends StatelessWidget {
  const ModernResultWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocationDetectionBloc, LocationDetectionState>(
      builder: (context, state) {
        if (state is LocationDetectionSuccess) {
          return _buildResultContent(context, state.location);
        }

        return _buildNoResultState();
      },
    );
  }

  Widget _buildNoResultState() {
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
              Icons.location_off_rounded,
              color: Colors.white.withOpacity(0.5),
              size: 60.w,
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            'Konum Tespit Edilmedi',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Önce bir konum tespit edin',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultContent(BuildContext context, location) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        children: [
          _buildHeader(location),
          SizedBox(height: 24.h),
          _buildLocationCard(location),
          SizedBox(height: 24.h),
          _buildDetailsCard(location),
          SizedBox(height: 24.h),
          _buildActionsCard(context, location),
          SizedBox(height: 24.h),
          _buildNewDetectionButton(context),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  Widget _buildHeader(location) {
    return ModernTheme.gradientContainer(
      padding: EdgeInsets.all(24.w),
      child: Column(
        children: [
          Container(
            width: 80.w,
            height: 80.w,
            decoration: BoxDecoration(
              gradient: ModernTheme.primaryGradient,
              borderRadius: BorderRadius.circular(40.r),
            ),
            child: Icon(
              Icons.check_circle_rounded,
              color: Colors.white,
              size: 40.w,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'Konum Tespit Edildi!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'AI analizi başarıyla tamamlandı',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCard(location) {
    return ModernTheme.gradientContainer(
      padding: EdgeInsets.all(24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  gradient: ModernTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.location_on_rounded,
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
                      location.name,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      location.address,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),

          // Konum bilgileri
          _buildInfoRow(
            Icons.flag_rounded,
            'Ülke',
            location.country ?? 'Bilinmeyen',
          ),
          SizedBox(height: 12.h),
          _buildInfoRow(
            Icons.location_city_rounded,
            'Şehir',
            location.city ?? 'Bilinmeyen',
          ),
          SizedBox(height: 12.h),
          _buildInfoRow(
            Icons.my_location_rounded,
            'Koordinatlar',
            '${location.coordinates.latitude.toStringAsFixed(6)}, ${location.coordinates.longitude.toStringAsFixed(6)}',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(
          icon,
          color: ModernTheme.primaryBlue,
          size: 16.w,
        ),
        SizedBox(width: 12.w),
        Text(
          '$label:',
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 14.sp,
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsCard(location) {
    return ModernTheme.gradientContainer(
      padding: EdgeInsets.all(24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Detaylı Bilgiler',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20.h),
          if (location.description != null) ...[
            _buildDetailItem(
              Icons.description_rounded,
              'Açıklama',
              location.description,
            ),
            SizedBox(height: 16.h),
          ],
          if (location.buildingType != null) ...[
            _buildDetailItem(
              Icons.business_rounded,
              'Yapı Türü',
              location.buildingType,
            ),
            SizedBox(height: 16.h),
          ],
          if (location.architecturalStyle != null) ...[
            _buildDetailItem(
              Icons.architecture_rounded,
              'Mimari Tarz',
              location.architecturalStyle,
            ),
            SizedBox(height: 16.h),
          ],
          if (location.roadType != null) ...[
            _buildDetailItem(
              Icons.route_rounded,
              'Yol Türü',
              location.roadType,
            ),
            SizedBox(height: 16.h),
          ],
          if (location.confidence != null) ...[
            _buildConfidenceBar(location.confidence),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: ModernTheme.primaryBlue.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(
            icon,
            color: ModernTheme.primaryBlue,
            size: 16.w,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 12.sp,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildConfidenceBar(double confidence) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.analytics_rounded,
              color: ModernTheme.primaryGreen,
              size: 16.w,
            ),
            SizedBox(width: 8.w),
            Text(
              'Güven Skoru',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Text(
              '${(confidence * 100).toInt()}%',
              style: TextStyle(
                color: ModernTheme.primaryGreen,
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Container(
          height: 8.h,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(4.r),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: confidence,
            child: Container(
              decoration: BoxDecoration(
                gradient: ModernTheme.primaryGradient,
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionsCard(BuildContext context, location) {
    return ModernTheme.gradientContainer(
      padding: EdgeInsets.all(24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Eylemler',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20.h),
          Row(
            children: [
              Expanded(
                child: ModernTheme.gradientButton(
                  text: 'Haritada Aç',
                  icon: Icons.map_rounded,
                  onPressed: () {
                    // Haritada aç
                  },
                  height: 50.h,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Container(
                  height: 50.h,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        // Paylaş
                      },
                      borderRadius: BorderRadius.circular(16.r),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.share_rounded,
                            color: Colors.white,
                            size: 16.w,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            'Paylaş',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14.sp,
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
    );
  }

  Widget _buildNewDetectionButton(BuildContext context) {
    return ModernTheme.gradientContainer(
      padding: EdgeInsets.all(24.w),
      child: Column(
        children: [
          Icon(
            Icons.camera_alt_rounded,
            color: Colors.white,
            size: 32.w,
          ),
          SizedBox(height: 12.h),
          Text(
            'Yeni Konum Tespit Et',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Başka bir görsel ile konum tespit etmek için tıklayın',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14.sp,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20.h),
          Container(
            width: double.infinity,
            height: 50.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  // Yeni tespit için tespit sayfasına geç
                  // Bu callback ana sayfadan gelecek
                },
                borderRadius: BorderRadius.circular(16.r),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_rounded,
                      color: ModernTheme.primaryBlue,
                      size: 20.w,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'Yeni Tespit Başlat',
                      style: TextStyle(
                        color: ModernTheme.primaryBlue,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

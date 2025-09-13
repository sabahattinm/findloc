import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/modern_theme.dart';
import '../bloc/location_detection_bloc.dart';
import 'camera_stream_widget.dart';

/// Modern kamera widget'ı
class ModernCameraWidget extends StatefulWidget {
  const ModernCameraWidget({super.key});

  @override
  State<ModernCameraWidget> createState() => _ModernCameraWidgetState();
}

class _ModernCameraWidgetState extends State<ModernCameraWidget> {
  @override
  void initState() {
    super.initState();
    // Widget yüklendiğinde son tespit edilen konumun kameralarını yükle
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadLastDetectedLocationCameras();
    });
  }

  void _loadLastDetectedLocationCameras() {
    final bloc = context.read<LocationDetectionBloc>();
    final currentState = bloc.state;

    if (currentState is LocationDetectionSuccess) {
      // Son tespit edilen konumun kameralarını yükle
      bloc.add(LoadNearbyCameras(
        location: currentState.location,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocationDetectionBloc, LocationDetectionState>(
      builder: (context, state) {
        if (state is NearbyCamerasLoading) {
          return _buildLoadingState();
        } else if (state is NearbyCamerasLoaded) {
          if (state.cameras.isEmpty) {
            return _buildEmptyState();
          }
          return _buildCamerasList(state.cameras);
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
                Icons.videocam_rounded,
                color: Colors.white,
                size: 40.w,
              ),
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            'Kameralar Yükleniyor...',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Yakındaki canlı kameralar aranıyor',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14.sp,
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
              Icons.videocam_off_rounded,
              color: Colors.white.withOpacity(0.5),
              size: 60.w,
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            'Yakında Kamera Yok',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Bu konumda canlı kamera bulunamadı.\nBaşka bir konum deneyin.',
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
                Icons.camera_alt_rounded,
                color: Colors.white,
                size: 60.w,
              ),
            ),
          ),
          SizedBox(height: 32.h),
          Text(
            'Konum Tespit Edin',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            'Yakındaki canlı kameraları görmek için\nönce bir konum tespit edin',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 16.sp,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 32.h),
          ModernTheme.gradientButton(
            text: 'Konum Tespit Et',
            icon: Icons.camera_alt_rounded,
            onPressed: () => _navigateToDetection(),
            width: 200.w,
            height: 50.h,
          ),
        ],
      ),
    );
  }

  Widget _buildCamerasList(cameras) {
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
                  Icons.videocam_rounded,
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
                      'Canlı Kameralar',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${cameras.length} kamera bulundu',
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

        // Kamera listesi
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            itemCount: cameras.length,
            itemBuilder: (context, index) {
              final camera = cameras[index];
              return _buildCameraCard(camera);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCameraCard(camera) {
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
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    gradient: ModernTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    Icons.videocam_rounded,
                    color: Colors.white,
                    size: 16.w,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        camera.name,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        camera.cameraType.displayName,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: ModernTheme.primaryGreen.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    'CANLI',
                    style: TextStyle(
                      color: ModernTheme.primaryGreen,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),

            // Konum bilgisi
            Row(
              children: [
                Icon(
                  Icons.location_on_rounded,
                  color: Colors.white.withOpacity(0.7),
                  size: 16.w,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    '${camera.location.city ?? 'Bilinmeyen'}, ${camera.location.country ?? 'Bilinmeyen'}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14.sp,
                    ),
                  ),
                ),
                Text(
                  '${camera.distance.toStringAsFixed(1)} km',
                  style: TextStyle(
                    color: ModernTheme.primaryBlue,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
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
                    height: 40.h,
                    decoration: BoxDecoration(
                      gradient: ModernTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _openCameraStream(camera),
                        borderRadius: BorderRadius.circular(12.r),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 16.w,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              'İzle',
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
                SizedBox(width: 12.w),
                Expanded(
                  child: Container(
                    height: 40.h,
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
                        onTap: () => _openInMap(camera),
                        borderRadius: BorderRadius.circular(12.r),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.map_rounded,
                              color: Colors.white,
                              size: 16.w,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              'Harita',
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
      ),
    );
  }

  void _openCameraStream(camera) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CameraStreamWidget(
          cameraName: camera.name,
          streamUrl: camera.streamUrl ?? '',
          cameraType: camera.cameraType.displayName,
        ),
      ),
    );
  }

  void _openInMap(camera) {
    // Harita açma işlevi
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ModernTheme.primaryDarkBlueLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: Text(
          'Harita Özelliği',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.map_rounded,
              color: ModernTheme.primaryGreen,
              size: 48.w,
            ),
            SizedBox(height: 16.h),
            Text(
              'Harita özelliği yakında eklenecek!\nKamera konumu haritada gösterilecek.',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 14.sp,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Tamam',
              style: TextStyle(
                color: ModernTheme.primaryGreen,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToDetection() {
    // Ana sayfadaki PageController'a erişim için callback kullan
    // Bu widget ana sayfadan çağrıldığında callback ile tespit sayfasına geçiş yapılacak
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Tespit Et sayfasına geçmek için ana sayfadaki "Tespit Et" sekmesini kullanın',
          style: TextStyle(fontSize: 14.sp),
        ),
        backgroundColor: ModernTheme.primaryGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        duration: Duration(seconds: 3),
      ),
    );
  }
}

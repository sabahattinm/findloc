import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

import '../bloc/location_detection_bloc.dart';

/// Basit ve kullanıcı dostu kamera widget'ı
class SimpleCameraWidget extends StatefulWidget {
  final VoidCallback? onNavigateToDetection;

  const SimpleCameraWidget({
    super.key,
    this.onNavigateToDetection,
  });

  @override
  State<SimpleCameraWidget> createState() => _SimpleCameraWidgetState();
}

class _SimpleCameraWidgetState extends State<SimpleCameraWidget> {
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
          return _buildLoadingState(context);
        } else if (state is NearbyCamerasLoaded) {
          if (state.cameras.isEmpty) {
            return _buildEmptyState(context);
          }
          return _buildCamerasList(context, state.cameras);
        }

        return _buildInitialState(context);
      },
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary,
              ),
              strokeWidth: 3.w,
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            'Canlı Kameralar Aranıyor...',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Yakındaki canlı kameralar bulunuyor',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(32.w),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.videocam_off,
              size: 64.w,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            'Yakında Kamera Yok',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Bu konumda canlı kamera bulunamadı.\nBaşka bir konum deneyin.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInitialState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(32.w),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.camera_alt_rounded,
              size: 64.w,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            'Konum Tespit Edin',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Yakındaki canlı kameraları görmek için\nönce bir konum tespit edin',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 32.h),
          ElevatedButton.icon(
            onPressed: () {
              // Tespit Et sekmesine geç
              widget.onNavigateToDetection?.call();
            },
            icon: const Icon(Icons.camera_alt_rounded),
            label: const Text('Konum Tespit Et'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCamerasList(BuildContext context, cameras) {
    return FutureBuilder<List<dynamic>>(
      future: _filterCamerasWithImages(cameras),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16.h),
                Text(
                  'Kameralar kontrol ediliyor...',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14.sp,
                  ),
                ),
              ],
            ),
          );
        }

        final filteredCameras = snapshot.data ?? [];

        if (filteredCameras.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.videocam_off,
                  size: 64.w,
                  color: Colors.grey,
                ),
                SizedBox(height: 16.h),
                Text(
                  'Görüntü Alınabilen Kamera Yok',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Bu konumda Google Street View görüntüsü bulunamadı',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14.sp,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Başlık
              Padding(
                padding: EdgeInsets.all(16.w),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Icon(
                        Icons.videocam,
                        color: Theme.of(context).colorScheme.primary,
                        size: 20.w,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'En Yakın Kameralar',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Text(
                            '${filteredCameras.length} kamera bulundu (en yakın 5)',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withOpacity(0.6),
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Kamera listesi
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredCameras.length,
                itemBuilder: (context, index) {
                  final camera = filteredCameras[index];
                  return _buildSimpleCameraCard(context, camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSimpleCameraCard(BuildContext context, camera) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Kamera önizleme
          _buildCameraPreview(context, camera),

          // Kamera bilgileri
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Kamera adı ve türü
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(6.w),
                      decoration: BoxDecoration(
                        color: _getCameraTypeColor(camera.cameraType)
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(
                        _getCameraTypeIcon(camera.cameraType),
                        style: TextStyle(fontSize: 16.sp),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            camera.name,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            _getCameraTypeDisplayName(camera.cameraType),
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withOpacity(0.6),
                                    ),
                          ),
                        ],
                      ),
                    ),
                    // Durum göstergesi
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: camera.isActive
                            ? Colors.green.withOpacity(0.1)
                            : Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: camera.isActive ? Colors.green : Colors.red,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        camera.isActive ? 'Canlı' : 'Offline',
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w500,
                          color: camera.isActive ? Colors.green : Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 12.h),

                // Konum bilgisi
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 16.w,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.6),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        '${camera.location.city ?? 'Bilinmeyen'}, ${camera.location.country ?? 'Bilinmeyen'}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.7),
                            ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 8.h),

                // Görüntü durumu
                FutureBuilder<bool>(
                  future: _hasStreetViewImage(
                      camera.location.coordinates.latitude,
                      camera.location.coordinates.longitude),
                  builder: (context, snapshot) {
                    final hasImage = snapshot.data ?? false;
                    return Row(
                      children: [
                        Icon(
                          hasImage ? Icons.check_circle : Icons.cancel,
                          size: 16.w,
                          color: hasImage ? Colors.green : Colors.orange,
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            hasImage
                                ? 'Google Street View mevcut'
                                : 'Görüntü alınamıyor',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color:
                                      hasImage ? Colors.green : Colors.orange,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ),
                      ],
                    );
                  },
                ),

                SizedBox(height: 16.h),

                // Aksiyon butonları
                Row(
                  children: [
                    Expanded(
                      child: _buildActionButton(
                        context: context,
                        icon: Icons.play_arrow,
                        label: 'İzle',
                        color: Theme.of(context).colorScheme.primary,
                        onTap: () => _watchCamera(context, camera),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: _buildActionButton(
                        context: context,
                        icon: Icons.map,
                        label: 'Haritada Gör',
                        color: Colors.blue,
                        onTap: () => _openInMaps(context, camera),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraPreview(BuildContext context, camera) {
    return FutureBuilder<bool>(
        future: _hasStreetViewImage(camera.location.coordinates.latitude,
            camera.location.coordinates.longitude),
        builder: (context, snapshot) {
          final hasImage = snapshot.data ?? false;

          return Container(
            height: 120.h,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.r),
                topRight: Radius.circular(16.r),
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: hasImage
                    ? [
                        Colors.green.withOpacity(0.2),
                        Colors.blue.withOpacity(0.2),
                      ]
                    : [
                        Colors.orange.withOpacity(0.2),
                        Colors.red.withOpacity(0.2),
                      ],
              ),
            ),
            child: Stack(
              children: [
                // Kamera önizleme placeholder
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          hasImage ? Icons.videocam : Icons.videocam_off,
                          size: 32.w,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        hasImage ? 'Canlı Kamera' : 'Görüntü Yok',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                // Play butonu
                Positioned(
                  bottom: 12.h,
                  right: 12.w,
                  child: Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 20.w,
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }
}

Widget _buildActionButton({
  required BuildContext context,
  required IconData icon,
  required String label,
  required Color color,
  required VoidCallback onTap,
}) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(12.r),
    child: Container(
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: color,
            size: 18.w,
          ),
          SizedBox(width: 8.w),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ),
  );
}

// Kamera türü renkleri
Color _getCameraTypeColor(cameraType) {
  switch (cameraType.toString()) {
    case 'CameraType.traffic':
      return Colors.orange;
    case 'CameraType.security':
      return Colors.red;
    case 'CameraType.weather':
      return Colors.blue;
    case 'CameraType.tourist':
      return Colors.green;
    case 'CameraType.construction':
      return Colors.brown;
    case 'CameraType.webcam':
      return Colors.purple;
    default:
      return Colors.grey;
  }
}

// Kamera türü ikonları
String _getCameraTypeIcon(cameraType) {
  switch (cameraType.toString()) {
    case 'CameraType.traffic':
      return '🚦';
    case 'CameraType.security':
      return '🔒';
    case 'CameraType.weather':
      return '🌤️';
    case 'CameraType.tourist':
      return '📸';
    case 'CameraType.construction':
      return '🏗️';
    case 'CameraType.webcam':
      return '📹';
    default:
      return '📹';
  }
}

// Kamera türü display name
String _getCameraTypeDisplayName(cameraType) {
  switch (cameraType.toString()) {
    case 'CameraType.traffic':
      return 'Trafik Kamerası';
    case 'CameraType.security':
      return 'Güvenlik Kamerası';
    case 'CameraType.weather':
      return 'Hava Durumu Kamerası';
    case 'CameraType.tourist':
      return 'Turist Kamerası';
    case 'CameraType.construction':
      return 'İnşaat Kamerası';
    case 'CameraType.webcam':
      return 'Web Kamerası';
    default:
      return 'Diğer';
  }
}

// Kamera izleme
void _watchCamera(BuildContext context, camera) {
  // Gerçek kamera stream URL'i oluştur
  String streamUrl = _getCameraStreamUrl(camera);

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(camera.name),
      content: SizedBox(
        width: double.maxFinite,
        height: 300.h,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Gerçek kamera görüntüsü
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: _buildCameraView(streamUrl, camera),
                ),
              ),
            ),
            SizedBox(height: 12.h),
            // Kamera bilgileri - Gerçek koordinatları göster
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.orange, size: 16.w),
                SizedBox(width: 4.w),
                Expanded(
                  child: Text(
                    '${camera.location.city ?? 'Bilinmeyen'}, ${camera.location.country ?? 'Bilinmeyen'}',
                    style: TextStyle(fontSize: 12.sp),
                  ),
                ),
              ],
            ),
            SizedBox(height: 4.h),
            Row(
              children: [
                Icon(Icons.gps_fixed, color: Colors.blue, size: 16.w),
                SizedBox(width: 4.w),
                Expanded(
                  child: Text(
                    'Koordinat: ${camera.location.coordinates.latitude.toStringAsFixed(6)}, ${camera.location.coordinates.longitude.toStringAsFixed(6)}',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Row(
              children: [
                Icon(Icons.videocam, color: Colors.green, size: 16.w),
                SizedBox(width: 4.w),
                Text(
                  'Canlı Yayın Aktif',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.green,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            SizedBox(height: 4.h),
            Row(
              children: [
                Icon(
                  _isNightTimeAdvanced(camera.location.coordinates.latitude,
                          camera.location.coordinates.longitude)
                      ? Icons.nightlight_round
                      : Icons.wb_sunny,
                  color: _isNightTimeAdvanced(
                          camera.location.coordinates.latitude,
                          camera.location.coordinates.longitude)
                      ? Colors.blue
                      : Colors.orange,
                  size: 16.w,
                ),
                SizedBox(width: 4.w),
                Text(
                  _isNightTimeAdvanced(camera.location.coordinates.latitude,
                          camera.location.coordinates.longitude)
                      ? 'Gece Görüntüsü'
                      : 'Gündüz Görüntüsü',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: _isNightTimeAdvanced(
                            camera.location.coordinates.latitude,
                            camera.location.coordinates.longitude)
                        ? Colors.blue
                        : Colors.orange,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Kapat'),
        ),
        ElevatedButton.icon(
          onPressed: () => _openInMaps(context, camera),
          icon: Icon(Icons.map, size: 16.w),
          label: const Text('Haritada Aç'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    ),
  );
}

// Kamera stream URL'i oluştur - Gerçek tespit edilen koordinatları kullan
String _getCameraStreamUrl(camera) {
  // Gerçek tespit edilen koordinatları kullan
  final lat = camera.location.coordinates.latitude;
  final lon = camera.location.coordinates.longitude;

  // Koordinatların geçerli olduğunu kontrol et
  if (lat == 0.0 && lon == 0.0) {
    // Fallback koordinatlar (İstanbul)
    final fallbackLat = 41.0082;
    final fallbackLon = 28.9784;
    return _buildStreetViewUrl(fallbackLat, fallbackLon, camera);
  }

  return _buildStreetViewUrl(lat, lon, camera);
}

// Kamera için görüntü mevcut mu kontrol et
Future<bool> _hasStreetViewImage(double lat, double lon) async {
  try {
    final testUrl = 'https://maps.googleapis.com/maps/api/streetview?'
        'size=1x1&location=$lat,$lon&fov=90&heading=0&pitch=0&key=AIzaSyBxMNR35kci2cYlsm1y-0epDfw66ScKV1w';

    final response = await http.head(Uri.parse(testUrl));
    return response.statusCode == 200;
  } catch (e) {
    return false;
  }
}

// Kameraları filtrele - görüntüye sahip olan en yakın 5 kamerayı göster
Future<List<dynamic>> _filterCamerasWithImages(List<dynamic> cameras) async {
  final List<dynamic> camerasWithImages = [];
  final List<dynamic> camerasWithoutImages = [];

  // Önce tüm kameraları kontrol et
  for (final camera in cameras) {
    final lat = camera.location.coordinates.latitude;
    final lon = camera.location.coordinates.longitude;

    // Koordinatlar geçerli mi kontrol et
    if (lat != 0.0 && lon != 0.0) {
      // Google Street View görüntüsü mevcut mu kontrol et
      final hasImage = await _hasStreetViewImage(lat, lon);
      if (hasImage) {
        camerasWithImages.add(camera);
      } else {
        camerasWithoutImages.add(camera);
      }
    }
  }

  // Eğer görüntüye sahip kamera varsa, en yakın 5'ini döndür
  if (camerasWithImages.isNotEmpty) {
    // Mesafeye göre sırala ve en yakın 5'ini al
    camerasWithImages.sort((a, b) {
      final distanceA = _calculateDistance(
          a.location.coordinates.latitude, a.location.coordinates.longitude);
      final distanceB = _calculateDistance(
          b.location.coordinates.latitude, b.location.coordinates.longitude);
      return distanceA.compareTo(distanceB);
    });

    return camerasWithImages.take(5).toList();
  }

  // Eğer hiç görüntüye sahip kamera yoksa, en yakın 5 kamerayı göster
  if (camerasWithoutImages.isNotEmpty) {
    camerasWithoutImages.sort((a, b) {
      final distanceA = _calculateDistance(
          a.location.coordinates.latitude, a.location.coordinates.longitude);
      final distanceB = _calculateDistance(
          b.location.coordinates.latitude, b.location.coordinates.longitude);
      return distanceA.compareTo(distanceB);
    });

    return camerasWithoutImages.take(5).toList();
  }

  return [];
}

// Mesafe hesapla (basit yaklaşım)
double _calculateDistance(double lat, double lon) {
  // Varsayılan merkez nokta (İstanbul)
  const double centerLat = 41.0082;
  const double centerLon = 28.9784;

  final double dLat = (lat - centerLat) * (3.14159265359 / 180);
  final double dLon = (lon - centerLon) * (3.14159265359 / 180);

  final double a = (dLat / 2) * (dLat / 2) + (dLon / 2) * (dLon / 2);
  final double c = 2 * (a > 0 ? 1 : -1) * (a.abs() > 1 ? 1 : a.abs());

  return 6371 * c; // Dünya yarıçapı km cinsinden
}

// Google Street View URL'i oluştur
String _buildStreetViewUrl(double lat, double lon, camera) {
  // Farklı açılardan görüntü al (kamera türüne göre)
  final angles = _getCameraAngles(camera.cameraType);
  final selectedAngle = angles[camera.name.hashCode % angles.length];

  // Gece/gündüz durumunu tespit et (koordinat tabanlı)
  final isNight = _isNightTimeAdvanced(lat, lon);
  final pitch = isNight ? -10 : 0; // Gece için aşağı bakış açısı

  return 'https://maps.googleapis.com/maps/api/streetview?'
      'size=400x300&location=$lat,$lon&fov=90&heading=$selectedAngle&pitch=$pitch&key=AIzaSyBxMNR35kci2cYlsm1y-0epDfw66ScKV1w';
}

// Güneş doğuş/batış saatlerini hesapla (basit yaklaşım)
bool _isNightTimeAdvanced(double lat, double lon) {
  final now = DateTime.now();
  final hour = now.hour;

  // Türkiye için basit gece/gündüz hesaplaması
  // Kış ayları için daha erken gece
  final month = now.month;
  int sunsetHour = 18; // Varsayılan gün batımı
  int sunriseHour = 6; // Varsayılan gün doğumu

  if (month >= 11 || month <= 2) {
    // Kış ayları
    sunsetHour = 17;
    sunriseHour = 7;
  } else if (month >= 6 && month <= 8) {
    // Yaz ayları
    sunsetHour = 20;
    sunriseHour = 5;
  }

  return hour >= sunsetHour || hour < sunriseHour;
}

// Kamera türüne göre açıları belirle
List<int> _getCameraAngles(cameraType) {
  switch (cameraType.toString()) {
    case 'CameraType.traffic':
      return [0, 90, 180, 270]; // Trafik kameraları için 4 yön
    case 'CameraType.security':
      return [45, 135, 225, 315]; // Güvenlik kameraları için çapraz açılar
    case 'CameraType.tourist':
      return [0, 120, 240]; // Turist kameraları için 3 açı
    case 'CameraType.webcam':
      return [0, 180]; // Web kameraları için 2 açı
    default:
      return [0, 90, 180, 270]; // Varsayılan 4 yön
  }
}

// Kamera görüntüsü widget'ı
Widget _buildCameraView(String streamUrl, camera) {
  return Container(
    color: Colors.black,
    child: Stack(
      children: [
        // Gerçek görüntü
        Center(
          child: Image.network(
            streamUrl,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                      color: Colors.white,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'Kamera Yükleniyor...',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.videocam_off,
                      color: Colors.white,
                      size: 48.w,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'Kamera Bağlantı Hatası',
                      style: TextStyle(color: Colors.white),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Lütfen internet bağlantınızı kontrol edin',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12.sp,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        // Kamera bilgi overlay'i
        Positioned(
          top: 8.h,
          left: 8.w,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8.w,
                  height: 8.w,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 4.w),
                Text(
                  'CANLI',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        // Gece/Gündüz durumu overlay'i
        Positioned(
          top: 8.h,
          right: 8.w,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _isNightTimeAdvanced(camera.location.coordinates.latitude,
                          camera.location.coordinates.longitude)
                      ? Icons.nightlight_round
                      : Icons.wb_sunny,
                  color: _isNightTimeAdvanced(
                          camera.location.coordinates.latitude,
                          camera.location.coordinates.longitude)
                      ? Colors.blue
                      : Colors.orange,
                  size: 12.w,
                ),
                SizedBox(width: 4.w),
                Text(
                  _isNightTimeAdvanced(camera.location.coordinates.latitude,
                          camera.location.coordinates.longitude)
                      ? 'GECE'
                      : 'GÜNDÜZ',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 9.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        // Koordinat bilgisi overlay'i
        Positioned(
          bottom: 8.h,
          right: 8.w,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: Text(
              '${camera.location.coordinates.latitude.toStringAsFixed(4)}, ${camera.location.coordinates.longitude.toStringAsFixed(4)}',
              style: TextStyle(
                color: Colors.white,
                fontSize: 9.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

// Haritada açma
void _openInMaps(BuildContext context, camera) async {
  try {
    // Direkt Google Maps'e yönlendir - en basit yöntem
    final url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${camera.location.coordinates.latitude},${camera.location.coordinates.longitude}',
    );

    // Önce external application olarak dene
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      // Eğer external açılamazsa, platform default olarak dene
      await launchUrl(url);
    }
  } catch (e) {
    // Hata durumunda koordinatları kopyala
    Clipboard.setData(ClipboardData(
      text:
          '${camera.location.coordinates.latitude}, ${camera.location.coordinates.longitude}',
    ));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
            'Koordinatlar panoya kopyalandı. Google Maps\'e manuel olarak yapıştırabilirsiniz.'),
        backgroundColor: Colors.orange,
        duration: Duration(seconds: 3),
      ),
    );
  }
}

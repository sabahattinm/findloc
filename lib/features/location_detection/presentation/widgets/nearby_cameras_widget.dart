import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

import '../bloc/location_detection_bloc.dart';

/// Widget to display nearby cameras
class NearbyCamerasWidget extends StatelessWidget {
  const NearbyCamerasWidget({super.key});

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
            padding: EdgeInsets.all(32.w),
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
            'Kameralar Yükleniyor...',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Yakındaki canlı kameralar aranıyor',
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
                ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Bu bölgede canlı kamera bulunmuyor.\nBaşka bir konum deneyin.',
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
              Icons.videocam,
              size: 64.w,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            'Canlı Kameralar',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Konum tespit ettikten sonra\nyakındaki kameraları görüntüleyebilirsiniz',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),
          ElevatedButton.icon(
            onPressed: () {
              // Navigate to detection tab
            },
            icon: const Icon(Icons.camera_alt),
            label: const Text('Konum Tespit Et'),
          ),
        ],
      ),
    );
  }

  Widget _buildCamerasList(BuildContext context, cameras) {
    return Column(
      children: [
        _buildHeader(context, cameras.length),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.all(16.w),
            itemCount: cameras.length,
            itemBuilder: (context, index) {
              final camera = cameras[index];
              return _buildCameraItem(context, camera);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, int cameraCount) {
    return Container(
      padding: EdgeInsets.all(16.w),
      child: Row(
        children: [
          Text(
            'Canlı Kameralar',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const Spacer(),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              '$cameraCount kamera',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraItem(BuildContext context, camera) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCameraThumbnail(context, camera),
            _buildCameraInfo(context, camera),
            _buildCameraActions(context, camera),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraThumbnail(BuildContext context, camera) {
    return Container(
      height: 200.h,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.r),
          topRight: Radius.circular(16.r),
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.1),
            Theme.of(context).colorScheme.secondary.withOpacity(0.1),
          ],
        ),
      ),
      child: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.videocam,
                    size: 32.w,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Canlı Yayın',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 12.h,
            right: 12.w,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: camera.isActive ? Colors.green : Colors.red,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6.w,
                    height: 6.w,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    camera.isActive ? 'Canlı' : 'Offline',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraInfo(BuildContext context, camera) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  camera.cameraType.icon,
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
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      camera.cameraType.displayName,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.6),
                          ),
                    ),
                    if (camera.description != null &&
                        camera.description!.contains('kamerası')) ...[
                      SizedBox(height: 4.h),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 8.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: _getSourceColorFromDescription(
                                  camera.description!)
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: _getSourceColorFromDescription(
                                    camera.description!)
                                .withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          _getSourceDisplayNameFromDescription(
                              camera.description!),
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w500,
                            color: _getSourceColorFromDescription(
                                camera.description!),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (camera.description != null) ...[
            SizedBox(height: 12.h),
            Text(
              camera.description!,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
          SizedBox(height: 12.h),
          Row(
            children: [
              Icon(
                Icons.location_on,
                size: 16.w,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: Text(
                  camera.location.address,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.5),
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          if (camera.resolution != null) ...[
            SizedBox(height: 8.h),
            Row(
              children: [
                Icon(
                  Icons.high_quality,
                  size: 16.w,
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                ),
                SizedBox(width: 4.w),
                Text(
                  camera.resolution!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.5),
                      ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCameraActions(BuildContext context, camera) {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.w),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: camera.isActive
                  ? () => _openCameraStream(context, camera)
                  : null,
              icon: const Icon(Icons.play_arrow),
              label: const Text('Canlı İzle'),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _openInMaps(context, camera),
              icon: const Icon(Icons.map),
              label: const Text('Haritada Gör'),
            ),
          ),
        ],
      ),
    );
  }

  void _openCameraStream(BuildContext context, camera) {
    // Navigate to camera stream page
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Canlı Yayın'),
        content: Text('${camera.name} canlı yayını açılıyor...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

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
        SnackBar(
          content: const Text(
              'Koordinatlar panoya kopyalandı. Google Maps\'e manuel olarak yapıştırabilirsiniz.'),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _showMapErrorDialog(BuildContext context, camera, String? errorMessage) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Harita Açılamadı'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Harita uygulaması açılamadı. Alternatif seçenekler:'),
            const SizedBox(height: 16),
            Text(
              'Koordinatlar: ${camera.coordinates.latitude}, ${camera.coordinates.longitude}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            if (errorMessage != null) ...[
              const SizedBox(height: 8),
              Text(
                'Hata: $errorMessage',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Kapat'),
          ),
          ElevatedButton(
            onPressed: () {
              // Copy coordinates to clipboard
              Clipboard.setData(ClipboardData(
                text:
                    '${camera.coordinates.latitude}, ${camera.coordinates.longitude}',
              ));
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Koordinatlar panoya kopyalandı'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Kopyala'),
          ),
          ElevatedButton(
            onPressed: () {
              // Try to open in browser
              Navigator.of(context).pop();
              _openInBrowser(context, camera);
            },
            child: const Text('Tarayıcıda Aç'),
          ),
        ],
      ),
    );
  }

  void _openInBrowser(BuildContext context, camera) async {
    try {
      // Try multiple URL formats
      final List<String> urls = [
        'https://www.google.com/maps/search/?api=1&query=${camera.coordinates.latitude},${camera.coordinates.longitude}',
        'https://maps.google.com/maps?q=${camera.coordinates.latitude},${camera.coordinates.longitude}',
        'https://www.google.com/maps/@${camera.coordinates.latitude},${camera.coordinates.longitude},15z',
        'https://www.google.com/maps?ll=${camera.coordinates.latitude},${camera.coordinates.longitude}&z=15',
      ];

      bool launched = false;
      String? errorMessage;

      for (final urlString in urls) {
        try {
          final url = Uri.parse(urlString);

          // Try different launch modes
          final List<LaunchMode> modes = [
            LaunchMode.externalApplication,
            LaunchMode.externalNonBrowserApplication,
            LaunchMode.platformDefault,
          ];

          for (final mode in modes) {
            try {
              if (await canLaunchUrl(url)) {
                await launchUrl(url, mode: mode);
                launched = true;
                break;
              }
            } catch (e) {
              errorMessage = e.toString();
              continue;
            }
          }

          if (launched) break;
        } catch (e) {
          errorMessage = e.toString();
          continue;
        }
      }

      if (!launched) {
        // Show detailed error with coordinates
        _showBrowserErrorDialog(context, camera, errorMessage);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Beklenmeyen hata: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showBrowserErrorDialog(
      BuildContext context, camera, String? errorMessage) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tarayıcı Açılamadı'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Tarayıcı açılamadı. Alternatif seçenekler:'),
            const SizedBox(height: 16),
            Text(
              'Koordinatlar: ${camera.coordinates.latitude}, ${camera.coordinates.longitude}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
                'Manuel olarak Google Maps\'e gidip koordinatları arayabilirsiniz.'),
            if (errorMessage != null) ...[
              const SizedBox(height: 8),
              Text(
                'Hata: $errorMessage',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Kapat'),
          ),
          ElevatedButton(
            onPressed: () {
              // Copy coordinates to clipboard
              Clipboard.setData(ClipboardData(
                text:
                    '${camera.coordinates.latitude}, ${camera.coordinates.longitude}',
              ));
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Koordinatlar panoya kopyalandı'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Kopyala'),
          ),
        ],
      ),
    );
  }

  /// Get color for camera source
  Color _getSourceColor(String? source) {
    switch (source) {
      case 'insecam':
        return Colors.blue;
      case 'webcamtaxi':
        return Colors.green;
      case 'earthcam':
        return Colors.orange;
      case 'skylinewebcams':
        return Colors.purple;
      case 'mock':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  /// Get display name for camera source
  String _getSourceDisplayName(String? source) {
    switch (source) {
      case 'insecam':
        return 'Insecam';
      case 'webcamtaxi':
        return 'WebcamTaxi';
      case 'earthcam':
        return 'EarthCam';
      case 'skylinewebcams':
        return 'SkylineWebcams';
      case 'mock':
        return 'Demo';
      default:
        return 'Unknown';
    }
  }

  /// Get color for camera source from description
  Color _getSourceColorFromDescription(String description) {
    if (description.contains('insecam')) return Colors.blue;
    if (description.contains('webcamtaxi')) return Colors.green;
    if (description.contains('earthcam')) return Colors.orange;
    if (description.contains('skylinewebcams')) return Colors.purple;
    if (description.contains('mock')) return Colors.grey;
    return Colors.grey;
  }

  /// Get display name for camera source from description
  String _getSourceDisplayNameFromDescription(String description) {
    if (description.contains('insecam')) return 'Insecam';
    if (description.contains('webcamtaxi')) return 'WebcamTaxi';
    if (description.contains('earthcam')) return 'EarthCam';
    if (description.contains('skylinewebcams')) return 'SkylineWebcams';
    if (description.contains('mock')) return 'Demo';
    return 'Unknown';
  }
}

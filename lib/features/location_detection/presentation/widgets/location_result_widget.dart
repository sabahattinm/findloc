import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/domain/entities/location_entity.dart';
import '../bloc/location_detection_bloc.dart';

/// Widget to display location detection results
class LocationResultWidget extends StatelessWidget {
  const LocationResultWidget({
    super.key,
    required this.location,
    this.onNewDetection,
  });

  final LocationEntity location;
  final VoidCallback? onNewDetection;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          SizedBox(height: 16.h),
          _buildLocationCard(context),
          SizedBox(height: 16.h),
          _buildDetailsCard(context),
          SizedBox(height: 16.h),
          _buildActionsCard(context),
          SizedBox(height: 16.h),
          _buildNearbyCamerasCard(context),
          SizedBox(height: 24.h),
          _buildNewDetectionButton(context),
          SizedBox(height: 16.h),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () {
            context.read<LocationDetectionBloc>().add(const ResetState());
          },
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        Expanded(
          child: Text(
            'Konum Tespit Edildi',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: _getConfidenceColor(context, location.confidence),
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Text(
            '${(location.confidence * 100).toInt()}%',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.1),
            Theme.of(context).colorScheme.secondary.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.location_on,
                  color: Colors.white,
                  size: 20.w,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      location.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      location.address,
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
          if (location.description != null) ...[
            SizedBox(height: 12.h),
            Text(
              location.description!,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailsCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
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
          Text(
            'Detaylı Bilgiler',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          SizedBox(height: 16.h),
          _buildDetailRow(
            context,
            Icons.my_location,
            'Koordinatlar',
            '${location.coordinates.latitude.toStringAsFixed(6)}, ${location.coordinates.longitude.toStringAsFixed(6)}',
          ),
          if (location.city != null)
            _buildDetailRow(
              context,
              Icons.location_city,
              'Şehir',
              location.city!,
            ),
          if (location.country != null)
            _buildDetailRow(
              context,
              Icons.public,
              'Ülke',
              location.country!,
            ),
          if (location.region != null)
            _buildDetailRow(
              context,
              Icons.map,
              'Bölge',
              location.region!,
            ),
          if (location.postalCode != null)
            _buildDetailRow(
              context,
              Icons.local_post_office,
              'Posta Kodu',
              location.postalCode!,
            ),
          if (location.accuracy != null)
            _buildDetailRow(
              context,
              Icons.gps_fixed,
              'Doğruluk',
              '${location.accuracy!.toInt()} metre',
            ),
          _buildDetailRow(
            context,
            Icons.access_time,
            'Tespit Zamanı',
            _formatDateTime(location.detectedAt),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
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
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                Text(
                  value,
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
    );
  }

  Widget _buildActionsCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
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
          Text(
            'Eylemler',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _openInMaps(context),
                  icon: const Icon(Icons.map),
                  label: const Text('Haritada Aç'),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _shareLocation(context),
                  icon: const Icon(Icons.share),
                  label: const Text('Paylaş'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNearbyCamerasCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
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
          Row(
            children: [
              Text(
                'Yakındaki Kameralar',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  context.read<LocationDetectionBloc>().add(
                        LoadNearbyCameras(location: location),
                      );
                },
                child: const Text('Yükle'),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          BlocBuilder<LocationDetectionBloc, LocationDetectionState>(
            builder: (context, state) {
              if (state is NearbyCamerasLoaded) {
                if (state.cameras.isEmpty) {
                  return Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.videocam_off,
                          size: 48.w,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.3),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'Yakında kamera bulunamadı',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(0.6),
                                  ),
                        ),
                      ],
                    ),
                  );
                }
                return Column(
                  children: state.cameras.map((camera) {
                    return _buildCameraItem(context, camera);
                  }).toList(),
                );
              }
              return Center(
                child: Text(
                  'Yakındaki kameraları yüklemek için "Yükle" butonuna tıklayın',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.6),
                      ),
                  textAlign: TextAlign.center,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCameraItem(BuildContext context, camera) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.background,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
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
                  camera.name,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                Text(
                  camera.cameraType.displayName,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.6),
                      ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              // Open camera stream
            },
            icon: Icon(
              Icons.play_arrow,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Color _getConfidenceColor(BuildContext context, double confidence) {
    if (confidence >= 0.8) {
      return Colors.green;
    } else if (confidence >= 0.6) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _openInMaps(BuildContext context) async {
    try {
      // Direkt Google Maps'e yönlendir - en basit yöntem
      final url = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=${location.coordinates.latitude},${location.coordinates.longitude}',
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
            '${location.coordinates.latitude}, ${location.coordinates.longitude}',
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

  void _showMapErrorDialog(BuildContext context, String? errorMessage) {
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
              'Koordinatlar: ${location.coordinates.latitude}, ${location.coordinates.longitude}',
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
                    '${location.coordinates.latitude}, ${location.coordinates.longitude}',
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
              _openInBrowser(context);
            },
            child: const Text('Tarayıcıda Aç'),
          ),
        ],
      ),
    );
  }

  void _openInBrowser(BuildContext context) async {
    try {
      // Try multiple URL formats
      final List<String> urls = [
        'https://www.google.com/maps/search/?api=1&query=${location.coordinates.latitude},${location.coordinates.longitude}',
        'https://maps.google.com/maps?q=${location.coordinates.latitude},${location.coordinates.longitude}',
        'https://www.google.com/maps/@${location.coordinates.latitude},${location.coordinates.longitude},15z',
        'https://www.google.com/maps?ll=${location.coordinates.latitude},${location.coordinates.longitude}&z=15',
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
        _showBrowserErrorDialog(context, errorMessage);
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

  void _showBrowserErrorDialog(BuildContext context, String? errorMessage) {
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
              'Koordinatlar: ${location.coordinates.latitude}, ${location.coordinates.longitude}',
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
                    '${location.coordinates.latitude}, ${location.coordinates.longitude}',
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

  void _shareLocation(BuildContext context) {
    try {
      final text = '''
📍 ${location.name}
${location.address}
Koordinatlar: ${location.coordinates.latitude}, ${location.coordinates.longitude}
Google Maps: https://www.google.com/maps?q=${location.coordinates.latitude},${location.coordinates.longitude}

FindLoc ile tespit edildi.
      ''';

      Share.share(
        text,
        subject: 'Konum Paylaşımı - ${location.name}',
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Paylaşım hatası: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildNewDetectionButton(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.camera_alt_rounded,
            size: 32.w,
            color: Colors.white,
          ),
          SizedBox(height: 12.h),
          Text(
            'Yeni Konum Tespit Et',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Başka bir görsel ile konum tespit etmek için tıklayın',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withOpacity(0.9),
                ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16.h),
          ElevatedButton.icon(
            onPressed: () {
              // Yeni tespit için tespit sekmesine geç
              onNewDetection?.call();
            },
            icon: const Icon(Icons.add_rounded),
            label: const Text('Yeni Tespit Başlat'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Theme.of(context).colorScheme.primary,
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              elevation: 2,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../bloc/live_camera_bloc.dart';
import '../../../../core/domain/entities/live_camera_entity.dart';
import 'camera_stream_widget.dart';

/// Widget for displaying live cameras
class LiveCameraWidget extends StatelessWidget {
  const LiveCameraWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LiveCameraBloc, LiveCameraState>(
      listener: (context, state) {
        if (state is LiveCameraError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Theme.of(context).colorScheme.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is LiveCameraLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (state is LiveCameraLoaded) {
          return _buildCameraList(context, state.cameras);
        }

        return _buildEmptyState(context);
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.videocam_off,
            size: 64.w,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
          ),
          SizedBox(height: 16.h),
          Text(
            'Henüz kamera bulunamadı',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Konum tespit ettikten sonra yakındaki kameraları görebilirsiniz',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCameraList(BuildContext context, List<LiveCameraEntity> cameras) {
    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: cameras.length,
      itemBuilder: (context, index) {
        final camera = cameras[index];
        return _buildCameraCard(context, camera);
      },
    );
  }

  Widget _buildCameraCard(BuildContext context, LiveCameraEntity camera) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      child: GlassmorphicContainer(
        width: double.infinity,
        height: 200.h,
        borderRadius: 20.r,
        blur: 20,
        alignment: Alignment.bottomCenter,
        border: 2,
        linearGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
        ),
        borderGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.5),
            Colors.white.withOpacity(0.2),
          ],
        ),
        child: InkWell(
          onTap: () => _showCameraStream(context, camera),
          borderRadius: BorderRadius.circular(20.r),
          child: Container(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        camera.cameraType.icon,
                        style: TextStyle(fontSize: 16.w),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            camera.name,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            camera.cameraType.displayName,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildStatusIndicator(context, camera.isActive),
                  ],
                ),
                SizedBox(height: 12.h),
                if (camera.description != null) ...[
                  Text(
                    camera.description!,
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8.h),
                ],
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 16.w,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: Text(
                        camera.location.name,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (camera.resolution != null) ...[
                      SizedBox(width: 8.w),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          camera.resolution!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 16.w,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      _formatLastUpdated(camera.lastUpdated),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                    const Spacer(),
                    if (camera.thumbnailUrl != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.r),
                        child: CachedNetworkImage(
                          imageUrl: camera.thumbnailUrl!,
                          width: 60.w,
                          height: 40.h,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            width: 60.w,
                            height: 40.h,
                            color: Theme.of(context).colorScheme.surface,
                            child: Icon(
                              Icons.image,
                              size: 20.w,
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            width: 60.w,
                            height: 40.h,
                            color: Theme.of(context).colorScheme.surface,
                            child: Icon(
                              Icons.error,
                              size: 20.w,
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(BuildContext context, bool isActive) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: isActive 
            ? Colors.green.withOpacity(0.2)
            : Colors.red.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6.w,
            height: 6.w,
            decoration: BoxDecoration(
              color: isActive ? Colors.green : Colors.red,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 4.w),
          Text(
            isActive ? 'Aktif' : 'Pasif',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: isActive ? Colors.green : Colors.red,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _formatLastUpdated(DateTime? lastUpdated) {
    if (lastUpdated == null) return 'Bilinmiyor';
    
    final now = DateTime.now();
    final difference = now.difference(lastUpdated);
    
    if (difference.inMinutes < 1) {
      return 'Az önce';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} dakika önce';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} saat önce';
    } else {
      return '${difference.inDays} gün önce';
    }
  }

  void _showCameraStream(BuildContext context, LiveCameraEntity camera) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CameraStreamWidget(camera: camera),
    );
  }
}

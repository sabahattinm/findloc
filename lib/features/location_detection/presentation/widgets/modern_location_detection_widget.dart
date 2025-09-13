import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../bloc/location_detection_bloc.dart';
import 'location_result_widget.dart';
import 'blurred_location_result_widget.dart';
import 'image_analysis_widget.dart';
import '../../../../core/theme/app_theme.dart';

/// Modern Location Detection Widget
class ModernLocationDetectionWidget extends StatefulWidget {
  const ModernLocationDetectionWidget({super.key});

  @override
  State<ModernLocationDetectionWidget> createState() =>
      _ModernLocationDetectionWidgetState();
}

class _ModernLocationDetectionWidgetState
    extends State<ModernLocationDetectionWidget> {
  bool _isDetailedAnalysis = true;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LocationDetectionBloc, LocationDetectionState>(
      listener: (context, state) {
        if (state is LocationDetectionError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppTheme.errorColor,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is LocationDetectionSuccess) {
          return LocationResultWidget(location: state.location);
        }

        if (state is LocationDetectionBlurred) {
          return BlurredLocationResultWidget(location: state.location);
        }

        if (state is LocationDetectionLoading) {
          return ImageAnalysisWidget(
            imagePath: state.imagePath ?? 'assets/images/placeholder.jpg',
            isDetailedAnalysis: _isDetailedAnalysis,
            onComplete: () {
              // Animation completed, but actual API call might still be running
            },
          );
        }

        return _buildMainContent(context);
      },
    );
  }

  Widget _buildMainContent(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeSection(context),
          SizedBox(height: 24.h),
          _buildActionCards(context),
          SizedBox(height: 24.h),
          _buildUrlInputSection(context),
          SizedBox(height: 24.h),
          _buildNearbyCamerasSection(context),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hoş Geldiniz',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onSurface,
              ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Fotoğrafınızı yükleyin veya sosyal medya linkini paylaşın.\nAI teknolojisi ile konumunu tespit edelim.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                height: 1.5,
              ),
        ),
      ],
    );
  }

  Widget _buildActionCards(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                context: context,
                icon: Icons.camera_alt_rounded,
                title: 'Kamera',
                subtitle: 'Fotoğraf çek',
                gradient: [AppTheme.primaryBlue, AppTheme.primaryBlueLight],
                onTap: () {
                  context.read<LocationDetectionBloc>().add(
                        PickImageFromCamera(),
                      );
                },
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: _buildActionCard(
                context: context,
                icon: Icons.photo_library_rounded,
                title: 'Galeri',
                subtitle: 'Fotoğraf seç',
                gradient: [
                  AppTheme.secondaryPurple,
                  AppTheme.secondaryPurpleLight
                ],
                onTap: () {
                  context.read<LocationDetectionBloc>().add(
                        PickImageFromGallery(),
                      );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required List<Color> gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradient,
          ),
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: gradient.first.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 32.w,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 14.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUrlInputSection(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: AppTheme.accentGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  Icons.link_rounded,
                  color: AppTheme.accentGreen,
                  size: 20.w,
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                'Sosyal Medya Linki',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Text(
            'Instagram, Twitter veya Facebook linkini yapıştırın',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
          ),
          SizedBox(height: 8.h),
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(
                color: Colors.orange.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.orange,
                  size: 16.w,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    'Instagram linkleri için görseli indirip galeriden seçmeniz önerilir',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.orange.shade700,
                          fontSize: 11.sp,
                        ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          _buildUrlInput(context),
        ],
      ),
    );
  }

  Widget _buildUrlInput(BuildContext context) {
    final TextEditingController urlController = TextEditingController();

    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: urlController,
            decoration: InputDecoration(
              hintText: 'https://instagram.com/p/...',
              hintStyle: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              ),
              prefixIcon: Icon(
                Icons.paste_rounded,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                size: 20.w,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(
                  color: AppTheme.accentGreen,
                  width: 2,
                ),
              ),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.accentGreen,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: IconButton(
            onPressed: () {
              if (urlController.text.isNotEmpty) {
                // Instagram URL kontrolü (geçici olarak devre dışı)
                // if (_isInstagramUrl(urlController.text)) {
                //   ScaffoldMessenger.of(context).showSnackBar(
                //     SnackBar(
                //       content: const Text(
                //         'Instagram linkleri desteklenmiyor. Lütfen görseli indirip galeriden seçin.',
                //       ),
                //       backgroundColor: Colors.orange,
                //       duration: const Duration(seconds: 4),
                //       action: SnackBarAction(
                //         label: 'Tamam',
                //         textColor: Colors.white,
                //         onPressed: () {},
                //       ),
                //     ),
                //   );
                //   return;
                // }

                context.read<LocationDetectionBloc>().add(
                      DetectLocationFromUrl(
                        imageUrl: urlController.text,
                        isDetailedAnalysis: _isDetailedAnalysis,
                      ),
                    );
              }
            },
            icon: Icon(
              Icons.arrow_forward_rounded,
              color: Colors.white,
              size: 20.w,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNearbyCamerasSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.videocam_rounded,
              color: Theme.of(context).colorScheme.primary,
              size: 24.w,
            ),
            SizedBox(width: 12.w),
            Text(
              'Yakındaki Kameralar',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(
                    Icons.location_on_rounded,
                    color: Colors.orange,
                    size: 20.w,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      'Mevcut konumunuzdaki canlı kameraları görüntüleyin',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.8),
                          ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Kameralar sekmesine geç - PageView kullanıyoruz
                        // Bu buton sadece bilgilendirme amaçlı
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Kameralar sekmesine geçmek için alt menüyü kullanın'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      icon: Icon(Icons.videocam_rounded, size: 18.w),
                      label: const Text('Kameraları Görüntüle'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // Demo kameraları yükle
                        context.read<LocationDetectionBloc>().add(
                              const LoadDemoCameras(),
                            );
                      },
                      icon: Icon(Icons.play_circle_outline_rounded, size: 18.w),
                      label: const Text('Demo Kameralar'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.primary,
                        side: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

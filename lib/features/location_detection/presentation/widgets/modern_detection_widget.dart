import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/modern_theme.dart';
import '../bloc/location_detection_bloc.dart';
import 'modern_analysis_widget.dart';

/// Modern tespit widget'ı
class ModernDetectionWidget extends StatefulWidget {
  const ModernDetectionWidget({super.key});

  @override
  State<ModernDetectionWidget> createState() => _ModernDetectionWidgetState();
}

class _ModernDetectionWidgetState extends State<ModernDetectionWidget>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _floatController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _floatController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _floatAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    _pulseController.repeat(reverse: true);
    _floatController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocationDetectionBloc, LocationDetectionState>(
      builder: (context, state) {
        if (state is LocationDetectionLoading) {
          return ModernAnalysisWidget();
        }

        return SingleChildScrollView(
          padding: EdgeInsets.all(20.w),
          child: Column(
            children: [
              SizedBox(height: 40.h),
              _buildHeroSection(),
              SizedBox(height: 60.h),
              _buildActionButtons(),
              SizedBox(height: 40.h),
              _buildFeaturesSection(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeroSection() {
    return Column(
      children: [
        // Ana icon
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimation.value,
              child: ModernTheme.glowContainer(
                glowColor: ModernTheme.primaryGreen,
                child: Container(
                  width: 120.w,
                  height: 120.w,
                  decoration: BoxDecoration(
                    gradient: ModernTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(30.r),
                    boxShadow: [
                      BoxShadow(
                        color: ModernTheme.primaryGreen.withOpacity(0.3),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.camera_alt_rounded,
                    color: Colors.white,
                    size: 50.w,
                  ),
                ),
              ),
            );
          },
        ),
        SizedBox(height: 32.h),

        // Başlık
        Text(
          'Konum Tespit Et',
          style: TextStyle(
            color: Colors.white,
            fontSize: 32.sp,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 16.h),

        // Açıklama
        Text(
          'Bir görsel yükleyin ve AI ile konumunu tespit edin',
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 16.sp,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Kamera butonu
        ModernTheme.gradientButton(
          text: 'Kameradan Çek',
          icon: Icons.camera_alt_rounded,
          onPressed: () => _pickImage(ImageSource.camera),
          width: double.infinity,
          height: 60.h,
        ),
        SizedBox(height: 16.h),

        // Galeri butonu
        Container(
          width: double.infinity,
          height: 60.h,
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
              onTap: () => _pickImage(ImageSource.gallery),
              borderRadius: BorderRadius.circular(16.r),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.photo_library_rounded,
                    color: Colors.white,
                    size: 20.w,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'Galeriden Seç',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: 16.h),

        // URL butonu
        Container(
          width: double.infinity,
          height: 60.h,
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
              onTap: () => _showUrlDialog(),
              borderRadius: BorderRadius.circular(16.r),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.link_rounded,
                    color: Colors.white,
                    size: 20.w,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'URL ile Tespit Et',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturesSection() {
    return ModernTheme.gradientContainer(
      padding: EdgeInsets.all(24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Özellikler',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20.h),
          _buildFeatureItem(
            Icons.auto_awesome_rounded,
            'AI Destekli Analiz',
            'Gelişmiş yapay zeka ile hassas konum tespiti',
          ),
          SizedBox(height: 16.h),
          _buildFeatureItem(
            Icons.speed_rounded,
            'Hızlı Sonuçlar',
            'Saniyeler içinde konum bilgisi alın',
          ),
          SizedBox(height: 16.h),
          _buildFeatureItem(
            Icons.videocam_rounded,
            'Canlı Kameralar',
            'Tespit edilen konumdaki canlı kameraları görün',
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String description) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            gradient: ModernTheme.primaryGradient,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Icon(
            icon,
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
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                description,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14.sp,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _pickImage(ImageSource source) {
    context.read<LocationDetectionBloc>().add(PickImageFromCamera());
  }

  void _showUrlDialog() {
    final TextEditingController urlController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF16213E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: Text(
          'URL ile Tespit Et',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: TextField(
          controller: urlController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Görsel URL\'sini girin',
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: ModernTheme.primaryBlue),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'İptal',
              style: TextStyle(color: Colors.white.withOpacity(0.7)),
            ),
          ),
          ModernTheme.gradientButton(
            text: 'Tespit Et',
            onPressed: () {
              if (urlController.text.isNotEmpty) {
                context.read<LocationDetectionBloc>().add(
                      DetectLocationFromUrl(imageUrl: urlController.text),
                    );
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_theme.dart';

/// Widget for showing analysis animation on top of the uploaded image
class ImageAnalysisWidget extends StatefulWidget {
  final String imagePath;
  final VoidCallback? onComplete;
  final bool isDetailedAnalysis;

  const ImageAnalysisWidget({
    super.key,
    required this.imagePath,
    this.onComplete,
    this.isDetailedAnalysis = true,
  });

  @override
  State<ImageAnalysisWidget> createState() => _ImageAnalysisWidgetState();
}

class _ImageAnalysisWidgetState extends State<ImageAnalysisWidget>
    with TickerProviderStateMixin {
  late AnimationController _scanController;
  late AnimationController _pulseController;
  late AnimationController _progressController;
  late AnimationController _stepController;

  late Animation<double> _scanAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _progressAnimation;
  late Animation<double> _stepAnimation;

  int _currentStep = 0;
  late List<AnalysisStep> _analysisSteps;

  @override
  void initState() {
    super.initState();
    _initializeAnalysisSteps();
    _initializeAnimations();
    _startAnalysis();
  }

  void _initializeAnalysisSteps() {
    if (widget.isDetailedAnalysis) {
      _analysisSteps = [
        AnalysisStep(
          title: 'Görsel Analiz Ediliyor',
          description: 'Fotoğraf kalitesi ve içerik kontrol ediliyor',
          icon: Icons.image_rounded,
          duration: 3.0,
        ),
        AnalysisStep(
          title: 'Mimari Özellikler',
          description: 'Binalar ve yapılar detaylı inceleniyor',
          icon: Icons.architecture_rounded,
          duration: 3.5,
        ),
        AnalysisStep(
          title: 'Yol ve Trafik',
          description: 'Kesişimler ve trafik işaretleri analiz ediliyor',
          icon: Icons.traffic_rounded,
          duration: 3.0,
        ),
        AnalysisStep(
          title: 'Coğrafi İpuçları',
          description: 'Doğal özellikler ve çevre taranıyor',
          icon: Icons.landscape_rounded,
          duration: 3.0,
        ),
        AnalysisStep(
          title: 'Kültürel Özellikler',
          description: 'Yazılar ve işaretler okunuyor',
          icon: Icons.language_rounded,
          duration: 2.5,
        ),
        AnalysisStep(
          title: 'Konum Hesaplanıyor',
          description: 'Koordinatlar ve adres belirleniyor',
          icon: Icons.location_on_rounded,
          duration: 3.0,
        ),
      ];
    } else {
      _analysisSteps = [
        AnalysisStep(
          title: 'Görsel Yükleniyor',
          description: 'Fotoğraf işleniyor',
          icon: Icons.image_rounded,
          duration: 3.0,
        ),
        AnalysisStep(
          title: 'Temel Analiz',
          description: 'Ana özellikler tespit ediliyor',
          icon: Icons.search_rounded,
          duration: 4.0,
        ),
        AnalysisStep(
          title: 'Konum Bulunuyor',
          description: 'Koordinatlar hesaplanıyor',
          icon: Icons.location_on_rounded,
          duration: 4.0,
        ),
      ];
    }
  }

  void _initializeAnimations() {
    // Scan line animation
    _scanController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _scanAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scanController,
      curve: Curves.easeInOut,
    ));

    // Pulse animation for active elements
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Progress animation
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeOut,
    ));

    // Step transition animation
    _stepController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _stepAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _stepController,
      curve: Curves.easeInOut,
    ));

    _pulseController.repeat(reverse: true);
  }

  void _startAnalysis() async {
    for (int i = 0; i < _analysisSteps.length; i++) {
      setState(() {
        _currentStep = i;
      });

      _stepController.reset();
      _stepController.forward();

      // Start scan animation for this step
      _scanController.reset();
      _scanController.forward();

      // Wait for step duration
      await Future.delayed(
          Duration(milliseconds: (_analysisSteps[i].duration * 1000).round()));
    }

    // Complete analysis
    widget.onComplete?.call();
  }

  @override
  void dispose() {
    _scanController.dispose();
    _pulseController.dispose();
    _progressController.dispose();
    _stepController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: AbsorbPointer(
          absorbing: false, // Allow header interactions
          child: Column(
            children: [
              // Header with back button
              _buildHeader(),

              // Image container with fixed aspect ratio
              Expanded(
                child: Center(
                  child: AbsorbPointer(
                    absorbing: true, // Block all interactions on image area
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.9,
                      height: MediaQuery.of(context).size.height * 0.5,
                      child: Stack(
                        children: [
                          // Background image
                          _buildBackgroundImage(),

                          // Dark overlay
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                          ),

                          // Analysis overlays
                          _buildAnalysisOverlays(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Progress indicator
              _buildProgressIndicator(),

              SizedBox(height: 20.h),

              // Step information
              _buildStepInfo(),

              SizedBox(height: 40.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.all(20.w),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: Icon(
              Icons.arrow_back_ios_rounded,
              color: Colors.white,
              size: 24.w,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Text(
              'Konum Analizi',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: AppTheme.primaryBlue.withOpacity(0.5),
                width: 1,
              ),
            ),
            child: Text(
              widget.isDetailedAnalysis ? 'Detaylı' : 'Hızlı',
              style: TextStyle(
                color: AppTheme.primaryBlue,
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundImage() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: widget.imagePath.startsWith('http')
            ? Image.network(
                widget.imagePath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: Icon(
                      Icons.image_not_supported_rounded,
                      size: 100.w,
                      color: Colors.grey[600],
                    ),
                  );
                },
              )
            : Image.file(
                File(widget.imagePath),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: Icon(
                      Icons.image_not_supported_rounded,
                      size: 100.w,
                      color: Colors.grey[600],
                    ),
                  );
                },
              ),
      ),
    );
  }

  Widget _buildAnalysisOverlays() {
    return AnimatedBuilder(
      animation: _scanAnimation,
      builder: (context, child) {
        return Stack(
          children: [
            // Scan line
            Positioned(
              top: _scanAnimation.value *
                  (MediaQuery.of(context).size.height * 0.5),
              left: 0,
              right: 0,
              child: Container(
                height: 3.h,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      AppTheme.primaryBlue,
                      AppTheme.accentGreen,
                      AppTheme.primaryBlue,
                      Colors.transparent,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryBlue.withOpacity(0.7),
                      blurRadius: 12,
                      spreadRadius: 3,
                    ),
                  ],
                ),
              ),
            ),

            // Analysis points
            ..._buildAnalysisPoints(),
          ],
        );
      },
    );
  }

  List<Widget> _buildAnalysisPoints() {
    final points = [
      Offset(0.2, 0.3), // Top left
      Offset(0.8, 0.2), // Top right
      Offset(0.3, 0.7), // Bottom left
      Offset(0.7, 0.8), // Bottom right
      Offset(0.5, 0.5), // Center
    ];

    return points.map((point) {
      final isActive = _currentStep < _analysisSteps.length;
      return Positioned(
        left: point.dx * (MediaQuery.of(context).size.width * 0.9) - 20.w,
        top: point.dy * (MediaQuery.of(context).size.height * 0.5) - 20.h,
        child: AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: isActive ? _pulseAnimation.value : 1.0,
              child: Container(
                width: 40.w,
                height: 40.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isActive
                      ? AppTheme.primaryBlue.withOpacity(0.9)
                      : Colors.white.withOpacity(0.7),
                  border: Border.all(
                    color: Colors.white,
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isActive
                          ? AppTheme.primaryBlue.withOpacity(0.6)
                          : Colors.white.withOpacity(0.4),
                      blurRadius: 12,
                      spreadRadius: 3,
                    ),
                  ],
                ),
                child: Icon(
                  _getStepIcon(_currentStep),
                  color: Colors.white,
                  size: 20.w,
                ),
              ),
            );
          },
        ),
      );
    }).toList();
  }

  IconData _getStepIcon(int step) {
    if (step < _analysisSteps.length) {
      return _analysisSteps[step].icon;
    }
    return Icons.check_rounded;
  }

  Widget _buildProgressIndicator() {
    final progress = (_currentStep + 1) / _analysisSteps.length;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 40.w),
      child: Column(
        children: [
          // Progress text
          Text(
            '${(_currentStep + 1)} / ${_analysisSteps.length}',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),

          SizedBox(height: 12.h),

          // Progress bar
          Container(
            height: 6.h,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(3.r),
            ),
            child: AnimatedBuilder(
              animation: _progressAnimation,
              builder: (context, child) {
                return FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: progress,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppTheme.primaryBlue, AppTheme.accentGreen],
                      ),
                      borderRadius: BorderRadius.circular(3.r),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepInfo() {
    if (_currentStep >= _analysisSteps.length) return const SizedBox.shrink();

    final step = _analysisSteps[_currentStep];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: AnimatedBuilder(
        animation: _stepAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, (1 - _stepAnimation.value) * 30),
            child: Opacity(
              opacity: _stepAnimation.value,
              child: Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: AppTheme.primaryBlue.withOpacity(0.6),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryBlue.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBlue.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Icon(
                        step.icon,
                        color: AppTheme.primaryBlue,
                        size: 28.w,
                      ),
                    ),
                    SizedBox(width: 20.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            step.title,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 6.h),
                          Text(
                            step.description,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 15.sp,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class AnalysisStep {
  final String title;
  final String description;
  final IconData icon;
  final double duration;

  const AnalysisStep({
    required this.title,
    required this.description,
    required this.icon,
    required this.duration,
  });
}

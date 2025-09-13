import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_theme.dart';

/// Widget for showing analysis animation during photo processing
class AnalysisAnimationWidget extends StatefulWidget {
  final String imagePath;
  final VoidCallback? onComplete;

  const AnalysisAnimationWidget({
    super.key,
    required this.imagePath,
    this.onComplete,
  });

  @override
  State<AnalysisAnimationWidget> createState() =>
      _AnalysisAnimationWidgetState();
}

class _AnalysisAnimationWidgetState extends State<AnalysisAnimationWidget>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _scanController;
  late AnimationController _bubbleController;
  late AnimationController _progressController;
  late AnimationController _pulseController;

  late Animation<double> _scanAnimation;
  late Animation<double> _bubbleAnimation;
  late Animation<double> _progressAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _fadeAnimation;

  int _currentStep = 0;
  final List<String> _analysisSteps = [
    'Görsel yükleniyor...',
    'Mimari özellikler analiz ediliyor...',
    'Coğrafi ipuçları taranıyor...',
    'Kültürel özellikler inceleniyor...',
    'Koordinatlar hesaplanıyor...',
    'Sonuçlar doğrulanıyor...',
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnalysis();
  }

  void _initializeAnimations() {
    // Main controller for overall timing
    _mainController = AnimationController(
      duration: const Duration(seconds: 18),
      vsync: this,
    );

    // Scan line animation
    _scanController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Thinking bubbles animation
    _bubbleController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Progress animation
    _progressController = AnimationController(
      duration: const Duration(seconds: 18),
      vsync: this,
    );

    // Pulse animation for AI eye
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // Initialize animations
    _scanAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scanController,
      curve: Curves.easeInOut,
    ));

    _bubbleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _bubbleController,
      curve: Curves.easeInOut,
    ));

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
    ));

    // Listen to main controller for step changes
    _mainController.addListener(() {
      final progress = _mainController.value;
      final newStep = (progress * _analysisSteps.length).floor();
      if (newStep != _currentStep && newStep < _analysisSteps.length) {
        setState(() {
          _currentStep = newStep;
        });
      }
    });

    // Complete callback
    _mainController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete?.call();
      }
    });
  }

  void _startAnalysis() {
    _mainController.forward();
    _progressController.forward();
    _pulseController.repeat(reverse: true);

    // Start scan animation repeatedly
    _scanController.repeat();

    // Start bubble animation repeatedly
    _bubbleController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _mainController.dispose();
    _scanController.dispose();
    _bubbleController.dispose();
    _progressController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.deepSpace,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.deepSpace,
              AppTheme.spaceBlue,
              AppTheme.cosmicPurple,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: Stack(
                  children: [
                    _buildImageWithOverlay(),
                    _buildAnalysisInfo(),
                  ],
                ),
              ),
              _buildProgressSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(16.w),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(
              Icons.arrow_back_ios_rounded,
              color: Colors.white,
              size: 24.w,
            ),
          ),
          Expanded(
            child: Text(
              'AI Analiz Ediyor',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.3),
                    offset: const Offset(0, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(width: 48.w),
        ],
      ),
    );
  }

  Widget _buildImageWithOverlay() {
    return Center(
      child: Container(
        margin: EdgeInsets.all(20.w),
        child: Stack(
          children: [
            // Main image
            Container(
              width: 300.w,
              height: 300.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.electricBlue.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20.r),
                child: Image.asset(
                  widget.imagePath,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // Scanning line overlay
            AnimatedBuilder(
              animation: _scanAnimation,
              builder: (context, child) {
                return Positioned(
                  top: _scanAnimation.value * 300.w,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 2.h,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          AppTheme.electricBlue,
                          AppTheme.neonGreen,
                          AppTheme.electricBlue,
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),

            // Corner highlights
            ...List.generate(4, (index) {
              return Positioned(
                top: index < 2 ? 10.h : null,
                bottom: index >= 2 ? 10.h : null,
                left: index % 2 == 0 ? 10.w : null,
                right: index % 2 == 1 ? 10.w : null,
                child: AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value,
                      child: Container(
                        width: 20.w,
                        height: 20.w,
                        decoration: BoxDecoration(
                          color: AppTheme.electricBlue,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.electricBlue.withOpacity(0.6),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisInfo() {
    return Positioned(
      bottom: 100.h,
      left: 20.w,
      right: 20.w,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.7),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: AppTheme.electricBlue.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              // AI Eye icon
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: AppTheme.electricBlue.withOpacity(0.2),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppTheme.electricBlue,
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        Icons.visibility_rounded,
                        color: AppTheme.electricBlue,
                        size: 32.w,
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: 16.h),

              // Current step
              Text(
                _analysisSteps[_currentStep],
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8.h),

              // Thinking bubbles
              _buildThinkingBubbles(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThinkingBubbles() {
    return AnimatedBuilder(
      animation: _bubbleAnimation,
      builder: (context, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) {
            final delay = index * 0.2;
            final animationValue =
                (_bubbleAnimation.value - delay).clamp(0.0, 1.0);

            return Container(
              margin: EdgeInsets.symmetric(horizontal: 4.w),
              child: Transform.scale(
                scale: 0.5 + (animationValue * 0.5),
                child: Container(
                  width: 8.w,
                  height: 8.w,
                  decoration: BoxDecoration(
                    color: AppTheme.neonGreen.withOpacity(0.7),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildProgressSection() {
    return Container(
      padding: EdgeInsets.all(20.w),
      child: Column(
        children: [
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
                  widthFactor: _progressAnimation.value,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppTheme.electricBlue, AppTheme.neonGreen],
                      ),
                      borderRadius: BorderRadius.circular(3.r),
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 16.h),

          // Progress text
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'İlerleme',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
              AnimatedBuilder(
                animation: _progressAnimation,
                builder: (context, child) {
                  return Text(
                    '${(_progressAnimation.value * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.electricBlue,
                    ),
                  );
                },
              ),
            ],
          ),
          SizedBox(height: 8.h),

          // Estimated time
          Text(
            'Tahmini süre: ${(10 - (_progressAnimation.value * 10)).toInt()} saniye',
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.white.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }
}

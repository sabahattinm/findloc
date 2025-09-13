import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/modern_theme.dart';

/// Modern analiz widget'ı
class ModernAnalysisWidget extends StatefulWidget {
  const ModernAnalysisWidget({super.key});

  @override
  State<ModernAnalysisWidget> createState() => _ModernAnalysisWidgetState();
}

class _ModernAnalysisWidgetState extends State<ModernAnalysisWidget>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _pulseController;
  late AnimationController _rotationController;

  late Animation<double> _mainAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();

    _mainController = AnimationController(
      duration: const Duration(seconds: 18),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _rotationController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    _mainAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _mainController, curve: Curves.easeInOut),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.linear),
    );

    _startAnimations();
  }

  void _startAnimations() {
    _mainController.forward();
    _pulseController.repeat(reverse: true);
    _rotationController.repeat();
  }

  @override
  void dispose() {
    _mainController.dispose();
    _pulseController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ModernTheme.primaryDarkBlue,
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _buildAnalysisContent(),
            ),
            _buildProgressSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(20.w),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              // Geri dön
            },
            icon: Icon(
              Icons.arrow_back_ios_rounded,
              color: Colors.white,
              size: 24.w,
            ),
          ),
          Expanded(
            child: Text(
              'Konum Analizi',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(width: 48.w), // Boşluk
        ],
      ),
    );
  }

  Widget _buildAnalysisContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Ana analiz animasyonu
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimation.value,
              child: ModernTheme.glowContainer(
                glowColor: ModernTheme.primaryGreen,
                child: Container(
                  width: 200.w,
                  height: 200.w,
                  decoration: BoxDecoration(
                    gradient: ModernTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(100.r),
                    boxShadow: [
                      BoxShadow(
                        color: ModernTheme.primaryGreen.withOpacity(0.4),
                        blurRadius: 40,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Dönen çember
                      AnimatedBuilder(
                        animation: _rotationAnimation,
                        builder: (context, child) {
                          return Transform.rotate(
                            angle: _rotationAnimation.value * 2 * 3.14159,
                            child: Container(
                              width: 180.w,
                              height: 180.w,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 2,
                                ),
                              ),
                              child: CustomPaint(
                                painter: CircleProgressPainter(
                                  progress: _mainAnimation.value,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      // Merkez icon
                      Icon(
                        Icons.location_on_rounded,
                        color: Colors.white,
                        size: 60.w,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        SizedBox(height: 40.h),

        // Analiz adımları
        _buildAnalysisSteps(),
      ],
    );
  }

  Widget _buildAnalysisSteps() {
    final steps = [
      {'title': 'Görsel Yükleniyor', 'duration': 3.0},
      {'title': 'AI Analiz Ediyor', 'duration': 3.5},
      {'title': 'Konum Tespit Ediliyor', 'duration': 3.0},
      {'title': 'Detaylar İşleniyor', 'duration': 3.0},
      {'title': 'Sonuçlar Hazırlanıyor', 'duration': 2.5},
      {'title': 'Tamamlanıyor', 'duration': 3.0},
    ];

    return ModernTheme.gradientContainer(
      padding: EdgeInsets.all(24.w),
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Analiz Adımları',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20.h),
          ...steps.asMap().entries.map((entry) {
            final index = entry.key;
            final step = entry.value;
            final stepProgress = _calculateStepProgress(index);

            return _buildStepItem(
              step['title'] as String,
              stepProgress,
              index < _getCurrentStepIndex(),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildStepItem(String title, double progress, bool isCompleted) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      child: Row(
        children: [
          // Step icon
          Container(
            width: 32.w,
            height: 32.w,
            decoration: BoxDecoration(
              gradient: isCompleted ? ModernTheme.primaryGradient : null,
              color: isCompleted ? null : Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Icon(
              isCompleted
                  ? Icons.check_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: Colors.white,
              size: 16.w,
            ),
          ),
          SizedBox(width: 16.w),

          // Step title
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14.sp,
                fontWeight: isCompleted ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),

          // Progress bar
          Container(
            width: 60.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(2.r),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  gradient: ModernTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection() {
    return Container(
      padding: EdgeInsets.all(20.w),
      child: Column(
        children: [
          // Progress bar
          Container(
            width: double.infinity,
            height: 6.h,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(3.r),
            ),
            child: AnimatedBuilder(
              animation: _mainAnimation,
              builder: (context, child) {
                return FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: _mainAnimation.value,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: ModernTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(3.r),
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 12.h),

          // Progress text
          AnimatedBuilder(
            animation: _mainAnimation,
            builder: (context, child) {
              return Text(
                '${(_mainAnimation.value * 100).toInt()}% Tamamlandı',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 14.sp,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  double _calculateStepProgress(int stepIndex) {
    final currentStep = _getCurrentStepIndex();
    if (stepIndex < currentStep) return 1.0;
    if (stepIndex > currentStep) return 0.0;

    // Mevcut step için progress hesapla
    final stepStartTime = _getStepStartTime(stepIndex);
    final stepDuration = _getStepDuration(stepIndex);
    final currentTime = _mainAnimation.value * 18; // Toplam süre 18 saniye

    if (currentTime < stepStartTime) return 0.0;
    if (currentTime > stepStartTime + stepDuration) return 1.0;

    return (currentTime - stepStartTime) / stepDuration;
  }

  int _getCurrentStepIndex() {
    final currentTime = _mainAnimation.value * 18;
    double accumulatedTime = 0;

    final durations = [3.0, 3.5, 3.0, 3.0, 2.5, 3.0];

    for (int i = 0; i < durations.length; i++) {
      accumulatedTime += durations[i];
      if (currentTime <= accumulatedTime) {
        return i;
      }
    }

    return durations.length - 1;
  }

  double _getStepStartTime(int stepIndex) {
    final durations = [3.0, 3.5, 3.0, 3.0, 2.5, 3.0];
    double startTime = 0;

    for (int i = 0; i < stepIndex; i++) {
      startTime += durations[i];
    }

    return startTime;
  }

  double _getStepDuration(int stepIndex) {
    final durations = [3.0, 3.5, 3.0, 3.0, 2.5, 3.0];
    return durations[stepIndex];
  }
}

class CircleProgressPainter extends CustomPainter {
  final double progress;
  final Color color;

  CircleProgressPainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.3)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;

    // Background circle
    canvas.drawCircle(center, radius, paint);

    // Progress arc
    paint.color = color;
    final sweepAngle = 2 * 3.14159 * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.14159 / 2, // Start from top
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

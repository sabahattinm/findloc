import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../location_detection/presentation/pages/modern_home_page.dart';

/// Onboarding page to introduce the app features
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  int _currentPage = 0;

  final List<OnboardingData> _onboardingData = [
    OnboardingData(
      title: 'Fotoğraftan Konum Tespit Et',
      description:
          'Herhangi bir fotoğrafı yükleyin veya sosyal medya URL\'lerinden görsel analiz edin. AI teknolojisi ile konumunu tespit edin.',
      icon: Icons.camera_alt_rounded,
      color: Colors.blue,
      gradient: [Colors.blue, Colors.blueAccent],
    ),
    OnboardingData(
      title: 'Sosyal Medya URL Analizi',
      description:
          'Instagram, Twitter, Facebook gibi sosyal medya platformlarından URL ile fotoğraf analiz edin. Direkt link paylaşımı yapın.',
      icon: Icons.link_rounded,
      color: Colors.pink,
      gradient: [Colors.pink, Colors.pinkAccent],
    ),
    OnboardingData(
      title: 'Canlı Kameraları İzle',
      description:
          'Tespit edilen konumdaki canlı kameralara erişin. Trafik, güvenlik, hava durumu ve turist kameralarını görüntüleyin.',
      icon: Icons.videocam_rounded,
      color: Colors.green,
      gradient: [Colors.green, Colors.greenAccent],
    ),
    OnboardingData(
      title: 'Premium Özellikler',
      description:
          'Sınırsız tarama, yüksek kaliteli analiz, gelişmiş özellikler ve öncelikli destek için premium paketlerimizi keşfedin.',
      icon: Icons.diamond_rounded,
      color: Colors.purple,
      gradient: [Colors.purple, Colors.deepPurple],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _onboardingData[_currentPage].gradient,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Skip button
              Padding(
                padding: EdgeInsets.all(16.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Page indicator
                    Row(
                      children: List.generate(
                        _onboardingData.length,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: EdgeInsets.only(right: 8.w),
                          height: 8.h,
                          width: _currentPage == index ? 24.w : 8.w,
                          decoration: BoxDecoration(
                            color: _currentPage == index
                                ? Colors.white
                                : Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                        ),
                      ),
                    ),
                    // Skip button
                    TextButton(
                      onPressed: _skipOnboarding,
                      child: Text(
                        'Atla',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.3),
                              offset: const Offset(0, 1),
                              blurRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Page content
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                    _animationController.forward().then((_) {
                      _animationController.reset();
                    });
                  },
                  itemCount: _onboardingData.length,
                  itemBuilder: (context, index) {
                    return _buildOnboardingPage(_onboardingData[index]);
                  },
                ),
              ),

              // Navigation buttons
              Padding(
                padding: EdgeInsets.all(24.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Previous button
                    if (_currentPage > 0)
                      TextButton(
                        onPressed: _previousPage,
                        child: Text(
                          'Geri',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.3),
                                offset: const Offset(0, 1),
                                blurRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      const SizedBox(width: 60),

                    // Next/Get Started button
                    ElevatedButton(
                      onPressed: _currentPage == _onboardingData.length - 1
                          ? _completeOnboarding
                          : _nextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: _onboardingData[_currentPage].color,
                        padding: EdgeInsets.symmetric(
                          horizontal: 32.w,
                          vertical: 16.h,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.r),
                        ),
                        elevation: 8,
                      ),
                      child: Text(
                        _currentPage == _onboardingData.length - 1
                            ? 'Başlayalım'
                            : 'İleri',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
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
  }

  Widget _buildOnboardingPage(OnboardingData data) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon with animation
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Transform.scale(
                scale: 1.0 + (_animationController.value * 0.1),
                child: Container(
                  width: 200.w,
                  height: 200.w,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Icon(
                    data.icon,
                    size: 100.w,
                    color: Colors.white,
                  ),
                ),
              );
            },
          ),

          SizedBox(height: 60.h),

          // Title
          Text(
            data.title,
            style: TextStyle(
              fontSize: 28.sp,
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

          SizedBox(height: 12.h),

          // Description
          Text(
            data.description,
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.white,
              height: 1.5,
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.2),
                  offset: const Offset(0, 1),
                  blurRadius: 2,
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 40.h),

          // Feature highlights
          _buildFeatureHighlights(data),
        ],
      ),
    );
  }

  Widget _buildFeatureHighlights(OnboardingData data) {
    List<String> features = [];

    switch (data.icon) {
      case Icons.camera_alt_rounded:
        features = ['AI Analizi', 'Yüksek Doğruluk', 'Hızlı Sonuç'];
        break;
      case Icons.videocam_rounded:
        features = ['Canlı Yayın', 'Çoklu Kaynak', 'Gerçek Zamanlı'];
        break;
      case Icons.map_rounded:
        features = ['Google Maps', 'Koordinat Paylaşımı', 'Geçmiş Takibi'];
        break;
      case Icons.diamond_rounded:
        features = ['Sınırsız Tarama', 'Premium Analiz', 'Öncelikli Destek'];
        break;
    }

    return Column(
      children: features
          .map((feature) => Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Colors.white,
                      size: 20.w,
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      feature,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.2),
                            offset: const Offset(0, 1),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }

  void _nextPage() {
    if (_currentPage < _onboardingData.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _skipOnboarding() async {
    await _completeOnboarding();
  }

  Future<void> _completeOnboarding() async {
    // Save onboarding completion
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);

    // Navigate to home page
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const ModernHomePage(),
        ),
      );
    }
  }
}

/// Data class for onboarding pages
class OnboardingData {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final List<Color> gradient;

  OnboardingData({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.gradient,
  });
}

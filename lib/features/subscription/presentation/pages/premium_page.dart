import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_theme.dart';

/// Premium subscription page with pricing plans
class PremiumPage extends StatefulWidget {
  const PremiumPage({super.key});

  @override
  State<PremiumPage> createState() => _PremiumPageState();
}

class _PremiumPageState extends State<PremiumPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _cardController;
  int _selectedPlan = 1; // Default to monthly plan

  final List<PremiumPlan> _plans = [
    PremiumPlan(
      name: 'Haftalık',
      price: '249₺',
      period: 'hafta',
      scans: 5,
      features: [
        '5 fotoğraf analizi',
        'Temel konum tespiti',
        'Canlı kamera erişimi',
        'Harita entegrasyonu',
        'E-posta desteği',
      ],
      isPopular: false,
      color: Colors.blue,
    ),
    PremiumPlan(
      name: 'Aylık',
      price: '749₺',
      period: 'ay',
      scans: 25,
      features: [
        '25 fotoğraf analizi',
        'Gelişmiş konum tespiti',
        'Sınırsız kamera erişimi',
        'Öncelikli işleme',
        'Gelişmiş harita özellikleri',
        'Telefon desteği',
      ],
      isPopular: true,
      color: AppTheme.primaryBlue,
    ),
    PremiumPlan(
      name: 'Sınırsız',
      price: '1,999₺',
      period: 'ay',
      scans: -1, // Unlimited
      features: [
        'Sınırsız fotoğraf analizi',
        'En yüksek doğruluk',
        'Tüm kamera türleri',
        'Anında işleme',
        'API erişimi',
        'Özel destek',
        'Gelişmiş raporlama',
      ],
      isPopular: false,
      color: Colors.purple,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _cardController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _animationController.forward();
    _cardController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _cardController.dispose();
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
            colors: [
              AppTheme.backgroundDark,
              AppTheme.surfaceDark,
              AppTheme.backgroundDark,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      _buildHeroSection(),
                      SizedBox(height: 40.h),
                      _buildPricingCards(),
                      SizedBox(height: 40.h),
                      _buildFeaturesSection(),
                      SizedBox(height: 40.h),
                      _buildSubscribeButton(),
                      SizedBox(height: 40.h),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
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
              'Premium Paketler',
              style: TextStyle(
                fontSize: 24.sp,
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
          SizedBox(width: 48.w), // Balance the back button
        ],
      ),
    );
  }

  Widget _buildHeroSection() {
    return FadeTransition(
      opacity: _animationController,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(32.w),
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.primaryBlue.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Icon(
              Icons.diamond_rounded,
              size: 64.w,
              color: AppTheme.primaryBlue,
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            'Premium Özellikler',
            style: TextStyle(
              fontSize: 32.sp,
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
          SizedBox(height: 16.h),
          Text(
            'Sınırsız analiz, gelişmiş özellikler\nve öncelikli destek',
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.white.withOpacity(0.8),
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.3),
                  offset: const Offset(0, 1),
                  blurRadius: 2,
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPricingCards() {
    return Column(
      children: _plans.asMap().entries.map((entry) {
        final index = entry.key;
        final plan = entry.value;
        return AnimatedBuilder(
          animation: _cardController,
          builder: (context, child) {
            final animation = Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(CurvedAnimation(
              parent: _cardController,
              curve: Interval(
                index * 0.2,
                1.0,
                curve: Curves.easeOutBack,
              ),
            ));

            return Transform.scale(
              scale: animation.value,
              child: _buildPricingCard(plan, index),
            );
          },
        );
      }).toList(),
    );
  }

  Widget _buildPricingCard(PremiumPlan plan, int index) {
    final isSelected = _selectedPlan == index;
    
    return GestureDetector(
      onTap: () => setState(() => _selectedPlan = index),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isSelected
                ? [plan.color, plan.color.withOpacity(0.8)]
                : [Colors.white.withOpacity(0.1), Colors.white.withOpacity(0.05)],
          ),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSelected
                ? plan.color
                : Colors.white.withOpacity(0.2),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? plan.color.withOpacity(0.3)
                  : Colors.black.withOpacity(0.1),
              blurRadius: isSelected ? 20 : 10,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            if (plan.isPopular)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: AppTheme.accentGreen,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  'EN POPÜLER',
                  style: TextStyle(
                    color: AppTheme.deepSpace,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            if (plan.isPopular) SizedBox(height: 16.h),
            
            Text(
              plan.name,
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 8.h),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  plan.price,
                  style: TextStyle(
                    fontSize: 36.sp,
                    fontWeight: FontWeight.bold,
                    color: plan.color,
                  ),
                ),
                SizedBox(width: 4.w),
                Text(
                  '/${plan.period}',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            
            Text(
              plan.scans == -1
                  ? 'Sınırsız analiz'
                  : '${plan.scans} fotoğraf analizi',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
            SizedBox(height: 24.h),
            
            ...plan.features.map((feature) => Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    color: AppTheme.accentGreen,
                    size: 20.w,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      feature,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturesSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Premium Avantajları',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 16.h),
          
          _buildFeatureItem(
            '🚀 Hızlı İşleme',
            'Öncelikli sunucu erişimi ile anında analiz',
          ),
          _buildFeatureItem(
            '🎯 Yüksek Doğruluk',
            'Gelişmiş AI algoritmaları ile %95+ doğruluk',
          ),
          _buildFeatureItem(
            '📱 Sınırsız Erişim',
            'Tüm özelliklere sınırsız erişim',
          ),
          _buildFeatureItem(
            '🛡️ Güvenlik',
            'End-to-end şifreleme ile veri güvenliği',
          ),
          _buildFeatureItem(
            '💬 Öncelikli Destek',
            '7/24 öncelikli müşteri desteği',
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String title, String description) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            flex: 3,
            child: Text(
              description,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscribeButton() {
    final selectedPlan = _plans[_selectedPlan];
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      width: double.infinity,
      height: 56.h,
      child: ElevatedButton(
        onPressed: () => _handleSubscription(selectedPlan),
        style: ElevatedButton.styleFrom(
          backgroundColor: selectedPlan.color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28.r),
          ),
          elevation: 8,
          shadowColor: selectedPlan.color.withOpacity(0.3),
        ),
        child: Text(
          '${selectedPlan.name} Paketi - ${selectedPlan.price}/${selectedPlan.period}',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _handleSubscription(PremiumPlan plan) {
    // TODO: Implement subscription logic
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${plan.name} paketi seçildi! Ödeme işlemi yakında aktif olacak.'),
        backgroundColor: plan.color,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

class PremiumPlan {
  final String name;
  final String price;
  final String period;
  final int scans;
  final List<String> features;
  final bool isPopular;
  final Color color;

  PremiumPlan({
    required this.name,
    required this.price,
    required this.period,
    required this.scans,
    required this.features,
    required this.isPopular,
    required this.color,
  });
}

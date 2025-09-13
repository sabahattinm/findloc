/// Application constants and configuration values
class AppConstants {
  // API Configuration
  static const String geminiApiKey = 'AIzaSyAcIUzhAtpU56TX9RB0gSElyA4fJ3RVGXo';
  static const String geminiBaseUrl =
      'https://generativelanguage.googleapis.com/v1beta';

  // Subscription Plans
  static const String weeklyPlanId = 'weekly_plan_249';
  static const String monthlyPlanId = 'monthly_plan_749';
  static const String unlimitedPlanId = 'unlimited_plan';

  // Usage Limits
  static const int weeklyScanLimit = 5;
  static const int monthlyScanLimit = 25;
  static const int freeTrialScans = 3;

  // Storage Keys
  static const String userPreferencesKey = 'user_preferences';
  static const String subscriptionKey = 'subscription_data';
  static const String usageKey = 'usage_data';

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 12.0;
  static const double cardElevation = 4.0;

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // Image Processing
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  static const List<String> supportedImageFormats = [
    'jpg',
    'jpeg',
    'png',
    'webp',
  ];

  // Error Messages
  static const String networkErrorMessage =
      'İnternet bağlantınızı kontrol edin';
  static const String genericErrorMessage =
      'Bir hata oluştu. Lütfen tekrar deneyin';
  static const String subscriptionRequiredMessage =
      'Bu özellik premium üyelik gerektirir';
}

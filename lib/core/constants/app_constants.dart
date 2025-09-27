class AppConstants {
  // App Info
  static const String appName = 'Quick Deliver';
  static const String appVersion = '1.0.0';
  
  // API Configuration
  static const String baseUrl = 'http://localhost:3000'; // Replace with your actual API URL
  static const int connectionTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds
  
  // Storage Keys
  static const String isFirstLaunchKey = 'is_first_launch';
  static const String isOnboardingCompletedKey = 'is_onboarding_completed';
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userDataKey = 'user_data';
  
  // Animation Durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 300);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);
  
  // UI Constants
  static const double defaultButtonHeight = 48.0;
  static const double defaultInputHeight = 56.0;
  static const double defaultElevation = 2.0;
  
  // Validation
  static const int minPasswordLength = 8;
  static const int maxNameLength = 50;
  static const int maxMessageLength = 500;
  
  // Error Messages
  static const String networkErrorMessage = 'Please check your internet connection';
  static const String serverErrorMessage = 'Something went wrong. Please try again';
  static const String timeoutErrorMessage = 'Request timeout. Please try again';
  static const String unknownErrorMessage = 'An unknown error occurred';
}
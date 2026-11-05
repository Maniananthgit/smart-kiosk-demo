class AppConstants {
  static const String appName = 'OrderEase Smart Kiosk';
  static const String appSubtitle = 'Table-Side Self Ordering & Kitchen Display';

  // Base API URL (supports Docker container proxy, cloud, or localhost)
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8000/api/v1',
  );

  static const String currencySymbol = '₹';
  static const double taxRatePercent = 5.0; // 5% GST
}


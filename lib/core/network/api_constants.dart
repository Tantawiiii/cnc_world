final class ApiConstants {
  ApiConstants._();

  /// Base URL - can be overridden with: flutter run/build --dart-define=BASE_URL=https://your-url.com
  static String get baseUrl => const String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'https://procnctech.dentin.cloud',
  );

  /// Base URL for media (HTTP) - used for image/video previews
  static String get mediaBaseUrl {
    final uri = Uri.parse(baseUrl);
    return uri.replace(scheme: 'http').toString().replaceAll(RegExp(r'/$'), '');
  }

  static const String login = '/api/login';
  static const String register = '/api/application-form';
  static const String mediaUpload = '/api/media';
  static const String getSlider = '/api/get-slider';
  static const String contactUs = '/api/contact-us-public';
}

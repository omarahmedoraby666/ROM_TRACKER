class BackendEnvironment {
  const BackendEnvironment({
    required this.baseUrl,
    this.connectTimeout = const Duration(seconds: 20),
    this.receiveTimeout = const Duration(seconds: 20),
  });

  final String baseUrl;
  final Duration connectTimeout;
  final Duration receiveTimeout;

  static const String placeholderBaseUrl = 'http://YOUR_BACKEND_BASE_URL/api';

  static const String _overrideBaseUrl = String.fromEnvironment(
    'ROM_TRACKER_API_BASE_URL',
    defaultValue: '',
  );

  static final BackendEnvironment current = BackendEnvironment(
    baseUrl: _overrideBaseUrl.isNotEmpty
        ? _overrideBaseUrl
        : 'http://127.0.0.1:3000/api',
  );

  bool get isConfigured => baseUrl != placeholderBaseUrl;
}

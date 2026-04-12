class BackendEnvironment {
  const BackendEnvironment({
    required this.baseUrl,
    this.connectTimeout = const Duration(seconds: 20),
    this.receiveTimeout = const Duration(seconds: 20),
  });

  final String baseUrl;
  final Duration connectTimeout;
  final Duration receiveTimeout;

  static const String placeholderBaseUrl =
      'http://YOUR_BACKEND_BASE_URL/api';

  static const BackendEnvironment current = BackendEnvironment(
    baseUrl: placeholderBaseUrl,
  );

  bool get isConfigured => baseUrl != placeholderBaseUrl;
}

enum BackendFailureType {
  unconfigured,
  unauthorized,
  validation,
  network,
  server,
  invalidResponse,
  unknown,
}

class BackendFailure {
  const BackendFailure({
    required this.type,
    required this.message,
    this.statusCode,
    this.details,
  });

  final BackendFailureType type;
  final String message;
  final int? statusCode;
  final Object? details;
}

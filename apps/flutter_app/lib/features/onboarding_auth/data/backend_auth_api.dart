import 'package:rom_tracker_app/core/network/api_endpoints.dart';
import 'package:rom_tracker_app/core/network/backend_client.dart';
import 'package:rom_tracker_app/core/network/backend_failure.dart';
import 'package:rom_tracker_app/core/network/backend_result.dart';
import 'package:rom_tracker_app/core/network/json_map.dart';
import 'package:rom_tracker_app/features/onboarding_auth/data/auth_contract.dart';

class BackendAuthApi implements AuthContract {
  BackendAuthApi._();

  static final BackendAuthApi instance = BackendAuthApi._();

  final BackendClient _client = BackendClient.instance;

  @override
  Future<BackendResult<AuthSession>> login(LoginRequest request) async {
    final response = await _client.post(
      ApiEndpoints.login,
      data: request.toJson(),
    );
    if (response.isFailure) {
      return BackendResult.failure(response.failure!);
    }

    final data = response.data!;
    final accessToken = (data['accessToken'] ?? '').toString();
    final user = _extractMap(data['user']);
    if (accessToken.isEmpty || user.isEmpty) {
      return BackendResult.failure(
        const BackendFailure(
          type: BackendFailureType.invalidResponse,
          message: 'Invalid login response from backend',
        ),
      );
    }

    return BackendResult.success(
      AuthSession(
        accessToken: accessToken,
        user: user,
      ),
    );
  }

  @override
  Future<BackendResult<JsonMap>> getCurrentUser() {
    return _client.get(ApiEndpoints.me);
  }

  @override
  Future<BackendResult<JsonMap>> registerDoctor(JsonMap payload) {
    return _client.post(ApiEndpoints.registerDoctor, data: payload);
  }

  @override
  Future<BackendResult<JsonMap>> registerPatient(JsonMap payload) {
    return _client.post(ApiEndpoints.registerPatient, data: payload);
  }

  @override
  Future<BackendResult<void>> forgotPassword(JsonMap payload) async {
    final result = await _client.post(ApiEndpoints.forgotPassword, data: payload);
    return result.isFailure
        ? BackendResult.failure(result.failure!)
        : const BackendResult.success(null);
  }

  @override
  Future<BackendResult<void>> resetPassword(JsonMap payload) async {
    final result = await _client.post(ApiEndpoints.resetPassword, data: payload);
    return result.isFailure
        ? BackendResult.failure(result.failure!)
        : const BackendResult.success(null);
  }

  @override
  Future<BackendResult<void>> verifyOtp(JsonMap payload) async {
    final result = await _client.post(ApiEndpoints.verifyOtp, data: payload);
    return result.isFailure
        ? BackendResult.failure(result.failure!)
        : const BackendResult.success(null);
  }

  JsonMap _extractMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return <String, dynamic>{};
  }
}

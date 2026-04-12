import 'package:rom_tracker_app/core/network/backend_result.dart';
import 'package:rom_tracker_app/core/network/json_map.dart';

class LoginRequest {
  const LoginRequest({
    required this.email,
    required this.password,
  });

  final String email;
  final String password;

  JsonMap toJson() => {
        'email': email,
        'password': password,
      };
}

class AuthSession {
  const AuthSession({
    required this.accessToken,
    required this.user,
  });

  final String accessToken;
  final JsonMap user;
}

abstract class AuthContract {
  Future<BackendResult<AuthSession>> login(LoginRequest request);
  Future<BackendResult<JsonMap>> registerPatient(JsonMap payload);
  Future<BackendResult<JsonMap>> registerDoctor(JsonMap payload);
  Future<BackendResult<JsonMap>> getCurrentUser();
  Future<BackendResult<void>> forgotPassword(JsonMap payload);
  Future<BackendResult<void>> verifyOtp(JsonMap payload);
  Future<BackendResult<void>> resetPassword(JsonMap payload);
}

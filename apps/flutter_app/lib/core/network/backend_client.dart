import 'package:dio/dio.dart';
import 'package:rom_tracker_app/core/network/backend_environment.dart';
import 'package:rom_tracker_app/core/network/backend_failure.dart';
import 'package:rom_tracker_app/core/network/backend_result.dart';
import 'package:rom_tracker_app/core/network/json_map.dart';
import 'package:rom_tracker_app/features/onboarding_auth/presentation/models/auth_session_store.dart';

class BackendClient {
  BackendClient._() {
    _dio = Dio(
      BaseOptions(
        baseUrl: BackendEnvironment.current.baseUrl,
        connectTimeout: BackendEnvironment.current.connectTimeout,
        receiveTimeout: BackendEnvironment.current.receiveTimeout,
        responseType: ResponseType.json,
        headers: const {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = AuthSessionStore.accessToken.value;
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );
  }

  static final BackendClient instance = BackendClient._();

  late final Dio _dio;

  bool get isConfigured => BackendEnvironment.current.isConfigured;

  Future<BackendResult<JsonMap>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) async {
    return _send<JsonMap>(
      () => _dio.get<dynamic>(
        path,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      ),
      (data) => _asJsonMap(data),
    );
  }

  Future<BackendResult<List<JsonMap>>> getList(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return _send<List<JsonMap>>(
      () => _dio.get<dynamic>(
        path,
        queryParameters: queryParameters,
      ),
      (data) {
        if (data is List) {
          return data
              .whereType<Map>()
              .map((item) => Map<String, dynamic>.from(item))
              .toList();
        }
        throw const FormatException('Expected a list response');
      },
    );
  }

  Future<BackendResult<JsonMap>> post(
    String path, {
    JsonMap? data,
    Map<String, dynamic>? headers,
  }) async {
    return _send<JsonMap>(
      () => _dio.post<dynamic>(
        path,
        data: data,
        options: Options(headers: headers),
      ),
      (payload) => _asJsonMap(payload),
    );
  }

  Future<BackendResult<JsonMap>> patch(
    String path, {
    JsonMap? data,
    Map<String, dynamic>? headers,
  }) async {
    return _send<JsonMap>(
      () => _dio.patch<dynamic>(
        path,
        data: data,
        options: Options(headers: headers),
      ),
      (payload) => _asJsonMap(payload),
    );
  }

  Future<BackendResult<void>> delete(String path) async {
    return _send<void>(
      () => _dio.delete<dynamic>(path),
      (_) {},
    );
  }

  Future<BackendResult<T>> _send<T>(
    Future<Response<dynamic>> Function() request,
    T Function(dynamic data) parser,
  ) async {
    if (!isConfigured) {
      return BackendResult.failure(
        const BackendFailure(
          type: BackendFailureType.unconfigured,
          message: 'Backend environment is not configured.',
        ),
      );
    }

    try {
      final response = await request();
      final parsed = parser(response.data);
      return BackendResult.success(parsed);
    } on DioException catch (error) {
      return BackendResult.failure(_mapDioError(error));
    } on FormatException catch (error) {
      return BackendResult.failure(
        BackendFailure(
          type: BackendFailureType.invalidResponse,
          message: error.message,
          details: error,
        ),
      );
    } catch (error) {
      return BackendResult.failure(
        BackendFailure(
          type: BackendFailureType.unknown,
          message: 'Unexpected backend error',
          details: error,
        ),
      );
    }
  }

  BackendFailure _mapDioError(DioException error) {
    final responseData = error.response?.data;
    final message = switch (responseData) {
      {'message': final Object backendMessage} => backendMessage.toString(),
      _ => error.message ?? 'Network request failed',
    };
    final statusCode = error.response?.statusCode;

    if (statusCode == 401 || statusCode == 403) {
      return BackendFailure(
        type: BackendFailureType.unauthorized,
        message: message,
        statusCode: statusCode,
        details: responseData,
      );
    }
    if (statusCode == 400 || statusCode == 422) {
      return BackendFailure(
        type: BackendFailureType.validation,
        message: message,
        statusCode: statusCode,
        details: responseData,
      );
    }
    if (statusCode != null && statusCode >= 500) {
      return BackendFailure(
        type: BackendFailureType.server,
        message: message,
        statusCode: statusCode,
        details: responseData,
      );
    }
    if (error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return BackendFailure(
        type: BackendFailureType.network,
        message: message,
        statusCode: statusCode,
        details: responseData,
      );
    }
    return BackendFailure(
      type: BackendFailureType.unknown,
      message: message,
      statusCode: statusCode,
      details: responseData,
    );
  }

  JsonMap _asJsonMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    throw const FormatException('Expected a JSON object response');
  }
}

import 'package:rom_tracker_app/core/network/api_endpoints.dart';
import 'package:rom_tracker_app/core/network/backend_client.dart';
import 'package:rom_tracker_app/core/network/backend_result.dart';
import 'package:rom_tracker_app/core/network/json_map.dart';
import 'package:rom_tracker_app/features/sessions/data/sessions_contract.dart';

class BackendSessionsApi implements SessionsContract {
  BackendSessionsApi._();

  static final BackendSessionsApi instance = BackendSessionsApi._();

  final BackendClient _client = BackendClient.instance;

  @override
  Future<BackendResult<JsonMap>> createBooking(JsonMap payload) {
    return _client.post(ApiEndpoints.bookings, data: payload);
  }

  @override
  Future<BackendResult<List<JsonMap>>> getDoctorSessions({
    String? status,
  }) async {
    final result = await _client.get(
      ApiEndpoints.doctorSessions,
      queryParameters: {
        if (status != null && status.isNotEmpty) 'status': status,
      },
    );
    if (result.isFailure) {
      return BackendResult.failure(result.failure!);
    }
    return BackendResult.success(_extractItems(result.data!));
  }

  @override
  Future<BackendResult<List<JsonMap>>> getNotifications() async {
    final result = await _client.get(ApiEndpoints.notifications);
    if (result.isFailure) {
      return BackendResult.failure(result.failure!);
    }
    return BackendResult.success(_extractItems(result.data!));
  }

  @override
  Future<BackendResult<List<JsonMap>>> getPatientSessions({
    String? status,
  }) async {
    final result = await _client.get(
      ApiEndpoints.patientSessions,
      queryParameters: {
        if (status != null && status.isNotEmpty) 'status': status,
      },
    );
    if (result.isFailure) {
      return BackendResult.failure(result.failure!);
    }
    return BackendResult.success(_extractItems(result.data!));
  }

  @override
  Future<BackendResult<JsonMap>> getDoctorWallet() {
    return _client.get(ApiEndpoints.doctorWallet);
  }

  @override
  Future<BackendResult<void>> markNotificationRead(String notificationId) async {
    final result = await _client.patch(
      ApiEndpoints.notificationRead(notificationId),
    );
    return result.isFailure
        ? BackendResult.failure(result.failure!)
        : const BackendResult.success(null);
  }

  @override
  Future<BackendResult<void>> submitReview({
    required String sessionId,
    required JsonMap payload,
  }) async {
    final result = await _client.post(
      ApiEndpoints.sessionReview(sessionId),
      data: payload,
    );
    return result.isFailure
        ? BackendResult.failure(result.failure!)
        : const BackendResult.success(null);
  }

  @override
  Future<BackendResult<JsonMap>> updateSessionStatus({
    required String sessionId,
    required String status,
    String? doctorNotes,
    String? review,
    int? reviewRating,
  }) {
    return _client.patch(
      ApiEndpoints.sessionStatus(sessionId),
      data: {
        'status': status,
        if (doctorNotes != null) 'doctorNotes': doctorNotes,
        if (review != null) 'review': review,
        if (reviewRating != null) 'reviewRating': reviewRating,
      },
    );
  }

  List<JsonMap> _extractItems(JsonMap json) {
    final raw = json['items'];
    if (raw is List) {
      return raw
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }
    return const <JsonMap>[];
  }
}

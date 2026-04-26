import 'package:rom_tracker_app/core/network/backend_result.dart';
import 'package:rom_tracker_app/core/network/json_map.dart';

abstract class SessionsContract {
  Future<BackendResult<JsonMap>> createBooking(JsonMap payload);

  Future<BackendResult<List<JsonMap>>> getPatientSessions({
    String? status,
  });

  Future<BackendResult<List<JsonMap>>> getDoctorSessions({
    String? status,
  });

  Future<BackendResult<JsonMap>> updateSessionStatus({
    required String sessionId,
    required String status,
    String? doctorNotes,
    String? review,
    int? reviewRating,
  });

  Future<BackendResult<void>> submitReview({
    required String sessionId,
    required JsonMap payload,
  });

  Future<BackendResult<List<JsonMap>>> getNotifications();

  Future<BackendResult<void>> markNotificationRead(String notificationId);

  Future<BackendResult<JsonMap>> getDoctorWallet();
}

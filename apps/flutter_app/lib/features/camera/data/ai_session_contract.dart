import 'package:rom_tracker_app/core/network/backend_result.dart';
import 'package:rom_tracker_app/core/network/json_map.dart';

class AiSessionResultPayload {
  const AiSessionResultPayload({
    required this.patientId,
    required this.sessionId,
    required this.exercise,
    required this.reps,
    required this.timestamp,
  });

  final String patientId;
  final String sessionId;
  final String exercise;
  final int reps;
  final String timestamp;

  JsonMap toJson() => {
        'patientId': patientId,
        'exercise': exercise,
        'reps': reps,
        'timestamp': timestamp,
      };
}

abstract class AiSessionContract {
  Future<BackendResult<JsonMap>> submitAiSessionResult(
    AiSessionResultPayload payload,
  );
}

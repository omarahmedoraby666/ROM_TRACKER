import 'package:rom_tracker_app/core/network/backend_result.dart';
import 'package:rom_tracker_app/core/network/json_map.dart';

abstract class DoctorsContract {
  Future<BackendResult<List<JsonMap>>> getDoctors({
    String? search,
    String? specialization,
    int? page,
    int? limit,
  });

  Future<BackendResult<JsonMap>> getDoctorDetails(String doctorId);

  Future<BackendResult<List<JsonMap>>> getDoctorSlots(String doctorId);

  Future<BackendResult<List<JsonMap>>> getWishlist();

  Future<BackendResult<void>> addToWishlist(String doctorId);

  Future<BackendResult<void>> removeFromWishlist(String doctorId);
}

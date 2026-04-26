import 'package:rom_tracker_app/core/network/api_endpoints.dart';
import 'package:rom_tracker_app/core/network/backend_client.dart';
import 'package:rom_tracker_app/core/network/backend_result.dart';
import 'package:rom_tracker_app/core/network/json_map.dart';
import 'package:rom_tracker_app/features/doctors/data/doctors_contract.dart';
import 'package:rom_tracker_app/features/doctors/presentation/models/doctor_catalog.dart';
import 'package:rom_tracker_app/features/doctors/presentation/models/doctor_profile.dart';
import 'package:rom_tracker_app/features/doctors/presentation/models/doctor_slot.dart';

class BackendDoctorsApi implements DoctorsContract {
  BackendDoctorsApi._();

  static final BackendDoctorsApi instance = BackendDoctorsApi._();

  final BackendClient _client = BackendClient.instance;

  Future<List<DoctorProfile>> fetchDoctorProfiles({
    String? search,
    String? specialization,
  }) async {
    final result = await getDoctors(
      search: search,
      specialization: specialization,
    );
    if (result.isFailure) {
      throw Exception(result.failure?.message ?? 'Failed to load doctors');
    }
    return result.data!.map(_mapDoctorProfile).toList();
  }

  Future<List<DoctorSlot>> fetchDoctorSlots(String doctorId) async {
    final result = await getDoctorSlots(doctorId);
    if (result.isFailure) {
      throw Exception(result.failure?.message ?? 'Failed to load slots');
    }
    return result.data!.map(DoctorSlot.fromJson).toList();
  }

  @override
  Future<BackendResult<void>> addToWishlist(String doctorId) async {
    final result = await _client.post(ApiEndpoints.wishlistDoctor(doctorId));
    return result.isFailure
        ? BackendResult.failure(result.failure!)
        : const BackendResult.success(null);
  }

  @override
  Future<BackendResult<JsonMap>> getDoctorDetails(String doctorId) {
    return _client.get(ApiEndpoints.doctorDetails(doctorId));
  }

  @override
  Future<BackendResult<List<JsonMap>>> getDoctors({
    String? search,
    String? specialization,
    int? page,
    int? limit,
  }) async {
    final result = await _client.get(
      ApiEndpoints.doctors,
      queryParameters: {
        if (search != null && search.isNotEmpty) 'search': search,
        if (specialization != null && specialization.isNotEmpty)
          'specialization': specialization,
        if (page != null) 'page': page,
        if (limit != null) 'limit': limit,
      },
    );
    if (result.isFailure) {
      return BackendResult.failure(result.failure!);
    }
    final items = _extractItems(result.data!);
    return BackendResult.success(items);
  }

  @override
  Future<BackendResult<List<JsonMap>>> getDoctorSlots(String doctorId) async {
    final result = await _client.get(ApiEndpoints.doctorSlots(doctorId));
    if (result.isFailure) {
      return BackendResult.failure(result.failure!);
    }
    return BackendResult.success(_extractItems(result.data!));
  }

  @override
  Future<BackendResult<List<JsonMap>>> getWishlist() async {
    final result = await _client.get(ApiEndpoints.wishlist);
    if (result.isFailure) {
      return BackendResult.failure(result.failure!);
    }
    return BackendResult.success(_extractItems(result.data!));
  }

  @override
  Future<BackendResult<void>> removeFromWishlist(String doctorId) async {
    final result = await _client.delete(ApiEndpoints.wishlistDoctor(doctorId));
    return result.isFailure
        ? BackendResult.failure(result.failure!)
        : const BackendResult.success(null);
  }

  DoctorProfile _mapDoctorProfile(JsonMap json) {
    final fullName = (json['fullName'] ?? '').toString();
    final displayName =
        fullName.toLowerCase().startsWith('dr.') ? fullName : 'Dr. $fullName';
    final price = ((json['sessionPrice'] ?? 0) as num?)?.toInt() ?? 0;
    return DoctorProfile(
      id: (json['id'] ?? '').toString(),
      name: displayName,
      specialty: (json['specialization'] ?? '').toString(),
      experienceYears: ((json['experienceYears'] ?? 0) as num?)?.toInt() ?? 0,
      cardPrice: '$price EGP',
      sessionPrice: '$price EGP',
      imagePath: DoctorCatalog.imageForDoctorName(displayName),
      clinicAddress: (json['clinicAddress'] ?? '').toString(),
      bio: (json['bio'] ?? '').toString(),
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

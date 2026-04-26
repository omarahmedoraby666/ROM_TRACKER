import 'package:flutter/foundation.dart';
import 'package:rom_tracker_app/core/constants/app_assets.dart';
import 'package:rom_tracker_app/features/user_profile/presentation/models/user_profile_data.dart';

class UserProfileStore {
  static const UserProfileData _defaultPatientProfile = UserProfileData(
    firstName: 'Gamal',
    lastName: 'Ali',
    email: 'patient@app.com',
    phoneCode: '+20',
    phoneNumber: '123 456 7891',
    country: 'Egypt',
    gender: 'Male',
    avatarPath: AppAssets.phase2PatientAvatar,
  );

  static const UserProfileData _defaultDoctorProfile = UserProfileData(
    firstName: 'Mohamed',
    lastName: 'Alaa',
    email: 'doctor@app.com',
    phoneCode: '+20',
    phoneNumber: '123 456 7891',
    country: 'Egypt',
    gender: 'Male',
    avatarPath: AppAssets.phase2DoctorMohamed,
    specialization: 'Physical Therapist',
    clinicAddress: 'Active Care Physiotherapy Center Cairo',
  );

  static final ValueNotifier<UserProfileData> patientProfile =
      ValueNotifier<UserProfileData>(
    _defaultPatientProfile,
  );

  static final ValueNotifier<UserProfileData> doctorProfile =
      ValueNotifier<UserProfileData>(
    _defaultDoctorProfile,
  );

  static ValueNotifier<UserProfileData> notifierFor(String userType) {
    return userType == 'Doctor' ? doctorProfile : patientProfile;
  }

  static UserProfileData dataFor(String userType) {
    return notifierFor(userType).value;
  }

  static void update(String userType, UserProfileData data) {
    notifierFor(userType).value = data;
  }

  static void reset() {
    patientProfile.value = _defaultPatientProfile;
    doctorProfile.value = _defaultDoctorProfile;
  }

  static void setFromBackendUser(Map<String, dynamic> user) {
    final role = (user['role'] ?? '').toString().toLowerCase();
    final userType = role == 'doctor' ? 'Doctor' : 'Patient';
    final firstName = (user['firstName'] ?? '').toString();
    final lastName = (user['lastName'] ?? '').toString();

    final current = notifierFor(userType).value;
    notifierFor(userType).value = current.copyWith(
      firstName: firstName.isNotEmpty ? firstName : current.firstName,
      lastName: lastName.isNotEmpty ? lastName : current.lastName,
      email: (user['email'] ?? current.email).toString(),
      phoneCode: (user['phoneCode'] ?? current.phoneCode).toString(),
      phoneNumber: (user['phoneNumber'] ?? current.phoneNumber).toString(),
      country: (user['country'] ?? current.country).toString(),
      gender: (user['gender'] ?? current.gender).toString(),
      specialization:
          (user['specialization'] ?? current.specialization)?.toString(),
      clinicAddress:
          (user['clinicAddress'] ?? current.clinicAddress)?.toString(),
      avatarPath: _avatarForBackendUser(
        role: role,
        fullName: (user['fullName'] ?? '').toString(),
      ),
    );
  }

  static String _avatarForBackendUser({
    required String role,
    required String fullName,
  }) {
    final normalized = fullName.toLowerCase();
    if (role == 'doctor') {
      if (normalized.contains('mohamed')) return AppAssets.phase2DoctorMohamed;
      if (normalized.contains('sara')) return AppAssets.phase2DoctorSara;
      if (normalized.contains('lina')) return AppAssets.phase2DoctorLina;
      if (normalized.contains('ahmed')) return AppAssets.phase2DoctorAhmed;
      return AppAssets.phase2DoctorMohamed;
    }

    if (normalized.contains('younes')) return AppAssets.phase2PatientYounes;
    if (normalized.contains('adham')) return AppAssets.phase2PatientAdham;
    if (normalized.contains('arwa')) return AppAssets.phase2PatientArwa;
    return AppAssets.phase2PatientAvatar;
  }
}

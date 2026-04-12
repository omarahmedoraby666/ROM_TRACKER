import 'package:flutter/foundation.dart';
import 'package:rom_tracker_app/core/constants/app_assets.dart';
import 'package:rom_tracker_app/features/user_profile/presentation/models/user_profile_data.dart';

class UserProfileStore {
  static final ValueNotifier<UserProfileData> patientProfile =
      ValueNotifier<UserProfileData>(
    const UserProfileData(
      firstName: 'Gamal',
      lastName: 'Ali',
      email: 'patient@app.com',
      phoneCode: '+20',
      phoneNumber: '123 456 7891',
      country: 'Egypt',
      gender: 'Male',
      avatarPath: AppAssets.phase2PatientAvatar,
    ),
  );

  static final ValueNotifier<UserProfileData> doctorProfile =
      ValueNotifier<UserProfileData>(
    const UserProfileData(
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
    ),
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
}

import 'package:rom_tracker_app/core/constants/app_assets.dart';
import 'package:rom_tracker_app/features/doctors/presentation/models/doctor_profile.dart';

class DoctorCatalog {
  static const topDoctors = <DoctorProfile>[
    DoctorProfile(
      id: 'user_doctor_001',
      name: 'Dr. Mohamed Alaa',
      specialty: 'Physical Therapist',
      experienceYears: 10,
      cardPrice: '350 EGP',
      sessionPrice: '350 EGP',
      imagePath: AppAssets.phase2DoctorMohamed,
      clinicAddress: 'Active Care Physiotherapy Center Cairo',
      bio:
          'Specialized in treating back pain, neck pain, sports injuries, and post-surgery rehabilitation. Helps patients restore mobility and reduce pain using modern physiotherapy techniques.',
    ),
    DoctorProfile(
      id: 'user_doctor_002',
      name: 'Dr. Sara Ali',
      specialty: 'Rehabilitation Expert',
      experienceYears: 8,
      cardPrice: '320 EGP',
      sessionPrice: '320 EGP',
      imagePath: AppAssets.phase2DoctorSara,
      clinicAddress: 'Cairo Sports Rehab Clinic',
      bio:
          'Focuses on rehabilitation plans for mobility limitations and long-term recovery. Supports patients with personalized exercise programs and careful progress monitoring.',
    ),
    DoctorProfile(
      id: 'user_doctor_003',
      name: 'Dr. Lina Mostafa',
      specialty: 'Senior Physical Therapy',
      experienceYears: 2,
      cardPrice: '300 EGP',
      sessionPrice: '300 EGP',
      imagePath: AppAssets.phase2DoctorLina,
      clinicAddress: 'Neuro Motion Center Giza',
      bio:
          'Works with senior adults to improve balance, strength, and daily mobility. Helps reduce pain and improve quality of life through safe guided therapy routines.',
    ),
    DoctorProfile(
      id: 'user_doctor_004',
      name: 'Dr. Ahmed Hassan',
      specialty: 'Rehabilitation Specialist',
      experienceYears: 5,
      cardPrice: '330 EGP',
      sessionPrice: '330 EGP',
      imagePath: AppAssets.phase2DoctorAhmed,
      clinicAddress: 'Ortho Move Clinic Alexandria',
      bio:
          'Experienced in rehabilitation after injury and muscle recovery sessions. Uses targeted assessment and structured sessions to improve function and confidence.',
    ),
  ];

  static String imageForDoctorName(String name) {
    final normalized = name.toLowerCase();
    if (normalized.contains('mohamed')) return AppAssets.phase2DoctorMohamed;
    if (normalized.contains('sara')) return AppAssets.phase2DoctorSara;
    if (normalized.contains('lina')) return AppAssets.phase2DoctorLina;
    if (normalized.contains('ahmed')) return AppAssets.phase2DoctorAhmed;
    return AppAssets.phase2DoctorAvatar;
  }

  static DoctorProfile? findById(String? id) {
    if (id == null || id.isEmpty) return null;
    for (final doctor in topDoctors) {
      if (doctor.id == id) return doctor;
    }
    return null;
  }

  static DoctorProfile? findByName(String name) {
    final normalized = name.trim().toLowerCase();
    for (final doctor in topDoctors) {
      if (doctor.name.trim().toLowerCase() == normalized) {
        return doctor;
      }
    }
    return null;
  }
}

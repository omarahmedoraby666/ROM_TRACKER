import 'package:rom_tracker_app/core/constants/app_assets.dart';
import 'package:rom_tracker_app/features/doctors/presentation/models/doctor_profile.dart';

class DoctorCatalog {
  static const topDoctors = <DoctorProfile>[
    DoctorProfile(
      name: 'Dr. Mohamed Alaa',
      specialty: 'Physical Therapist',
      experienceYears: 10,
      cardPrice: '350 EGP',
      sessionPrice: '350 EGP',
      imagePath: AppAssets.phase2DoctorMohamed,
      bio:
          'Specialized in treating back pain, neck pain, sports injuries, and post-surgery rehabilitation. Helps patients restore mobility and reduce pain using modern physiotherapy techniques.',
    ),
    DoctorProfile(
      name: 'Dr. Sara Ali',
      specialty: 'Rehabilitation Expert',
      experienceYears: 8,
      cardPrice: '320 EGP',
      sessionPrice: '320 EGP',
      imagePath: AppAssets.phase2DoctorSara,
      bio:
          'Focuses on rehabilitation plans for mobility limitations and long-term recovery. Supports patients with personalized exercise programs and careful progress monitoring.',
    ),
    DoctorProfile(
      name: 'Dr. Lina Mostafa',
      specialty: 'Senior Physical Therapy',
      experienceYears: 2,
      cardPrice: '300 EGP',
      sessionPrice: '300 EGP',
      imagePath: AppAssets.phase2DoctorLina,
      bio:
          'Works with senior adults to improve balance, strength, and daily mobility. Helps reduce pain and improve quality of life through safe guided therapy routines.',
    ),
    DoctorProfile(
      name: 'Dr. Ahmed Hassan',
      specialty: 'Rehabilitation Specialist',
      experienceYears: 5,
      cardPrice: '330 EGP',
      sessionPrice: '330 EGP',
      imagePath: AppAssets.phase2DoctorAhmed,
      bio:
          'Experienced in rehabilitation after injury and muscle recovery sessions. Uses targeted assessment and structured sessions to improve function and confidence.',
    ),
  ];
}

class DoctorProfile {
  const DoctorProfile({
    this.id,
    required this.name,
    required this.specialty,
    required this.experienceYears,
    required this.cardPrice,
    required this.sessionPrice,
    required this.imagePath,
    required this.bio,
    this.clinicAddress,
  });

  final String? id;
  final String name;
  final String specialty;
  final int experienceYears;
  final String cardPrice;
  final String sessionPrice;
  final String imagePath;
  final String bio;
  final String? clinicAddress;
}

class DoctorProfile {
  const DoctorProfile({
    required this.name,
    required this.specialty,
    required this.experienceYears,
    required this.cardPrice,
    required this.sessionPrice,
    required this.imagePath,
    required this.bio,
  });

  final String name;
  final String specialty;
  final int experienceYears;
  final String cardPrice;
  final String sessionPrice;
  final String imagePath;
  final String bio;
}

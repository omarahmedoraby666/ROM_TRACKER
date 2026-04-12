class UserProfileData {
  const UserProfileData({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneCode,
    required this.phoneNumber,
    required this.country,
    required this.gender,
    required this.avatarPath,
    this.specialization,
    this.university,
    this.clinicAddress,
  });

  final String firstName;
  final String lastName;
  final String email;
  final String phoneCode;
  final String phoneNumber;
  final String country;
  final String gender;
  final String avatarPath;
  final String? specialization;
  final String? university;
  final String? clinicAddress;

  String get fullName => '$firstName $lastName';

  UserProfileData copyWith({
    String? firstName,
    String? lastName,
    String? email,
    String? phoneCode,
    String? phoneNumber,
    String? country,
    String? gender,
    String? avatarPath,
    String? specialization,
    String? university,
    String? clinicAddress,
  }) {
    return UserProfileData(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phoneCode: phoneCode ?? this.phoneCode,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      country: country ?? this.country,
      gender: gender ?? this.gender,
      avatarPath: avatarPath ?? this.avatarPath,
      specialization: specialization ?? this.specialization,
      university: university ?? this.university,
      clinicAddress: clinicAddress ?? this.clinicAddress,
    );
  }
}

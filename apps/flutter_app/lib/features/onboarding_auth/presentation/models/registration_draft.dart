class RegistrationDraft {
  const RegistrationDraft({
    required this.userType,
    this.firstName = '',
    this.lastName = '',
    this.email = '',
    this.phone = '',
    this.country = 'Egypt',
    this.gender = 'Male',
    this.age,
    this.condition,
    this.specialization,
    this.university = '',
    this.graduationYear = '',
    this.yearsOfExperience = '',
  });

  final String userType;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String country;
  final String gender;
  final int? age;
  final String? condition;
  final String? specialization;
  final String university;
  final String graduationYear;
  final String yearsOfExperience;

  bool get isDoctor => userType == 'Doctor';
  bool get isPatient => userType == 'Patient';

  RegistrationDraft copyWith({
    String? userType,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? country,
    String? gender,
    int? age,
    String? condition,
    String? specialization,
    String? university,
    String? graduationYear,
    String? yearsOfExperience,
  }) {
    return RegistrationDraft(
      userType: userType ?? this.userType,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      country: country ?? this.country,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      condition: condition ?? this.condition,
      specialization: specialization ?? this.specialization,
      university: university ?? this.university,
      graduationYear: graduationYear ?? this.graduationYear,
      yearsOfExperience: yearsOfExperience ?? this.yearsOfExperience,
    );
  }
}

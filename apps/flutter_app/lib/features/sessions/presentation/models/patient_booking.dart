class PatientBooking {
  const PatientBooking({
    required this.doctorName,
    required this.specialty,
    required this.imagePath,
    required this.dayLabel,
    required this.dayNumber,
    required this.timeLabel,
    required this.reason,
    this.patientName,
    this.patientAge,
    this.patientGender,
  });

  final String doctorName;
  final String specialty;
  final String imagePath;
  final String dayLabel;
  final String dayNumber;
  final String timeLabel;
  final String reason;
  final String? patientName;
  final String? patientAge;
  final String? patientGender;
}

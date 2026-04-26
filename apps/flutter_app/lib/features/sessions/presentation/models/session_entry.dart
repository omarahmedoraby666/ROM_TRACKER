enum SessionStage { upcoming, completed, canceled }

class SessionEntry {
  const SessionEntry({
    required this.id,
    this.doctorId,
    required this.doctorName,
    required this.specialty,
    required this.time,
    required this.imagePath,
    required this.notes,
    this.review,
  });

  final String id;
  final String? doctorId;
  final String doctorName;
  final String specialty;
  final String time;
  final String imagePath;
  final String notes;
  final String? review;

  SessionEntry copyWith({
    String? id,
    String? doctorId,
    String? doctorName,
    String? specialty,
    String? time,
    String? imagePath,
    String? notes,
    String? review,
  }) {
    return SessionEntry(
      id: id ?? this.id,
      doctorId: doctorId ?? this.doctorId,
      doctorName: doctorName ?? this.doctorName,
      specialty: specialty ?? this.specialty,
      time: time ?? this.time,
      imagePath: imagePath ?? this.imagePath,
      notes: notes ?? this.notes,
      review: review ?? this.review,
    );
  }
}

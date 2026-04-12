enum DoctorSessionStage { upcoming, completed, canceled }

class DoctorSessionEntry {
  const DoctorSessionEntry({
    required this.id,
    required this.patientName,
    required this.condition,
    required this.time,
    required this.imagePath,
    required this.threadId,
    required this.notes,
    required this.stage,
    required this.ctaLabel,
  });

  final String id;
  final String patientName;
  final String condition;
  final String time;
  final String imagePath;
  final String threadId;
  final String notes;
  final DoctorSessionStage stage;
  final String ctaLabel;

  DoctorSessionEntry copyWith({
    String? id,
    String? patientName,
    String? condition,
    String? time,
    String? imagePath,
    String? threadId,
    String? notes,
    DoctorSessionStage? stage,
    String? ctaLabel,
  }) {
    return DoctorSessionEntry(
      id: id ?? this.id,
      patientName: patientName ?? this.patientName,
      condition: condition ?? this.condition,
      time: time ?? this.time,
      imagePath: imagePath ?? this.imagePath,
      threadId: threadId ?? this.threadId,
      notes: notes ?? this.notes,
      stage: stage ?? this.stage,
      ctaLabel: ctaLabel ?? this.ctaLabel,
    );
  }
}

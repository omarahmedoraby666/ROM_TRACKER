class DoctorSlot {
  const DoctorSlot({
    required this.id,
    required this.scheduledAt,
    required this.displayTime,
    required this.isBooked,
  });

  final String id;
  final String scheduledAt;
  final String displayTime;
  final bool isBooked;

  factory DoctorSlot.fromJson(Map<String, dynamic> json) {
    return DoctorSlot(
      id: (json['id'] ?? '').toString(),
      scheduledAt: (json['scheduledAt'] ?? '').toString(),
      displayTime: (json['displayTime'] ?? '').toString(),
      isBooked: json['isBooked'] == true,
    );
  }
}

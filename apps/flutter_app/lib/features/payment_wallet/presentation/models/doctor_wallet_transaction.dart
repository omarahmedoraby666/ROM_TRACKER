enum DoctorWalletTransactionStatus {
  pending,
  available,
  canceled,
}

class DoctorWalletTransaction {
  const DoctorWalletTransaction({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.status,
    this.linkedDoctorSessionId,
  });

  final String id;
  final String title;
  final String subtitle;
  final int amount;
  final DoctorWalletTransactionStatus status;
  final String? linkedDoctorSessionId;

  DoctorWalletTransaction copyWith({
    String? id,
    String? title,
    String? subtitle,
    int? amount,
    DoctorWalletTransactionStatus? status,
    String? linkedDoctorSessionId,
  }) {
    return DoctorWalletTransaction(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      amount: amount ?? this.amount,
      status: status ?? this.status,
      linkedDoctorSessionId: linkedDoctorSessionId ?? this.linkedDoctorSessionId,
    );
  }
}

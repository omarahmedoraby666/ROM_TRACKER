import 'package:flutter/foundation.dart';
import 'package:rom_tracker_app/features/payment_wallet/presentation/models/doctor_wallet_transaction.dart';

class DoctorWalletStore {
  static final ValueNotifier<List<DoctorWalletTransaction>> transactions =
      ValueNotifier<List<DoctorWalletTransaction>>([]);

  static bool _seeded = false;
  static int _counter = 0;

  static void ensureSeeded() {
    if (_seeded) return;
    transactions.value = [
      _entry(
        title: 'Receive',
        subtitle: 'Ana Williams - 12 March - 6:00 pm',
        amount: 300,
        status: DoctorWalletTransactionStatus.available,
      ),
      _entry(
        title: 'Receive',
        subtitle: 'Osama Elsayed - 15 March - 9:00 pm',
        amount: 250,
        status: DoctorWalletTransactionStatus.available,
      ),
    ];
    _seeded = true;
  }

  static String addPendingBooking({
    required String patientName,
    required String schedule,
    required int amount,
    required String doctorSessionId,
  }) {
    ensureSeeded();
    final item = _entry(
      title: 'Receive',
      subtitle: '$patientName - $schedule',
      amount: amount,
      status: DoctorWalletTransactionStatus.pending,
      linkedDoctorSessionId: doctorSessionId,
    );
    transactions.value = [item, ...transactions.value];
    return item.id;
  }

  static void markAvailable(String id) {
    ensureSeeded();
    transactions.value = transactions.value
        .map(
          (item) => item.id == id
              ? item.copyWith(status: DoctorWalletTransactionStatus.available)
              : item,
        )
        .toList();
  }

  static void markCanceled(String id) {
    ensureSeeded();
    transactions.value = transactions.value
        .map(
          (item) => item.id == id
              ? item.copyWith(status: DoctorWalletTransactionStatus.canceled)
              : item,
        )
        .toList();
  }

  static void markPending(String id) {
    ensureSeeded();
    transactions.value = transactions.value
        .map(
          (item) => item.id == id
              ? item.copyWith(status: DoctorWalletTransactionStatus.pending)
              : item,
        )
        .toList();
  }

  static DoctorWalletTransaction _entry({
    required String title,
    required String subtitle,
    required int amount,
    required DoctorWalletTransactionStatus status,
    String? linkedDoctorSessionId,
  }) {
    _counter += 1;
    return DoctorWalletTransaction(
      id: 'wallet_tx_$_counter',
      title: title,
      subtitle: subtitle,
      amount: amount,
      status: status,
      linkedDoctorSessionId: linkedDoctorSessionId,
    );
  }
}

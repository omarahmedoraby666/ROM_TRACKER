import 'package:flutter/foundation.dart';
import 'package:rom_tracker_app/core/network/backend_client.dart';
import 'package:rom_tracker_app/features/onboarding_auth/presentation/models/auth_session_store.dart';
import 'package:rom_tracker_app/features/sessions/data/backend_sessions_api.dart';
import 'package:rom_tracker_app/features/payment_wallet/presentation/models/doctor_wallet_transaction.dart';

class DoctorWalletStore {
  static final ValueNotifier<List<DoctorWalletTransaction>> transactions =
      ValueNotifier<List<DoctorWalletTransaction>>([]);

  static bool _seeded = false;
  static int _counter = 0;

  static void ensureSeeded() {
    if (_seeded) return;
    if (BackendClient.instance.isConfigured &&
        AuthSessionStore.isAuthenticated &&
        AuthSessionStore.userType.value == 'Doctor') {
      transactions.value = [];
      _seeded = true;
      refreshFromBackend();
      return;
    }
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

  static Future<void> refreshFromBackend() async {
    if (!BackendClient.instance.isConfigured ||
        !AuthSessionStore.isAuthenticated ||
        AuthSessionStore.userType.value != 'Doctor') {
      ensureSeeded();
      return;
    }

    final result = await BackendSessionsApi.instance.getDoctorWallet();
    if (result.isFailure) return;
    final rawItems = result.data?['items'];
    if (rawItems is! List) return;

    transactions.value = rawItems
        .whereType<Map>()
        .map((item) => _fromBackend(Map<String, dynamic>.from(item)))
        .toList();
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

  static void reset() {
    transactions.value = [];
    _seeded = false;
  }

  static DoctorWalletTransaction _fromBackend(Map<String, dynamic> json) {
    final status = switch ((json['status'] ?? '').toString()) {
      'available' => DoctorWalletTransactionStatus.available,
      'canceled' => DoctorWalletTransactionStatus.canceled,
      _ => DoctorWalletTransactionStatus.pending,
    };
    return DoctorWalletTransaction(
      id: (json['id'] ?? '').toString(),
      title: 'Receive',
      subtitle:
          '${(json['patientName'] ?? '').toString()} - ${(json['description'] ?? '').toString()}',
      amount: ((json['amount'] ?? 0) as num?)?.toInt() ?? 0,
      status: status,
      linkedDoctorSessionId: (json['sessionId'] ?? '').toString(),
    );
  }
}

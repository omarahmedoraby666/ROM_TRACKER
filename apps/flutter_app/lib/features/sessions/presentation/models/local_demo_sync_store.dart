import 'package:rom_tracker_app/core/network/backend_client.dart';
import 'package:rom_tracker_app/features/chat/presentation/models/chat_store.dart';
import 'package:rom_tracker_app/features/doctors/presentation/models/doctor_catalog.dart';
import 'package:rom_tracker_app/features/notifications/presentation/models/notification_store.dart';
import 'package:rom_tracker_app/features/onboarding_auth/presentation/models/auth_session_store.dart';
import 'package:rom_tracker_app/features/payment_wallet/presentation/models/doctor_wallet_store.dart';
import 'package:rom_tracker_app/features/sessions/data/backend_sessions_api.dart';
import 'package:rom_tracker_app/features/sessions/presentation/models/booking_store.dart';
import 'package:rom_tracker_app/features/sessions/presentation/models/doctor_session_entry.dart';
import 'package:rom_tracker_app/features/sessions/presentation/models/doctor_session_store.dart';
import 'package:rom_tracker_app/features/sessions/presentation/models/patient_booking.dart';
import 'package:rom_tracker_app/features/sessions/presentation/models/session_entry.dart';
import 'package:rom_tracker_app/features/user_profile/presentation/models/user_profile_store.dart';

class LocalDemoSyncStore {
  static const linkedDoctorName = 'Dr. Mohamed Alaa';

  static final Map<String, String> _patientToDoctor = {};
  static final Map<String, String> _doctorToPatient = {};
  static final Map<String, String> _patientToWalletTransaction = {};

  static bool get _useBackend =>
      BackendClient.instance.isConfigured && AuthSessionStore.isAuthenticated;

  static Future<String?> confirmPatientBooking(PatientBooking booking) async {
    if (_useBackend && booking.doctorId != null && booking.slotId != null) {
      final result = await BackendSessionsApi.instance.createBooking({
        'doctorId': booking.doctorId,
        'slotId': booking.slotId,
        'reason': booking.reason,
        if (booking.patientAge != null)
          'patientAge': int.tryParse(booking.patientAge!),
        if (booking.patientGender != null) 'patientGender': booking.patientGender,
      });
      if (result.isFailure) {
        throw Exception(result.failure?.message ?? 'Booking failed');
      }
      await BookingStore.refreshFromBackend();
      await NotificationStore.refreshFromBackend();
      final session = result.data?['session'];
      if (session is Map) {
        return (session['id'] ?? '').toString();
      }
      return null;
    }

    final patientSessionId = BookingStore.addUpcoming(booking);
    NotificationStore.addPatientBookingFlow(booking);

    if (!_isLinkedDoctorBooking(booking.doctorName)) {
      return patientSessionId;
    }

    final patientProfile = UserProfileStore.patientProfile.value;
    final patientName = patientProfile.fullName;
    final schedule =
        '${booking.dayLabel} ${booking.dayNumber} - ${booking.timeLabel}';
    final doctorThreadId = ChatStore.ensureLinkedDoctorThread();
    final doctorSessionId = DoctorSessionStore.addUpcomingLinkedBooking(
      patientName: patientName,
      condition: booking.reason.isEmpty ? booking.specialty : booking.reason,
      time: schedule,
      imagePath: patientProfile.avatarPath,
      threadId: doctorThreadId,
      notes:
          'New booking received from $patientName. Review the symptoms and start with the planned physical therapy routine.',
    );

    final transactionId = DoctorWalletStore.addPendingBooking(
      patientName: patientName,
      schedule: schedule,
      amount: _amountForDoctor(booking.doctorName),
      doctorSessionId: doctorSessionId,
    );

    _patientToDoctor[patientSessionId] = doctorSessionId;
    _doctorToPatient[doctorSessionId] = patientSessionId;
    _patientToWalletTransaction[patientSessionId] = transactionId;

    NotificationStore.addDoctorBookingNotification(
      patientName: patientName,
      schedule: schedule,
    );
    return patientSessionId;
  }

  static Future<void> patientCancelUpcoming(String patientSessionId) async {
    if (_useBackend) {
      final result = await BackendSessionsApi.instance.updateSessionStatus(
        sessionId: patientSessionId,
        status: 'canceled',
      );
      if (result.isFailure) {
        throw Exception(result.failure?.message ?? 'Failed to cancel session');
      }
      await BookingStore.refreshFromBackend();
      await NotificationStore.refreshFromBackend();
      return;
    }

    final session = BookingStore.byId(patientSessionId);
    final moved = BookingStore.cancelUpcoming(patientSessionId);
    if (moved == null) return;

    final doctorSessionId = _patientToDoctor[patientSessionId];
    if (doctorSessionId != null) {
      DoctorSessionStore.cancelUpcoming(doctorSessionId);
      final transactionId = _patientToWalletTransaction[patientSessionId];
      if (transactionId != null) {
        DoctorWalletStore.markCanceled(transactionId);
      }
      final patientName = _patientNameForLinkedSession(session);
      NotificationStore.addDoctorSessionUpdate(
        title: 'Session canceled by $patientName',
        body:
            '$patientName canceled the upcoming session. The payment was marked as canceled locally.',
      );
    }
  }

  static Future<void> patientCompleteUpcoming(String patientSessionId) async {
    if (_useBackend) {
      final result = await BackendSessionsApi.instance.updateSessionStatus(
        sessionId: patientSessionId,
        status: 'completed',
      );
      if (result.isFailure) {
        throw Exception(result.failure?.message ?? 'Failed to complete session');
      }
      await BookingStore.refreshFromBackend();
      await NotificationStore.refreshFromBackend();
      return;
    }

    final moved = BookingStore.completeUpcoming(patientSessionId);
    if (moved == null) return;

    final doctorSessionId = _patientToDoctor[patientSessionId];
    if (doctorSessionId != null) {
      DoctorSessionStore.completeUpcoming(doctorSessionId);
      final transactionId = _patientToWalletTransaction[patientSessionId];
      if (transactionId != null) {
        DoctorWalletStore.markAvailable(transactionId);
      }
      NotificationStore.addDoctorSessionUpdate(
        title: 'Session completed',
        body:
            '${_patientNameForLinkedSession(moved)} completed the linked session. The wallet balance was updated locally.',
      );
    }
  }

  static Future<void> doctorCancelUpcoming(String doctorSessionId) async {
    if (_useBackend) {
      final result = await BackendSessionsApi.instance.updateSessionStatus(
        sessionId: doctorSessionId,
        status: 'canceled',
      );
      if (result.isFailure) {
        throw Exception(result.failure?.message ?? 'Failed to cancel session');
      }
      await DoctorSessionStore.refreshFromBackend();
      await NotificationStore.refreshFromBackend();
      await DoctorWalletStore.refreshFromBackend();
      return;
    }

    final moved = DoctorSessionStore.cancelUpcoming(doctorSessionId);
    if (moved == null) return;

    final patientSessionId = _doctorToPatient[doctorSessionId];
    if (patientSessionId != null) {
      BookingStore.cancelUpcoming(patientSessionId);
      final transactionId = _patientToWalletTransaction[patientSessionId];
      if (transactionId != null) {
        DoctorWalletStore.markCanceled(transactionId);
      }
      NotificationStore.addPatientSessionUpdate(
        title: 'Session canceled',
        body:
            'Dr. ${UserProfileStore.doctorProfile.value.fullName} canceled your linked session. Check your canceled sessions for details.',
      );
    }
  }

  static Future<void> doctorCompleteUpcoming(String doctorSessionId) async {
    if (_useBackend) {
      final result = await BackendSessionsApi.instance.updateSessionStatus(
        sessionId: doctorSessionId,
        status: 'completed',
      );
      if (result.isFailure) {
        throw Exception(result.failure?.message ?? 'Failed to complete session');
      }
      await DoctorSessionStore.refreshFromBackend();
      await NotificationStore.refreshFromBackend();
      await DoctorWalletStore.refreshFromBackend();
      return;
    }

    final moved = DoctorSessionStore.completeUpcoming(doctorSessionId);
    if (moved == null) return;

    final patientSessionId = _doctorToPatient[doctorSessionId];
    if (patientSessionId != null) {
      BookingStore.completeUpcoming(patientSessionId);
      final transactionId = _patientToWalletTransaction[patientSessionId];
      if (transactionId != null) {
        DoctorWalletStore.markAvailable(transactionId);
      }
      NotificationStore.addPatientSessionUpdate(
        title: 'Session completed',
        body:
            'Dr. ${UserProfileStore.doctorProfile.value.fullName} marked your linked session as completed.',
      );
    }
  }

  static Future<void> doctorRestoreToUpcoming({
    required DoctorSessionStage fromStage,
    required String doctorSessionId,
  }) async {
    if (_useBackend) {
      final result = await BackendSessionsApi.instance.updateSessionStatus(
        sessionId: doctorSessionId,
        status: 'upcoming',
      );
      if (result.isFailure) {
        throw Exception(result.failure?.message ?? 'Failed to restore session');
      }
      await DoctorSessionStore.refreshFromBackend();
      await NotificationStore.refreshFromBackend();
      await DoctorWalletStore.refreshFromBackend();
      return;
    }

    final moved = DoctorSessionStore.restoreToUpcoming(
      fromStage: fromStage,
      id: doctorSessionId,
    );
    if (moved == null) return;

    final patientSessionId = _doctorToPatient[doctorSessionId];
    if (patientSessionId != null) {
      BookingStore.restoreToUpcoming(
        fromStage: _patientStageForDoctorStage(fromStage),
        id: patientSessionId,
      );
      final transactionId = _patientToWalletTransaction[patientSessionId];
      if (transactionId != null) {
        DoctorWalletStore.markPending(transactionId);
      }
      NotificationStore.addPatientSessionUpdate(
        title: 'Session moved to upcoming',
        body:
            'Dr. ${UserProfileStore.doctorProfile.value.fullName} moved your linked session back to upcoming.',
      );
    }
  }

  static bool _isLinkedDoctorBooking(String doctorName) {
    final normalizedDoctor = doctorName.toLowerCase();
    return normalizedDoctor.contains(linkedDoctorName.toLowerCase());
  }

  static int _amountForDoctor(String doctorName) {
    final normalized = doctorName.toLowerCase();
    for (final doctor in DoctorCatalog.topDoctors) {
      final doctorNameLower = doctor.name.toLowerCase();
      if (doctorNameLower == normalized || normalized.contains(doctorNameLower)) {
        return int.tryParse(doctor.sessionPrice.split(' ').first) ?? 350;
      }
    }
    return 350;
  }

  static String _patientNameForLinkedSession(SessionEntry? session) {
    return UserProfileStore.patientProfile.value.fullName;
  }

  static SessionStage _patientStageForDoctorStage(DoctorSessionStage stage) {
    switch (stage) {
      case DoctorSessionStage.upcoming:
        return SessionStage.upcoming;
      case DoctorSessionStage.completed:
        return SessionStage.completed;
      case DoctorSessionStage.canceled:
        return SessionStage.canceled;
    }
  }
}

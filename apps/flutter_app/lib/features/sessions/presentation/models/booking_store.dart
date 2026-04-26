import 'package:flutter/foundation.dart';
import 'package:rom_tracker_app/core/network/backend_client.dart';
import 'package:rom_tracker_app/core/constants/app_assets.dart';
import 'package:rom_tracker_app/features/onboarding_auth/presentation/models/auth_session_store.dart';
import 'package:rom_tracker_app/features/sessions/data/backend_session_mapper.dart';
import 'package:rom_tracker_app/features/sessions/data/backend_sessions_api.dart';
import 'package:rom_tracker_app/features/sessions/presentation/models/patient_booking.dart';
import 'package:rom_tracker_app/features/sessions/presentation/models/session_entry.dart';

class BookingStore {
  static final ValueNotifier<List<SessionEntry>> upcomingSessions =
      ValueNotifier<List<SessionEntry>>([]);
  static final ValueNotifier<List<SessionEntry>> completedSessions =
      ValueNotifier<List<SessionEntry>>([]);
  static final ValueNotifier<List<SessionEntry>> canceledSessions =
      ValueNotifier<List<SessionEntry>>([]);

  static bool _seeded = false;
  static int _idCounter = 100;

  static void ensureSeeded() {
    if (_seeded) return;
    if (BackendClient.instance.isConfigured && AuthSessionStore.isAuthenticated) {
      upcomingSessions.value = [];
      completedSessions.value = [];
      canceledSessions.value = [];
      _seeded = true;
      refreshFromBackend();
      return;
    }
    upcomingSessions.value = [
      _entry(
        doctorName: 'Dr. Mohamed Alaa',
        specialty: 'Physical Therapist',
        time: '10:30 am - 12:30 pm',
        imagePath: AppAssets.phase2DoctorMohamed,
      ),
      _entry(
        doctorName: 'Dr. Sara Ali',
        specialty: 'Rehabilitation Expert',
        time: '11:30 am - 1:30 pm',
        imagePath: AppAssets.phase2DoctorSara,
      ),
    ];
    completedSessions.value = [
      _entry(
        doctorName: 'Dr. Sara Ali',
        specialty: 'Rehabilitation Expert',
        time: '12 March - 6:00 pm',
        imagePath: AppAssets.phase2DoctorSara,
      ),
      _entry(
        doctorName: 'Dr. Mohamed Alaa',
        specialty: 'Physical Therapist',
        time: '15 March - 9:00 pm',
        imagePath: AppAssets.phase2DoctorMohamed,
      ),
      _entry(
        doctorName: 'Dr. Ahmed Hassan',
        specialty: 'Rehabilitation Specialist',
        time: '22 March - 3:00 pm',
        imagePath: AppAssets.phase2DoctorAhmed,
      ),
    ];
    canceledSessions.value = [
      _entry(
        doctorName: 'Dr. Lina Mostafa',
        specialty: 'Senior Physical Therapy',
        time: '18 March - 2:00 pm',
        imagePath: AppAssets.phase2DoctorLina,
      ),
    ];
    _seeded = true;
  }

  static Future<void> refreshFromBackend() async {
    if (!BackendClient.instance.isConfigured || !AuthSessionStore.isAuthenticated) {
      ensureSeeded();
      return;
    }

    final result = await BackendSessionsApi.instance.getPatientSessions();
    if (result.isFailure) return;

    final items = result.data!
        .map(BackendSessionMapper.toPatientSession)
        .toList();
    upcomingSessions.value = [
      for (final item in items)
        if (_statusForItem(result.data!, item.id) == SessionStage.upcoming) item,
    ];
    completedSessions.value = [
      for (final item in items)
        if (_statusForItem(result.data!, item.id) == SessionStage.completed) item,
    ];
    canceledSessions.value = [
      for (final item in items)
        if (_statusForItem(result.data!, item.id) == SessionStage.canceled) item,
    ];
    _seeded = true;
  }

  static void reset() {
    upcomingSessions.value = [];
    completedSessions.value = [];
    canceledSessions.value = [];
    _seeded = false;
  }

  static String addUpcoming(PatientBooking booking) {
    ensureSeeded();
    final entry = _entry(
      doctorId: booking.doctorId,
      doctorName: booking.doctorName,
      specialty: booking.specialty,
      time: '${booking.dayLabel} ${booking.dayNumber} - ${booking.timeLabel}',
      imagePath: booking.imagePath,
    );
    final items = List<SessionEntry>.from(upcomingSessions.value)
      ..insert(0, entry);
    upcomingSessions.value = items;
    return entry.id;
  }

  static String addUpcomingEntry(SessionEntry entry) {
    ensureSeeded();
    final items = List<SessionEntry>.from(upcomingSessions.value)
      ..insert(0, entry);
    upcomingSessions.value = items;
    return entry.id;
  }

  static SessionEntry? completeUpcoming(String id) {
    ensureSeeded();
    final current = List<SessionEntry>.from(upcomingSessions.value);
    final index = current.indexWhere((item) => item.id == id);
    if (index == -1) return null;
    final session = current.removeAt(index);
    upcomingSessions.value = current;

    final completed = List<SessionEntry>.from(completedSessions.value);
    completed.insert(0, session);
    completedSessions.value = completed;
    return session;
  }

  static SessionEntry? cancelUpcoming(String id) {
    ensureSeeded();
    final current = List<SessionEntry>.from(upcomingSessions.value);
    final index = current.indexWhere((item) => item.id == id);
    if (index == -1) return null;
    final session = current.removeAt(index);
    upcomingSessions.value = current;

    final canceled = List<SessionEntry>.from(canceledSessions.value);
    canceled.insert(0, session);
    canceledSessions.value = canceled;
    return session;
  }

  static SessionEntry? restoreToUpcoming({
    required SessionStage fromStage,
    required String id,
    String? time,
  }) {
    ensureSeeded();
    switch (fromStage) {
      case SessionStage.upcoming:
        return null;
      case SessionStage.completed:
        final completed = List<SessionEntry>.from(completedSessions.value);
        final index = completed.indexWhere((item) => item.id == id);
        if (index == -1) return null;
        final session = completed.removeAt(index).copyWith(
          time: time ?? 'Next follow-up - 5:00 pm',
        );
        completedSessions.value = completed;
        upcomingSessions.value = [session, ...upcomingSessions.value];
        return session;
      case SessionStage.canceled:
        final canceled = List<SessionEntry>.from(canceledSessions.value);
        final index = canceled.indexWhere((item) => item.id == id);
        if (index == -1) return null;
        final session = canceled.removeAt(index).copyWith(
          time: time ?? 'Rescheduled - 4:00 pm',
        );
        canceledSessions.value = canceled;
        upcomingSessions.value = [session, ...upcomingSessions.value];
        return session;
    }
  }

  static SessionEntry? byId(String id) {
    ensureSeeded();
    for (final item in [
      ...upcomingSessions.value,
      ...completedSessions.value,
      ...canceledSessions.value,
    ]) {
      if (item.id == id) return item;
    }
    return null;
  }

  static SessionEntry createEntry({
    String? doctorId,
    required String doctorName,
    required String specialty,
    required String time,
    required String imagePath,
    String? notes,
  }) {
    final entry = SessionEntry(
      id: _nextId(),
      doctorId: doctorId,
      doctorName: doctorName,
      specialty: specialty,
      time: time,
      imagePath: imagePath,
      notes: notes ?? _notesForSpecialty(specialty),
    );
    return entry;
  }

  static SessionEntry rebook(SessionEntry session) {
    ensureSeeded();
    final rebooked = session.copyWith(
      id: _nextId(),
      time: 'Next available - 5:00 pm',
    );
    final upcoming = List<SessionEntry>.from(upcomingSessions.value)
      ..insert(0, rebooked);
    upcomingSessions.value = upcoming;
    return rebooked;
  }

  static void saveReview({
    required SessionStage stage,
    required String id,
    required String review,
  }) {
    ensureSeeded();
    switch (stage) {
      case SessionStage.upcoming:
        upcomingSessions.value = _replaceReview(
          upcomingSessions.value,
          id,
          review,
        );
        break;
      case SessionStage.completed:
        completedSessions.value = _replaceReview(
          completedSessions.value,
          id,
          review,
        );
        break;
      case SessionStage.canceled:
        canceledSessions.value = _replaceReview(
          canceledSessions.value,
          id,
          review,
        );
        break;
    }
  }

  static List<SessionEntry> _replaceReview(
    List<SessionEntry> source,
    String id,
    String review,
  ) {
    return source
        .map(
          (item) => item.id == id ? item.copyWith(review: review) : item,
        )
        .toList();
  }

  static SessionEntry _entry({
    String? doctorId,
    required String doctorName,
    required String specialty,
    required String time,
    required String imagePath,
  }) {
    return createEntry(
      doctorId: doctorId,
      doctorName: doctorName,
      specialty: specialty,
      time: time,
      imagePath: imagePath,
    );
  }

  static String _notesForSpecialty(String specialty) {
    if (specialty.contains('Physical Therapist')) {
      return 'Focus on posture correction and daily stretching exercises.';
    }
    if (specialty.contains('Rehabilitation Expert')) {
      return 'Continue balance drills and mobility recovery exercises at home.';
    }
    if (specialty.contains('Senior Physical Therapy')) {
      return 'Follow low-impact movement drills and avoid sudden strain.';
    }
    if (specialty.contains('Rehabilitation Specialist')) {
      return 'Keep muscle recovery sessions consistent and track pain levels.';
    }
    return 'Stay consistent with your therapy plan and follow the session guidance.';
  }

  static String _nextId() {
    _idCounter += 1;
    return 'session_$_idCounter';
  }

  static SessionStage _statusForItem(
    List<Map<String, dynamic>> source,
    String id,
  ) {
    final raw = source.firstWhere(
      (item) => (item['id'] ?? '').toString() == id,
      orElse: () => const <String, dynamic>{},
    );
    return switch ((raw['status'] ?? 'upcoming').toString()) {
      'completed' => SessionStage.completed,
      'canceled' => SessionStage.canceled,
      _ => SessionStage.upcoming,
    };
  }
}

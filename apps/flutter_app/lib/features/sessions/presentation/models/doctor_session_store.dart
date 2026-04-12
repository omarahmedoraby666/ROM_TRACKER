import 'package:flutter/foundation.dart';
import 'package:rom_tracker_app/core/constants/app_assets.dart';
import 'package:rom_tracker_app/features/sessions/presentation/models/doctor_session_entry.dart';

class DoctorSessionStore {
  static final ValueNotifier<List<DoctorSessionEntry>> upcomingSessions =
      ValueNotifier<List<DoctorSessionEntry>>([]);
  static final ValueNotifier<List<DoctorSessionEntry>> completedSessions =
      ValueNotifier<List<DoctorSessionEntry>>([]);
  static final ValueNotifier<List<DoctorSessionEntry>> canceledSessions =
      ValueNotifier<List<DoctorSessionEntry>>([]);

  static bool _seeded = false;
  static int _counter = 40;

  static void ensureSeeded() {
    if (_seeded) return;

    upcomingSessions.value = [
      _entry(
        patientName: 'Younes Ashraf',
        condition: 'Carpal tunnel syndrome',
        time: '9:30 am - 11:30 am',
        imagePath: AppAssets.phase2PatientYounes,
        threadId: 'd_younes',
        notes:
            'Start with wrist mobility drills, then continue the guided resistance routine.',
        ctaLabel: 'Go To Session',
      ),
      _entry(
        patientName: 'Adham Yasser',
        condition: 'Carpal tunnel syndrome',
        time: '12:00 pm - 2:00 pm',
        imagePath: AppAssets.phase2PatientAdham,
        threadId: 'd_adham',
        notes:
            'Review daily exercise adherence before the session and confirm pain level.',
        ctaLabel: 'Waiting Session',
      ),
      _entry(
        patientName: 'Arwa Ahmed',
        condition: 'Muscle recovery plan',
        time: '2:30 pm - 4:30 pm',
        imagePath: AppAssets.phase2PatientArwa,
        threadId: 'd_arwa',
        notes:
            'Keep the session low-impact and stay within the safe range of motion.',
        ctaLabel: 'Upcoming',
      ),
    ];

    completedSessions.value = [
      _entry(
        patientName: 'Ana Williams',
        condition: 'Parkinson support plan',
        time: '12 March - 6:00 pm',
        imagePath: AppAssets.phase2PatientYounes,
        threadId: 'd_younes',
        notes:
            'Balance drills improved today. Continue short guided sessions and monitor fatigue.',
        ctaLabel: 'View Details',
        stage: DoctorSessionStage.completed,
      ),
      _entry(
        patientName: 'Osama Elsayed',
        condition: 'Lymphedema',
        time: '15 March - 9:00 pm',
        imagePath: AppAssets.phase2PatientAdham,
        threadId: 'd_adham',
        notes:
            'Compression routine explained. Encourage daily follow-up and hydration tracking.',
        ctaLabel: 'View Details',
        stage: DoctorSessionStage.completed,
      ),
    ];

    canceledSessions.value = [
      _entry(
        patientName: 'Yousra Zain',
        condition: 'Muscular dystrophies',
        time: '18 March - 2:00 pm',
        imagePath: AppAssets.phase2PatientArwa,
        threadId: 'd_arwa',
        notes:
            'Session was postponed. Follow up later to confirm the next suitable appointment.',
        ctaLabel: 'Canceled',
        stage: DoctorSessionStage.canceled,
      ),
    ];

    _seeded = true;
  }

  static DoctorSessionEntry? byId(String id) {
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

  static void updateNotes({
    required DoctorSessionStage stage,
    required String id,
    required String notes,
  }) {
    ensureSeeded();
    switch (stage) {
      case DoctorSessionStage.upcoming:
        upcomingSessions.value = _replace(
          upcomingSessions.value,
          id,
          (item) => item.copyWith(notes: notes),
        );
        break;
      case DoctorSessionStage.completed:
        completedSessions.value = _replace(
          completedSessions.value,
          id,
          (item) => item.copyWith(notes: notes),
        );
        break;
      case DoctorSessionStage.canceled:
        canceledSessions.value = _replace(
          canceledSessions.value,
          id,
          (item) => item.copyWith(notes: notes),
        );
        break;
    }
  }

  static DoctorSessionEntry? completeUpcoming(String id) {
    ensureSeeded();
    final current = List<DoctorSessionEntry>.from(upcomingSessions.value);
    final index = current.indexWhere((item) => item.id == id);
    if (index == -1) return null;
    final session = current.removeAt(index).copyWith(
      stage: DoctorSessionStage.completed,
      ctaLabel: 'View Details',
    );
    upcomingSessions.value = current;
    completedSessions.value = [session, ...completedSessions.value];
    return session;
  }

  static DoctorSessionEntry? cancelUpcoming(String id) {
    ensureSeeded();
    final current = List<DoctorSessionEntry>.from(upcomingSessions.value);
    final index = current.indexWhere((item) => item.id == id);
    if (index == -1) return null;
    final session = current.removeAt(index).copyWith(
      stage: DoctorSessionStage.canceled,
      ctaLabel: 'Canceled',
    );
    upcomingSessions.value = current;
    canceledSessions.value = [session, ...canceledSessions.value];
    return session;
  }

  static DoctorSessionEntry? restoreToUpcoming({
    required DoctorSessionStage fromStage,
    required String id,
  }) {
    ensureSeeded();
    switch (fromStage) {
      case DoctorSessionStage.upcoming:
        return null;
      case DoctorSessionStage.completed:
        final completed = List<DoctorSessionEntry>.from(completedSessions.value);
        final completedIndex = completed.indexWhere((item) => item.id == id);
        if (completedIndex == -1) return null;
        final completedSession = completed.removeAt(completedIndex).copyWith(
          stage: DoctorSessionStage.upcoming,
          ctaLabel: 'Waiting Session',
          time: 'Next follow-up - 5:00 pm',
        );
        completedSessions.value = completed;
        upcomingSessions.value = [completedSession, ...upcomingSessions.value];
        return completedSession;
      case DoctorSessionStage.canceled:
        final canceled = List<DoctorSessionEntry>.from(canceledSessions.value);
        final canceledIndex = canceled.indexWhere((item) => item.id == id);
        if (canceledIndex == -1) return null;
        final canceledSession = canceled.removeAt(canceledIndex).copyWith(
          stage: DoctorSessionStage.upcoming,
          ctaLabel: 'Upcoming',
          time: 'Rescheduled - 4:00 pm',
        );
        canceledSessions.value = canceled;
        upcomingSessions.value = [canceledSession, ...upcomingSessions.value];
        return canceledSession;
    }
  }

  static String addUpcomingLinkedBooking({
    required String patientName,
    required String condition,
    required String time,
    required String imagePath,
    required String threadId,
    required String notes,
  }) {
    ensureSeeded();
    final session = _entry(
      patientName: patientName,
      condition: condition,
      time: time,
      imagePath: imagePath,
      threadId: threadId,
      notes: notes,
      ctaLabel: 'Upcoming',
    );
    upcomingSessions.value = [session, ...upcomingSessions.value];
    return session.id;
  }

  static List<DoctorSessionEntry> _replace(
    List<DoctorSessionEntry> source,
    String id,
    DoctorSessionEntry Function(DoctorSessionEntry item) update,
  ) {
    return source
        .map((item) => item.id == id ? update(item) : item)
        .toList();
  }

  static DoctorSessionEntry _entry({
    required String patientName,
    required String condition,
    required String time,
    required String imagePath,
    required String threadId,
    required String notes,
    required String ctaLabel,
    DoctorSessionStage stage = DoctorSessionStage.upcoming,
  }) {
    return DoctorSessionEntry(
      id: _nextId(),
      patientName: patientName,
      condition: condition,
      time: time,
      imagePath: imagePath,
      threadId: threadId,
      notes: notes,
      stage: stage,
      ctaLabel: ctaLabel,
    );
  }

  static String _nextId() {
    _counter += 1;
    return 'doctor_session_$_counter';
  }
}

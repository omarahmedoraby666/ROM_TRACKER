import 'package:rom_tracker_app/core/constants/app_assets.dart';
import 'package:rom_tracker_app/features/chat/presentation/models/chat_store.dart';
import 'package:rom_tracker_app/features/doctors/presentation/models/doctor_catalog.dart';
import 'package:rom_tracker_app/features/sessions/presentation/models/doctor_session_entry.dart';
import 'package:rom_tracker_app/features/sessions/presentation/models/session_entry.dart';

class BackendSessionMapper {
  const BackendSessionMapper._();

  static SessionEntry toPatientSession(Map<String, dynamic> json) {
    return SessionEntry(
      id: (json['id'] ?? '').toString(),
      doctorId: (json['doctorId'] ?? '').toString(),
      doctorName: _ensureDoctorPrefix((json['doctorName'] ?? '').toString()),
      specialty: (json['specialty'] ?? '').toString(),
      time: (json['displayTime'] ?? '').toString(),
      imagePath: DoctorCatalog.imageForDoctorName(
        (json['doctorName'] ?? '').toString(),
      ),
      notes: (json['doctorNotes'] ?? '').toString(),
      review: _nullableText(json['review']),
    );
  }

  static DoctorSessionEntry toDoctorSession(Map<String, dynamic> json) {
    final status = (json['status'] ?? 'upcoming').toString();
    final stage = switch (status) {
      'completed' => DoctorSessionStage.completed,
      'canceled' => DoctorSessionStage.canceled,
      _ => DoctorSessionStage.upcoming,
    };

    return DoctorSessionEntry(
      id: (json['id'] ?? '').toString(),
      patientName: (json['patientName'] ?? '').toString(),
      condition: _nullableText(json['reason']) ?? 'Therapy session',
      time: (json['displayTime'] ?? '').toString(),
      imagePath: _patientAvatarForName((json['patientName'] ?? '').toString()),
      threadId: _threadIdForPatient((json['patientName'] ?? '').toString()),
      notes: (json['doctorNotes'] ?? '').toString(),
      stage: stage,
      ctaLabel: switch (stage) {
        DoctorSessionStage.upcoming => 'Go To Session',
        DoctorSessionStage.completed => 'View Details',
        DoctorSessionStage.canceled => 'Canceled',
      },
    );
  }

  static String _ensureDoctorPrefix(String name) {
    if (name.toLowerCase().startsWith('dr.')) return name;
    return 'Dr. $name';
  }

  static String _patientAvatarForName(String name) {
    final normalized = name.toLowerCase();
    if (normalized.contains('younes')) return AppAssets.phase2PatientYounes;
    if (normalized.contains('adham')) return AppAssets.phase2PatientAdham;
    if (normalized.contains('arwa')) return AppAssets.phase2PatientArwa;
    return AppAssets.phase2PatientAvatar;
  }

  static String _threadIdForPatient(String patientName) {
    final normalized = patientName.toLowerCase();
    if (normalized.contains('younes')) return 'd_younes';
    if (normalized.contains('adham')) return 'd_adham';
    if (normalized.contains('arwa')) return 'd_arwa';
    ChatStore.ensureSeeded();
    return ChatStore.linkedDoctorThreadId;
  }

  static String? _nullableText(dynamic value) {
    final text = (value ?? '').toString().trim();
    return text.isEmpty ? null : text;
  }
}

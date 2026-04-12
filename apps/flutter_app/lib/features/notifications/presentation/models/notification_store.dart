import 'package:flutter/foundation.dart';
import 'package:rom_tracker_app/features/chat/presentation/models/chat_store.dart';
import 'package:rom_tracker_app/features/notifications/presentation/models/app_notification.dart';
import 'package:rom_tracker_app/features/sessions/presentation/models/patient_booking.dart';

class NotificationStore {
  static final ValueNotifier<List<AppNotification>> patientNotifications =
      ValueNotifier<List<AppNotification>>([]);
  static final ValueNotifier<List<AppNotification>> doctorNotifications =
      ValueNotifier<List<AppNotification>>([]);

  static bool _seeded = false;
  static int _idCounter = 0;

  static void ensureSeeded() {
    if (_seeded) return;
    final now = DateTime.now();

    patientNotifications.value = [
      _item(
        title: 'Exercise reminder',
        body: 'Do not forget your stretching exercise at 2:00 PM.',
        createdAt: now.subtract(const Duration(hours: 2)),
        type: AppNotificationType.reminder,
        target: AppNotificationTarget.home,
        isRead: true,
      ),
      _item(
        title: 'New message from Dr. Sara Ali',
        body: 'Open chat to review the latest recovery instructions.',
        createdAt: now.subtract(const Duration(days: 1, hours: 3)),
        type: AppNotificationType.message,
        target: AppNotificationTarget.chat,
        threadId: 'p_dr_sara',
        isRead: true,
      ),
      _item(
        title: 'System update completed',
        body: 'The app has been updated with a smoother therapy flow.',
        createdAt: now.subtract(const Duration(days: 1, hours: 6)),
        type: AppNotificationType.system,
        target: AppNotificationTarget.system,
        isRead: true,
      ),
    ];

    doctorNotifications.value = [
      _item(
        title: 'Daily reminder',
        body: 'Review today\'s schedule and patient updates before sessions.',
        createdAt: now.subtract(const Duration(hours: 1)),
        type: AppNotificationType.reminder,
        target: AppNotificationTarget.home,
        isRead: true,
      ),
      _item(
        title: 'New message from Younes Ashraf',
        body: 'Open chat to review the patient\'s latest update.',
        createdAt: now.subtract(const Duration(days: 1, hours: 2)),
        type: AppNotificationType.message,
        target: AppNotificationTarget.chat,
        threadId: 'd_younes',
        isRead: true,
      ),
      _item(
        title: 'System update completed',
        body: 'The app has been updated with a smoother therapy flow.',
        createdAt: now.subtract(const Duration(days: 1, hours: 5)),
        type: AppNotificationType.system,
        target: AppNotificationTarget.system,
        isRead: true,
      ),
    ];

    _seeded = true;
  }

  static ValueNotifier<List<AppNotification>> notifierFor(String userType) {
    ensureSeeded();
    return userType == 'Doctor' ? doctorNotifications : patientNotifications;
  }

  static void markAllRead(String userType) {
    final notifier = notifierFor(userType);
    notifier.value = notifier.value
        .map((notification) => notification.copyWith(isRead: true))
        .toList();
  }

  static void markRead(String userType, String id) {
    final notifier = notifierFor(userType);
    notifier.value = notifier.value
        .map(
          (notification) => notification.id == id
              ? notification.copyWith(isRead: true)
              : notification,
        )
        .toList();
  }

  static void addPatientBookingFlow(PatientBooking booking) {
    ensureSeeded();
    final isRebook = booking.reason.toLowerCase().contains('re-book');
    final schedule =
        '${booking.dayLabel} ${booking.dayNumber} at ${booking.timeLabel}';

    _insert(
      userType: 'Patient',
      notification: _item(
        title: isRebook ? 'Session re-booked' : 'Session confirmed',
        body:
            '${booking.doctorName} confirmed your session for $schedule. Tap to review your upcoming session.',
        createdAt: DateTime.now(),
        type: AppNotificationType.session,
        target: AppNotificationTarget.sessions,
      ),
    );

    final threadId = ChatStore.patientThreadIdForDoctor(booking.doctorName);
    if (threadId == null) return;

    ChatStore.receiveText(
      userType: 'Patient',
      threadId: threadId,
      text:
          'Hello, your session is confirmed for $schedule. Please be ready 10 minutes early and keep your exercise notes with you.',
    );
  }

  static void addDoctorBookingNotification({
    required String patientName,
    required String schedule,
  }) {
    ensureSeeded();
    _insert(
      userType: 'Doctor',
      notification: _item(
        title: 'New booking from $patientName',
        body:
            'Payment was confirmed and a new session was booked for $schedule. Tap to review upcoming sessions.',
        createdAt: DateTime.now(),
        type: AppNotificationType.session,
        target: AppNotificationTarget.sessions,
      ),
    );
  }

  static void addPatientSessionUpdate({
    required String title,
    required String body,
  }) {
    ensureSeeded();
    _insert(
      userType: 'Patient',
      notification: _item(
        title: title,
        body: body,
        createdAt: DateTime.now(),
        type: AppNotificationType.session,
        target: AppNotificationTarget.sessions,
      ),
    );
  }

  static void addDoctorSessionUpdate({
    required String title,
    required String body,
  }) {
    ensureSeeded();
    _insert(
      userType: 'Doctor',
      notification: _item(
        title: title,
        body: body,
        createdAt: DateTime.now(),
        type: AppNotificationType.session,
        target: AppNotificationTarget.sessions,
      ),
    );
  }

  static void _insert({
    required String userType,
    required AppNotification notification,
  }) {
    final notifier = notifierFor(userType);
    notifier.value = [notification, ...notifier.value];
  }

  static AppNotification _item({
    required String title,
    required String body,
    required DateTime createdAt,
    required AppNotificationType type,
    required AppNotificationTarget target,
    String? threadId,
    bool isRead = false,
  }) {
    _idCounter += 1;
    return AppNotification(
      id: 'notification_$_idCounter',
      title: title,
      body: body,
      createdAt: createdAt,
      type: type,
      target: target,
      threadId: threadId,
      isRead: isRead,
    );
  }
}

import 'package:flutter/foundation.dart';
import 'package:rom_tracker_app/core/constants/app_assets.dart';
import 'package:rom_tracker_app/features/chat/presentation/models/chat_thread.dart';
import 'package:rom_tracker_app/features/user_profile/presentation/models/user_profile_store.dart';

class ChatStore {
  static const linkedPatientThreadId = 'p_dr_mohamed';
  static const linkedDoctorThreadId = 'd_patient_app';

  static final ValueNotifier<List<ChatThread>> patientThreads =
      ValueNotifier<List<ChatThread>>([]);
  static final ValueNotifier<List<ChatThread>> doctorThreads =
      ValueNotifier<List<ChatThread>>([]);

  static final Map<String, ValueNotifier<List<ChatMessage>>> _messages = {};
  static bool _seeded = false;
  static int _messageCounter = 0;

  static void ensureSeeded() {
    if (_seeded) return;

    patientThreads.value = const [
      ChatThread(
        id: 'p_dr_mohamed',
        name: 'Dr. Mohamed Alaa',
        subtitle: 'Physical Therapist',
        avatarPath: AppAssets.phase2DoctorMohamed,
        lastMessage: 'Drink water and continue your stretching plan.',
        lastTime: '10:30 AM',
        unreadCount: 2,
        isOnline: true,
        isRead: false,
      ),
      ChatThread(
        id: 'p_dr_sara',
        name: 'Dr. Sara Ali',
        subtitle: 'Rehabilitation Expert',
        avatarPath: AppAssets.phase2DoctorSara,
        lastMessage: 'Nice one. Keep doing it tomorrow.',
        lastTime: '10:30 AM',
        unreadCount: 0,
        isOnline: false,
        isRead: true,
      ),
      ChatThread(
        id: 'p_dr_lina',
        name: 'Dr. Lina Mostafa',
        subtitle: 'Senior Physical Therapy',
        avatarPath: AppAssets.phase2DoctorLina,
        lastMessage: 'Hi, are you available for tomorrow?',
        lastTime: 'Yesterday',
        unreadCount: 1,
        isOnline: true,
        isRead: false,
      ),
      ChatThread(
        id: 'p_dr_ahmed',
        name: 'Dr. Ahmed Hassan',
        subtitle: 'Rehabilitation Specialist',
        avatarPath: AppAssets.phase2DoctorAhmed,
        lastMessage: 'How is the pain level today?',
        lastTime: '2 days ago',
        unreadCount: 0,
        isOnline: false,
        isRead: true,
      ),
    ];

    doctorThreads.value = const [
      ChatThread(
        id: 'd_younes',
        name: 'Younes Ashraf',
        subtitle: 'Carpal tunnel syndrome',
        avatarPath: AppAssets.phase2PatientYounes,
        lastMessage: 'Doctor, the exercise is helping me a lot.',
        lastTime: '10:30 AM',
        unreadCount: 2,
        isOnline: true,
        isRead: false,
      ),
      ChatThread(
        id: 'd_adham',
        name: 'Adham Yasser',
        subtitle: 'Carpal tunnel syndrome',
        avatarPath: AppAssets.phase2PatientAdham,
        lastMessage: 'I will upload the movement video tomorrow.',
        lastTime: 'Yesterday',
        unreadCount: 0,
        isOnline: false,
        isRead: true,
      ),
      ChatThread(
        id: 'd_arwa',
        name: 'Arwa Ahmed',
        subtitle: 'Muscle recovery plan',
        avatarPath: AppAssets.phase2PatientArwa,
        lastMessage: 'Can we move the session to evening?',
        lastTime: '1 week ago',
        unreadCount: 1,
        isOnline: true,
        isRead: false,
      ),
    ];

    _messages['p_dr_mohamed'] = ValueNotifier<List<ChatMessage>>([
      _msg('You sit too long. Try drinking lots of water', false, '08:01 AM'),
      _msg('Oh like that.', true, '08:50 AM'),
      _msg('ok doc. i will drink lots of water and exercise.', true, '08:50 AM'),
      _msg('Thanks a lot doc 😍', true, '08:50 AM'),
      _msg('Don\'t mention it baby 👍', false, '08:01 AM'),
    ]);
    _messages['p_dr_sara'] = ValueNotifier<List<ChatMessage>>([
      _msg('Today\'s session was great.', false, '09:30 AM'),
      _msg('Thank you doctor.', true, '09:32 AM'),
    ]);
    _messages['p_dr_lina'] = ValueNotifier<List<ChatMessage>>([
      _msg('Please do your balance drill twice today.', false, 'Yesterday'),
    ]);
    _messages['p_dr_ahmed'] = ValueNotifier<List<ChatMessage>>([
      _msg('How is the pain level today?', false, '2 days ago'),
    ]);

    _messages['d_younes'] = ValueNotifier<List<ChatMessage>>([
      _msg('Doctor, the exercise is helping me a lot.', false, '10:10 AM'),
      _msg('Great, keep going.', true, '10:12 AM'),
    ]);
    _messages['d_adham'] = ValueNotifier<List<ChatMessage>>([
      _msg('I will upload the movement video tomorrow.', false, 'Yesterday'),
    ]);
    _messages['d_arwa'] = ValueNotifier<List<ChatMessage>>([
      _msg('Can we move the session to evening?', false, '1 week ago'),
    ]);

    _ensureLinkedThreads();
    _seeded = true;
  }

  static ValueNotifier<List<ChatThread>> threadsFor(String userType) {
    ensureSeeded();
    _ensureLinkedThreads();
    return userType == 'Doctor' ? doctorThreads : patientThreads;
  }

  static ValueNotifier<List<ChatMessage>> messagesFor(String threadId) {
    ensureSeeded();
    _ensureLinkedThreads();
    return _messages.putIfAbsent(
      threadId,
      () => ValueNotifier<List<ChatMessage>>([]),
    );
  }

  static ChatThread? threadById(String userType, String threadId) {
    final threads = threadsFor(userType).value;
    for (final thread in threads) {
      if (thread.id == threadId) return thread;
    }
    return null;
  }

  static void markRead(String userType, String threadId) {
    _updateThread(
      userType,
      threadId,
      (thread) => thread.copyWith(
        unreadCount: 0,
        isRead: true,
      ),
    );
  }

  static void sendText({
    required String userType,
    required String threadId,
    required String text,
  }) {
    if (text.trim().isEmpty) return;
    _ensureLinkedThreads();
    final notifier = messagesFor(threadId);
    final items = List<ChatMessage>.from(notifier.value)
      ..add(_msg(text.trim(), true, 'Now'));
    notifier.value = items;

    _updateThread(
      userType,
      threadId,
      (thread) => thread.copyWith(
        lastMessage: text.trim(),
        lastTime: 'Now',
        unreadCount: 0,
        isRead: true,
      ),
    );

    final mirroredThreadId = _linkedCounterpartThreadId(userType, threadId);
    if (mirroredThreadId == null) return;
    final mirroredUserType = userType == 'Doctor' ? 'Patient' : 'Doctor';
    final mirroredMessages = messagesFor(mirroredThreadId);
    mirroredMessages.value = List<ChatMessage>.from(mirroredMessages.value)
      ..add(_msg(text.trim(), false, 'Now'));
    _updateThread(
      mirroredUserType,
      mirroredThreadId,
      (thread) => thread.copyWith(
        lastMessage: text.trim(),
        lastTime: 'Now',
        unreadCount: thread.unreadCount + 1,
        isRead: false,
      ),
    );
  }

  static void receiveText({
    required String userType,
    required String threadId,
    required String text,
  }) {
    if (text.trim().isEmpty) return;
    _ensureLinkedThreads();
    final notifier = messagesFor(threadId);
    final items = List<ChatMessage>.from(notifier.value)
      ..add(_msg(text.trim(), false, 'Now'));
    notifier.value = items;

    _updateThread(
      userType,
      threadId,
      (thread) => thread.copyWith(
        lastMessage: text.trim(),
        lastTime: 'Now',
        unreadCount: thread.unreadCount + 1,
        isRead: false,
      ),
    );

    final mirroredThreadId = _linkedCounterpartThreadId(userType, threadId);
    if (mirroredThreadId == null) return;
    final mirroredUserType = userType == 'Doctor' ? 'Patient' : 'Doctor';
    final mirroredMessages = messagesFor(mirroredThreadId);
    mirroredMessages.value = List<ChatMessage>.from(mirroredMessages.value)
      ..add(_msg(text.trim(), true, 'Now'));
    _updateThread(
      mirroredUserType,
      mirroredThreadId,
      (thread) => thread.copyWith(
        lastMessage: text.trim(),
        lastTime: 'Now',
        unreadCount: 0,
        isRead: true,
      ),
    );
  }

  static void sendAttachment({
    required String userType,
    required String threadId,
    required String label,
  }) {
    final text = 'Sent $label';
    sendText(
      userType: userType,
      threadId: threadId,
      text: text,
    );
  }

  static void _updateThread(
    String userType,
    String threadId,
    ChatThread Function(ChatThread thread) update,
  ) {
    final notifier = threadsFor(userType);
    final items = notifier.value
        .map((thread) => thread.id == threadId ? update(thread) : thread)
        .toList();
    notifier.value = items;
  }

  static ChatMessage _msg(String text, bool isMe, String time) {
    _messageCounter += 1;
    return ChatMessage(
      id: 'msg_$_messageCounter',
      text: text,
      time: time,
      isMe: isMe,
    );
  }

  static String? patientThreadIdForDoctor(String doctorName) {
    final normalized = doctorName.toLowerCase();
    if (normalized.contains('mohamed')) return 'p_dr_mohamed';
    if (normalized.contains('sara')) return 'p_dr_sara';
    if (normalized.contains('lina')) return 'p_dr_lina';
    if (normalized.contains('ahmed')) return 'p_dr_ahmed';
    return null;
  }

  static String ensureLinkedDoctorThread() {
    ensureSeeded();
    _ensureLinkedThreads();
    return linkedDoctorThreadId;
  }

  static String? _linkedCounterpartThreadId(String userType, String threadId) {
    if (userType == 'Patient' && threadId == linkedPatientThreadId) {
      return linkedDoctorThreadId;
    }
    if (userType == 'Doctor' && threadId == linkedDoctorThreadId) {
      return linkedPatientThreadId;
    }
    return null;
  }

  static void _ensureLinkedThreads() {
    final patientProfile = UserProfileStore.patientProfile.value;
    final doctorProfile = UserProfileStore.doctorProfile.value;
    final doctorDisplayName = 'Dr. ${doctorProfile.fullName}';
    final linkedPatientPreview = patientThreads.value.firstWhere(
      (thread) => thread.id == linkedPatientThreadId,
      orElse: () => const ChatThread(
        id: linkedPatientThreadId,
        name: 'Dr. Mohamed Alaa',
        subtitle: 'Physical Therapist',
        avatarPath: AppAssets.phase2DoctorMohamed,
        lastMessage: 'The linked conversation is ready.',
        lastTime: 'Now',
        unreadCount: 0,
        isOnline: true,
        isRead: true,
      ),
    );

    final updatedPatientThreads = [
      for (final thread in patientThreads.value)
        thread.id == linkedPatientThreadId
            ? thread.copyWith(
                name: doctorDisplayName,
                subtitle: doctorProfile.specialization ?? 'Physical Therapist',
                avatarPath: doctorProfile.avatarPath,
              )
            : thread,
    ];
    if (!_sameThreads(patientThreads.value, updatedPatientThreads)) {
      patientThreads.value = updatedPatientThreads;
    }

    final linkedDoctorThread = ChatThread(
      id: linkedDoctorThreadId,
      name: patientProfile.fullName,
      subtitle: 'Connected patient account',
      avatarPath: patientProfile.avatarPath,
      lastMessage: linkedPatientPreview.lastMessage,
      lastTime: linkedPatientPreview.lastTime,
      unreadCount: 0,
      isOnline: true,
      isRead: true,
    );

    final hasDoctorLinkedThread = doctorThreads.value.any(
      (thread) => thread.id == linkedDoctorThreadId,
    );
    final updatedDoctorThreads = !hasDoctorLinkedThread
        ? [linkedDoctorThread, ...doctorThreads.value]
        : [
            for (final thread in doctorThreads.value)
              thread.id == linkedDoctorThreadId
                  ? linkedDoctorThread.copyWith(
                      lastMessage: thread.lastMessage,
                      lastTime: thread.lastTime,
                      unreadCount: thread.unreadCount,
                      isRead: thread.isRead,
                    )
                  : thread,
          ];
    if (!_sameThreads(doctorThreads.value, updatedDoctorThreads)) {
      doctorThreads.value = updatedDoctorThreads;
    }

    _messages.putIfAbsent(
      linkedDoctorThreadId,
      () {
        final source =
            _messages[linkedPatientThreadId]?.value ?? const <ChatMessage>[];
        final mirrored = source
            .map(
              (message) => ChatMessage(
                id: '${message.id}_mirror',
                text: message.text,
                time: message.time,
                isMe: !message.isMe,
              ),
            )
            .toList();
        return ValueNotifier<List<ChatMessage>>(mirrored);
      },
    );
  }

  static bool _sameThreads(List<ChatThread> a, List<ChatThread> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i].id != b[i].id ||
          a[i].name != b[i].name ||
          a[i].subtitle != b[i].subtitle ||
          a[i].avatarPath != b[i].avatarPath ||
          a[i].lastMessage != b[i].lastMessage ||
          a[i].lastTime != b[i].lastTime ||
          a[i].unreadCount != b[i].unreadCount ||
          a[i].isOnline != b[i].isOnline ||
          a[i].isRead != b[i].isRead) {
        return false;
      }
    }
    return true;
  }
}

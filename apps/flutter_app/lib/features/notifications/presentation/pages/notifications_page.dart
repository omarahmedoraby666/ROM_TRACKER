import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rom_tracker_app/core/constants/app_colors.dart';
import 'package:rom_tracker_app/core/widgets/app_page_shell.dart';
import 'package:rom_tracker_app/features/chat/presentation/models/chat_store.dart';
import 'package:rom_tracker_app/features/chat/presentation/pages/chat_detail_page.dart';
import 'package:rom_tracker_app/features/chat/presentation/pages/chat_list_page.dart';
import 'package:rom_tracker_app/features/home/presentation/pages/main_layout.dart';
import 'package:rom_tracker_app/features/notifications/presentation/models/app_notification.dart';
import 'package:rom_tracker_app/features/notifications/presentation/models/notification_store.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({
    super.key,
    required this.userType,
  });

  final String userType;

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  void initState() {
    super.initState();
    NotificationStore.ensureSeeded();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      NotificationStore.markAllRead(widget.userType);
    });
  }

  @override
  Widget build(BuildContext context) {
    ChatStore.ensureSeeded();
    return AppPageShell(
      title: 'Notifications',
      subtitle:
          'Updates about bookings, reminders, chat activity, and system events appear here.',
      onBack: () => Navigator.pop(context),
      child: ValueListenableBuilder<List<AppNotification>>(
        valueListenable: NotificationStore.notifierFor(widget.userType),
        builder: (context, notifications, _) {
          final sections = _groupNotifications(notifications);
          if (sections.isEmpty) {
            return Center(
              child: Text(
                'No notifications yet.',
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  color: AppColors.textSecondary,
                ),
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: sections.entries
                .expand(
                  (entry) => [
                    _buildSectionHeader(entry.key),
                    ...entry.value.map(
                      (notification) => _buildNotificationItem(
                        context: context,
                        notification: notification,
                      ),
                    ),
                    SizedBox(height: 8.h),
                  ],
                )
                .toList(),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
          color: Colors.black54,
        ),
      ),
    );
  }

  Widget _buildNotificationItem({
    required BuildContext context,
    required AppNotification notification,
  }) {
    final meta = _metaFor(notification.type);
    return InkWell(
      onTap: () => _handleNotificationTap(context, notification),
      borderRadius: BorderRadius.circular(16.r),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      overlayColor: const MaterialStatePropertyAll(Colors.transparent),
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: meta.color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(meta.icon, color: meta.color, size: 24.sp),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    notification.body,
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    _formatTime(notification.createdAt),
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, List<AppNotification>> _groupNotifications(
    List<AppNotification> notifications,
  ) {
    final sorted = [...notifications]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final sections = <String, List<AppNotification>>{};
    for (final notification in sorted) {
      final label = _sectionLabel(notification.createdAt);
      sections.putIfAbsent(label, () => []).add(notification);
    }
    return sections;
  }

  String _sectionLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final difference = today.difference(target).inDays;
    if (difference <= 0) return 'Today';
    if (difference == 1) return 'Yesterday';
    return 'Earlier';
  }

  String _formatTime(DateTime date) {
    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    final suffix = date.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $suffix';
  }

  _NotificationMeta _metaFor(AppNotificationType type) {
    switch (type) {
      case AppNotificationType.session:
        return const _NotificationMeta(
          icon: Icons.calendar_month_rounded,
          color: AppColors.primary,
        );
      case AppNotificationType.message:
        return const _NotificationMeta(
          icon: Icons.chat_bubble_outline_rounded,
          color: Colors.orange,
        );
      case AppNotificationType.reminder:
        return const _NotificationMeta(
          icon: Icons.timer_outlined,
          color: AppColors.primary,
        );
      case AppNotificationType.system:
        return const _NotificationMeta(
          icon: Icons.system_update_alt_rounded,
          color: Colors.grey,
        );
    }
  }

  void _handleNotificationTap(
    BuildContext context,
    AppNotification notification,
  ) {
    NotificationStore.markRead(widget.userType, notification.id);
    switch (notification.target) {
      case AppNotificationTarget.home:
        _openHome(context);
        return;
      case AppNotificationTarget.sessions:
        _openSessions(context);
        return;
      case AppNotificationTarget.chat:
        _openChat(context, threadId: notification.threadId);
        return;
      case AppNotificationTarget.system:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Your app is already up to date'),
          ),
        );
        return;
    }
  }

  void _openHome(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => MainLayout(
          userType: widget.userType,
          initialIndex: 0,
        ),
      ),
    );
  }

  void _openSessions(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => MainLayout(
          userType: widget.userType,
          initialIndex: 1,
        ),
      ),
    );
  }

  void _openChat(BuildContext context, {String? threadId}) {
    final targetThreadId =
        threadId ?? (widget.userType == 'Doctor' ? 'd_younes' : 'p_dr_sara');
    final thread = ChatStore.threadById(widget.userType, targetThreadId);
    if (thread == null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatListPage(userType: widget.userType),
        ),
      );
      return;
    }
    ChatStore.markRead(widget.userType, targetThreadId);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatDetailPage(
          userType: widget.userType,
          threadId: targetThreadId,
        ),
      ),
    );
  }
}

class _NotificationMeta {
  const _NotificationMeta({
    required this.icon,
    required this.color,
  });

  final IconData icon;
  final Color color;
}

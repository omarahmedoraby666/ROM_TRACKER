import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rom_tracker_app/features/notifications/presentation/models/app_notification.dart';
import 'package:rom_tracker_app/features/notifications/presentation/models/notification_store.dart';

class AppUserHeader extends StatelessWidget {
  const AppUserHeader({
    super.key,
    required this.avatarPath,
    required this.title,
    this.subtitle,
    this.showNotifications = true,
    this.onProfileTap,
    this.onNotificationTap,
    this.notificationUserType,
  });

  final String avatarPath;
  final String title;
  final String? subtitle;
  final bool showNotifications;
  final VoidCallback? onProfileTap;
  final VoidCallback? onNotificationTap;
  final String? notificationUserType;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        InkWell(
          onTap: onProfileTap,
          borderRadius: BorderRadius.circular(999.r),
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          overlayColor: const MaterialStatePropertyAll(Colors.transparent),
          child: ClipOval(
            child: Image.asset(
              avatarPath,
              width: 42.w,
              height: 42.w,
              fit: BoxFit.cover,
            ),
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 19.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (subtitle != null)
                Text(
                  subtitle!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    color: const Color(0xFF64748B),
                  ),
                ),
            ],
          ),
        ),
        if (showNotifications)
          if (notificationUserType == null)
            _NotificationBell(
              hasUnread: false,
              onTap: onNotificationTap,
            )
          else
            ValueListenableBuilder<List<AppNotification>>(
              valueListenable: NotificationStore.notifierFor(
                notificationUserType!,
              ),
              builder: (context, notifications, _) {
                final hasUnread =
                    notifications.any((notification) => !notification.isRead);
                return _NotificationBell(
                  hasUnread: hasUnread,
                  onTap: onNotificationTap,
                );
              },
            ),
      ],
    );
  }
}

class _NotificationBell extends StatelessWidget {
  const _NotificationBell({
    required this.hasUnread,
    this.onTap,
  });

  final bool hasUnread;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20.r),
      onTap: onTap,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      overlayColor: const MaterialStatePropertyAll(Colors.transparent),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.notifications_none_rounded),
          ),
          if (hasUnread)
            Positioned(
              right: 3.w,
              top: 3.h,
              child: Container(
                width: 9.w,
                height: 9.w,
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 1.4,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

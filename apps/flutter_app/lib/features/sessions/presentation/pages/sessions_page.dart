import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rom_tracker_app/core/constants/app_colors.dart';
import 'package:rom_tracker_app/core/widgets/app_search_bar.dart';
import 'package:rom_tracker_app/core/widgets/app_user_header.dart';
import 'package:rom_tracker_app/core/widgets/user_avatar.dart';
import 'package:rom_tracker_app/features/home/presentation/pages/main_layout.dart';
import 'package:rom_tracker_app/features/notifications/presentation/pages/notifications_page.dart';
import 'package:rom_tracker_app/features/payment_wallet/presentation/pages/payment_methods_page.dart';
import 'package:rom_tracker_app/features/sessions/presentation/models/booking_store.dart';
import 'package:rom_tracker_app/features/sessions/presentation/models/local_demo_sync_store.dart';
import 'package:rom_tracker_app/features/sessions/presentation/models/patient_booking.dart';
import 'package:rom_tracker_app/features/sessions/presentation/models/session_entry.dart';
import 'package:rom_tracker_app/features/user_profile/presentation/models/user_profile_data.dart';
import 'package:rom_tracker_app/features/user_profile/presentation/models/user_profile_store.dart';

class SessionsPage extends StatefulWidget {
  const SessionsPage({
    super.key,
    required this.userType,
  });

  final String userType;

  @override
  State<SessionsPage> createState() => _SessionsPageState();
}

class _SessionsPageState extends State<SessionsPage> {
  int selectedTabIndex = 0;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (widget.userType != 'Doctor') {
      BookingStore.ensureSeeded();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ValueListenableBuilder<UserProfileData>(
          valueListenable: UserProfileStore.notifierFor(widget.userType),
          builder: (context, profile, _) => SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 12.h),
                AppUserHeader(
                  avatarPath: profile.avatarPath,
                  title: 'Sessions',
                  notificationUserType: widget.userType,
                  onProfileTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MainLayout(
                          userType: widget.userType,
                          initialIndex: 3,
                        ),
                      ),
                    );
                  },
                  onNotificationTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => NotificationsPage(
                          userType: widget.userType,
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(height: 18.h),
                AppSearchBar(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                ),
                SizedBox(height: 18.h),
                _buildTabs(),
                SizedBox(height: 18.h),
                ..._currentCards(),
                SizedBox(height: 18.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabs() {
    const tabs = ['Upcoming', 'Completed', 'Canceled'];
    return Container(
      height: 48.h,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Row(
        children: List.generate(
          tabs.length,
          (index) {
            final selected = selectedTabIndex == index;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => selectedTabIndex = index),
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: selected ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(20.r),
                    border: selected
                        ? Border.all(color: AppColors.primary)
                        : null,
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      tabs[index],
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        color: selected
                            ? AppColors.primary
                            : const Color(0xFF475569),
                        fontWeight:
                            selected ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  List<Widget> _currentCards() {
    if (widget.userType == 'Doctor') {
      return _doctorCards();
    }

    switch (selectedTabIndex) {
      case 0:
        return [
          ValueListenableBuilder<List<SessionEntry>>(
            valueListenable: BookingStore.upcomingSessions,
            builder: (context, sessions, _) {
              final filtered = _filterSessions(sessions);
              if (filtered.isEmpty) {
                return _emptyState('No upcoming sessions yet.');
              }
              return Column(
                children: filtered
                    .map(
                      (session) => _PatientUpcomingCard(
                        session: session,
                        onCancel: () =>
                            LocalDemoSyncStore.patientCancelUpcoming(
                          session.id,
                        ),
                        onComplete: () =>
                            LocalDemoSyncStore.patientCompleteUpcoming(
                          session.id,
                        ),
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ];
      case 1:
        return [
          ValueListenableBuilder<List<SessionEntry>>(
            valueListenable: BookingStore.completedSessions,
            builder: (context, sessions, _) {
              final filtered = _filterSessions(sessions);
              if (filtered.isEmpty) {
                return _emptyState('No completed sessions yet.');
              }
              return Column(
                children: filtered
                    .map(
                      (session) => _CompletedCard(
                        session: session,
                        onRebook: () => _startRebook(session),
                        onReview: () => _showReviewDialog(
                          session: session,
                          stage: SessionStage.completed,
                        ),
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ];
      default:
        return [
          ValueListenableBuilder<List<SessionEntry>>(
            valueListenable: BookingStore.canceledSessions,
            builder: (context, sessions, _) {
              final filtered = _filterSessions(sessions);
              if (filtered.isEmpty) {
                return _emptyState('No canceled sessions.');
              }
              return Column(
                children: filtered
                    .map(
                      (session) => _CanceledCard(
                        session: session,
                        onReview: () => _showReviewDialog(
                          session: session,
                          stage: SessionStage.canceled,
                        ),
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ];
    }
  }

  Future<void> _startRebook(SessionEntry session) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentMethodsPage(
          booking: PatientBooking(
            doctorName: session.doctorName,
            specialty: session.specialty,
            imagePath: session.imagePath,
            dayLabel: 'Next',
            dayNumber: 'available',
            timeLabel: '5:00 pm',
            reason: 'Re-booked session',
          ),
        ),
      ),
    );
  }

  Future<void> _showReviewDialog({
    required SessionEntry session,
    required SessionStage stage,
  }) async {
    final controller = TextEditingController(text: session.review ?? '');

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Write Review',
            style: GoogleFonts.inter(fontWeight: FontWeight.w700),
          ),
          content: TextField(
            controller: controller,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'Share your feedback about the doctor',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final review = controller.text.trim();
                if (review.isEmpty) return;
                BookingStore.saveReview(
                  stage: stage,
                  id: session.id,
                  review: review,
                );
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Widget _emptyState(String text) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18.r),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: GoogleFonts.inter(
          fontSize: 14.sp,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  List<Widget> _doctorCards() {
    if (selectedTabIndex == 0) {
      return const [
        _DoctorSimpleCard(
          name: 'Younes Ashraf',
          subtitle: 'Carpal tunnel syndrome',
          time: '10:30 am - 12:30 pm',
        ),
        _DoctorSimpleCard(
          name: 'Ana Williams',
          subtitle: 'Parkinson',
          time: '11:30 am - 1:30 pm',
        ),
      ];
    }

    if (selectedTabIndex == 1) {
      return const [
        _DoctorSimpleCard(
          name: 'Osama Elsayed',
          subtitle: 'Lymphedema',
          time: '12 March - 6:00 pm',
        ),
        _DoctorSimpleCard(
          name: 'Yousef Idreis',
          subtitle: 'Cerebral palsy',
          time: '15 March - 9:00 pm',
        ),
      ];
    }

    return const [
      _DoctorSimpleCard(
        name: 'Yousra Zain',
        subtitle: 'Muscular dystrophies',
        time: '18 March - 2:00 pm',
      ),
    ];
  }

  List<SessionEntry> _filterSessions(List<SessionEntry> sessions) {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return sessions;
    return sessions.where((session) {
      return session.doctorName.toLowerCase().contains(query) ||
          session.specialty.toLowerCase().contains(query) ||
          session.time.toLowerCase().contains(query);
    }).toList();
  }
}

class _PatientUpcomingCard extends StatelessWidget {
  const _PatientUpcomingCard({
    required this.session,
    required this.onCancel,
    required this.onComplete,
  });

  final SessionEntry session;
  final VoidCallback onCancel;
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 14.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18.r),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14.r),
                child: Image.asset(
                  session.imagePath,
                  width: 72.w,
                  height: 72.h,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session.doctorName,
                      style: GoogleFonts.inter(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF2A5DC8),
                      ),
                    ),
                    Text(
                      session.specialty,
                      style: GoogleFonts.inter(
                        fontSize: 13.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Row(
                      children: [
                        const Icon(Icons.access_time,
                            size: 16, color: Color(0xFF64748B)),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: Text(
                            session.time,
                            style: GoogleFonts.inter(fontSize: 12.sp),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                width: 38.w,
                height: 38.w,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child:
                    const Icon(Icons.videocam_outlined, color: AppColors.primary),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onCancel,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFFF6B6B)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                  ),
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.inter(
                      color: const Color(0xFFFF6B6B),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: onComplete,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                  ),
                  child: Text(
                    'Complete',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CompletedCard extends StatelessWidget {
  const _CompletedCard({
    required this.session,
    required this.onRebook,
    required this.onReview,
  });

  final SessionEntry session;
  final VoidCallback onRebook;
  final VoidCallback onReview;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 14.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18.r),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14.r),
                child: Image.asset(
                  session.imagePath,
                  width: 96.w,
                  height: 98.h,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session.doctorName,
                      style: GoogleFonts.inter(
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF2A5DC8),
                      ),
                    ),
                    Text(
                      session.specialty,
                      style: GoogleFonts.inter(
                        fontSize: 13.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Row(
                      children: [
                        const Icon(Icons.access_time,
                            size: 16, color: Color(0xFF64748B)),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: Text(
                            session.time,
                            style: GoogleFonts.inter(fontSize: 12.sp),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Doctor\'s Notes',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w700,
                        fontSize: 13.sp,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      session.notes,
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        color: AppColors.textSecondary,
                        height: 1.35,
                      ),
                    ),
                    if (session.review != null) ...[
                      SizedBox(height: 8.h),
                      Text(
                        'Your Review',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                          fontSize: 13.sp,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        session.review!,
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          color: AppColors.textSecondary,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onRebook,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                  ),
                  child: Text(
                    'Re-Book',
                    style: GoogleFonts.inter(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: onReview,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                  ),
                  child: Text(
                    session.review == null ? 'Add Review' : 'Edit Review',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CanceledCard extends StatelessWidget {
  const _CanceledCard({
    required this.session,
    required this.onReview,
  });

  final SessionEntry session;
  final VoidCallback onReview;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 14.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18.r),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14.r),
                child: Image.asset(
                  session.imagePath,
                  width: 96.w,
                  height: 98.h,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session.doctorName,
                      style: GoogleFonts.inter(
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF2A5DC8),
                      ),
                    ),
                    Text(
                      session.specialty,
                      style: GoogleFonts.inter(
                        fontSize: 13.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Row(
                      children: [
                        const Icon(Icons.access_time,
                            size: 16, color: Color(0xFF64748B)),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: Text(
                            session.time,
                            style: GoogleFonts.inter(fontSize: 12.sp),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Session Status',
                      style: GoogleFonts.inter(fontSize: 12.sp),
                    ),
                    Text(
                      'Canceled',
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        color: const Color(0xFFFF6B6B),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (session.review != null) ...[
                      SizedBox(height: 8.h),
                      Text(
                        'Your Review',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                          fontSize: 13.sp,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        session.review!,
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          color: AppColors.textSecondary,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onReview,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
              ),
              child: Text(
                session.review == null ? 'Add Review' : 'Edit Review',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DoctorSimpleCard extends StatelessWidget {
  const _DoctorSimpleCard({
    required this.name,
    required this.subtitle,
    required this.time,
  });

  final String name;
  final String subtitle;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 14.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18.r),
      ),
      child: Row(
        children: [
          UserAvatar(name: name, radius: 22),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2A5DC8),
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 13.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  time,
                  style: GoogleFonts.inter(fontSize: 12.sp),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

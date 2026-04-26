import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rom_tracker_app/core/constants/app_colors.dart';
import 'package:rom_tracker_app/core/widgets/app_search_bar.dart';
import 'package:rom_tracker_app/core/widgets/app_user_header.dart';
import 'package:rom_tracker_app/features/chat/presentation/pages/chat_detail_page.dart';
import 'package:rom_tracker_app/features/doctors/presentation/pages/doctor_patient_details_page.dart';
import 'package:rom_tracker_app/features/home/presentation/pages/main_layout.dart';
import 'package:rom_tracker_app/features/notifications/presentation/pages/notifications_page.dart';
import 'package:rom_tracker_app/features/sessions/presentation/models/doctor_session_entry.dart';
import 'package:rom_tracker_app/features/sessions/presentation/models/doctor_session_store.dart';
import 'package:rom_tracker_app/features/sessions/presentation/models/local_demo_sync_store.dart';
import 'package:rom_tracker_app/features/user_profile/presentation/models/user_profile_data.dart';
import 'package:rom_tracker_app/features/user_profile/presentation/models/user_profile_store.dart';

class DoctorSessionsPage extends StatefulWidget {
  const DoctorSessionsPage({super.key});

  @override
  State<DoctorSessionsPage> createState() => _DoctorSessionsPageState();
}

class _DoctorSessionsPageState extends State<DoctorSessionsPage> {
  int selectedTabIndex = 0;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    DoctorSessionStore.ensureSeeded();
    DoctorSessionStore.refreshFromBackend();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ValueListenableBuilder<UserProfileData>(
          valueListenable: UserProfileStore.doctorProfile,
          builder: (context, profile, _) => SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 12.h),
                AppUserHeader(
                  avatarPath: profile.avatarPath,
                  title: 'Sessions',
                  notificationUserType: 'Doctor',
                  onProfileTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const MainLayout(
                          userType: 'Doctor',
                          initialIndex: 3,
                        ),
                      ),
                    );
                  },
                  onNotificationTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const NotificationsPage(
                          userType: 'Doctor',
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(height: 18.h),
                AppSearchBar(
                  controller: _searchController,
                  hintText: 'Search patients or sessions',
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
                    border:
                        selected ? Border.all(color: AppColors.primary) : null,
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
    switch (selectedTabIndex) {
      case 0:
        return [
          ValueListenableBuilder<List<DoctorSessionEntry>>(
            valueListenable: DoctorSessionStore.upcomingSessions,
            builder: (context, sessions, _) {
              final filtered = _filterSessions(sessions);
              if (filtered.isEmpty) {
                return _emptyState('No upcoming doctor sessions yet.');
              }
              return Column(
                children: filtered
                    .map(
                      (session) => _DoctorUpcomingCard(
                        session: session,
                        onOpen: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  DoctorPatientDetailsPage(session: session),
                            ),
                          );
                        },
                        onCancel: () => _handleDoctorStatusUpdate(
                          sessionId: session.id,
                          status: 'canceled',
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
          ValueListenableBuilder<List<DoctorSessionEntry>>(
            valueListenable: DoctorSessionStore.completedSessions,
            builder: (context, sessions, _) {
              final filtered = _filterSessions(sessions);
              if (filtered.isEmpty) {
                return _emptyState('No completed doctor sessions yet.');
              }
              return Column(
                children: filtered
                    .map(
                      (session) => _DoctorHistoryCard(
                        session: session,
                        onPrimary: () => _handleDoctorStatusUpdate(
                          sessionId: session.id,
                          status: 'upcoming',
                          sourceStage: DoctorSessionStage.completed,
                        ),
                        onMessage: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChatDetailPage(
                                userType: 'Doctor',
                                threadId: session.threadId,
                              ),
                            ),
                          );
                        },
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ];
      default:
        return [
          ValueListenableBuilder<List<DoctorSessionEntry>>(
            valueListenable: DoctorSessionStore.canceledSessions,
            builder: (context, sessions, _) {
              final filtered = _filterSessions(sessions);
              if (filtered.isEmpty) {
                return _emptyState('No canceled doctor sessions.');
              }
              return Column(
                children: filtered
                    .map(
                      (session) => _DoctorHistoryCard(
                        session: session,
                        onPrimary: () => _handleDoctorStatusUpdate(
                          sessionId: session.id,
                          status: 'upcoming',
                          sourceStage: DoctorSessionStage.canceled,
                        ),
                        onMessage: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChatDetailPage(
                                userType: 'Doctor',
                                threadId: session.threadId,
                              ),
                            ),
                          );
                        },
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ];
    }
  }

  List<DoctorSessionEntry> _filterSessions(List<DoctorSessionEntry> sessions) {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return sessions;
    return sessions.where((session) {
      return session.patientName.toLowerCase().contains(query) ||
          session.condition.toLowerCase().contains(query) ||
          session.time.toLowerCase().contains(query);
    }).toList();
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

  Future<void> _handleDoctorStatusUpdate({
    required String sessionId,
    required String status,
    DoctorSessionStage sourceStage = DoctorSessionStage.upcoming,
  }) async {
    try {
      switch (status) {
        case 'canceled':
          await LocalDemoSyncStore.doctorCancelUpcoming(sessionId);
          break;
        case 'completed':
          await LocalDemoSyncStore.doctorCompleteUpcoming(sessionId);
          break;
        default:
          await LocalDemoSyncStore.doctorRestoreToUpcoming(
            fromStage: sourceStage,
            doctorSessionId: sessionId,
          );
      }
      if (!mounted) return;
      setState(() {});
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    }
  }
}

class _DoctorUpcomingCard extends StatelessWidget {
  const _DoctorUpcomingCard({
    required this.session,
    required this.onOpen,
    required this.onCancel,
  });

  final DoctorSessionEntry session;
  final VoidCallback onOpen;
  final VoidCallback onCancel;

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
                      session.patientName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF2A5DC8),
                      ),
                    ),
                    Text(
                      session.condition,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 13.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 16,
                          color: Color(0xFF64748B),
                        ),
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
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onCancel,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFEF4444)),
                  ),
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.inter(
                      color: const Color(0xFFEF4444),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: onOpen,
                  child: Text(
                    session.ctaLabel,
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

class _DoctorHistoryCard extends StatelessWidget {
  const _DoctorHistoryCard({
    required this.session,
    required this.onPrimary,
    required this.onMessage,
  });

  final DoctorSessionEntry session;
  final VoidCallback onPrimary;
  final VoidCallback onMessage;

  @override
  Widget build(BuildContext context) {
    final isCanceled = session.stage == DoctorSessionStage.canceled;
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
                      session.patientName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF2A5DC8),
                      ),
                    ),
                    Text(
                      session.condition,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 13.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      session.time,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(fontSize: 12.sp),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      session.notes,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        color: const Color(0xFF64748B),
                      ),
                    ),
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
                  onPressed: onMessage,
                  child: const Text('Message'),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: onPrimary,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isCanceled ? const Color(0xFF0EA5E9) : AppColors.primary,
                  ),
                  child: Text(
                    isCanceled ? 'Reschedule' : 'Restore',
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

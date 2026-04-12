import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rom_tracker_app/core/constants/app_colors.dart';
import 'package:rom_tracker_app/core/widgets/app_search_bar.dart';
import 'package:rom_tracker_app/core/widgets/app_user_header.dart';
import 'package:rom_tracker_app/features/doctors/presentation/pages/doctor_patient_details_page.dart';
import 'package:rom_tracker_app/features/home/presentation/pages/main_layout.dart';
import 'package:rom_tracker_app/features/notifications/presentation/pages/notifications_page.dart';
import 'package:rom_tracker_app/features/sessions/presentation/models/doctor_session_entry.dart';
import 'package:rom_tracker_app/features/sessions/presentation/models/doctor_session_store.dart';
import 'package:rom_tracker_app/features/user_profile/presentation/models/user_profile_store.dart';

class DoctorHomePage extends StatefulWidget {
  const DoctorHomePage({super.key});

  @override
  State<DoctorHomePage> createState() => _DoctorHomePageState();
}

class _DoctorHomePageState extends State<DoctorHomePage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    DoctorSessionStore.ensureSeeded();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isCompact = MediaQuery.sizeOf(context).width < 390;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: Listenable.merge([
            UserProfileStore.doctorProfile,
            DoctorSessionStore.upcomingSessions,
            DoctorSessionStore.completedSessions,
            DoctorSessionStore.canceledSessions,
          ]),
          builder: (context, _) {
            final profile = UserProfileStore.doctorProfile.value;
            final sessions = _filteredSessions(
              DoctorSessionStore.upcomingSessions.value,
            );
            final completedCount = DoctorSessionStore.completedSessions.value.length;
            final todayCount = DoctorSessionStore.upcomingSessions.value.length;
            final upcomingCount = DoctorSessionStore.upcomingSessions.value.length;

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 12.h),
                  AppUserHeader(
                    avatarPath: profile.avatarPath,
                    title: 'Hello, Dr ${profile.firstName}',
                    subtitle: 'How\'s Your Health Today',
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
                    hintText: 'Search patients or conditions',
                    onChanged: (_) => setState(() {}),
                  ),
                  SizedBox(height: 18.h),
                  Container(
                    width: double.infinity,
                    padding:
                        EdgeInsets.symmetric(horizontal: 18.w, vertical: 18.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCECFF),
                      borderRadius: BorderRadius.circular(18.r),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _StatItem(
                          number: '$completedCount',
                          label: 'Completed',
                          isCompact: isCompact,
                        ),
                        const _StatDivider(),
                        _StatItem(
                          number: '$todayCount',
                          label: 'Today',
                          isCompact: isCompact,
                        ),
                        const _StatDivider(),
                        _StatItem(
                          number: '$upcomingCount',
                          label: 'Upcoming',
                          isCompact: isCompact,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    'Today Session',
                    style: GoogleFonts.inter(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 14.h),
                  if (sessions.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(20.w),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(18.r),
                      ),
                      child: Text(
                        'No matching sessions found.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    )
                  else
                    ...sessions.map(
                      (session) => _DoctorSessionCard(
                        data: session,
                        onOpen: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  DoctorPatientDetailsPage(session: session),
                            ),
                          );
                        },
                      ),
                    ),
                  SizedBox(height: 18.h),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  List<DoctorSessionEntry> _filteredSessions(List<DoctorSessionEntry> sessions) {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return sessions;
    return sessions.where((session) {
      return session.patientName.toLowerCase().contains(query) ||
          session.condition.toLowerCase().contains(query) ||
          session.time.toLowerCase().contains(query);
    }).toList();
  }
}

class _DoctorSessionCard extends StatelessWidget {
  const _DoctorSessionCard({
    required this.data,
    required this.onOpen,
  });

  final DoctorSessionEntry data;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final primaryAction = data.ctaLabel != 'Upcoming';

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
            children: [
              ClipOval(
                child: Image.asset(
                  data.imagePath,
                  width: 48.w,
                  height: 48.w,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.patientName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 16.5.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF2A5DC8),
                      ),
                    ),
                    Text(
                      data.condition,
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
                            data.time,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
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
                child: const Icon(
                  Icons.videocam_outlined,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          SizedBox(
            width: double.infinity,
            height: 44.h,
            child: ElevatedButton(
              onPressed: onOpen,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    primaryAction ? AppColors.primary : const Color(0xFFE2E8F0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
              ),
              child: Text(
                data.ctaLabel,
                style: GoogleFonts.inter(
                  color: primaryAction ? Colors.white : const Color(0xFF475569),
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

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.number,
    required this.label,
    required this.isCompact,
  });

  final String number;
  final String label;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            number,
            style: GoogleFonts.inter(
              fontSize: isCompact ? 20.sp : 22.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        SizedBox(height: 4.h),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

class _StatDivider extends StatelessWidget {
  const _StatDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 38.h,
      color: const Color(0xFFBFD4F9),
    );
  }
}

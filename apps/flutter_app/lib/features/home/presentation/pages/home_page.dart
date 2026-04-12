import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rom_tracker_app/core/constants/app_assets.dart';
import 'package:rom_tracker_app/core/constants/app_colors.dart';
import 'package:rom_tracker_app/core/widgets/app_search_bar.dart';
import 'package:rom_tracker_app/core/widgets/app_user_header.dart';
import 'package:rom_tracker_app/features/doctors/presentation/models/doctor_catalog.dart';
import 'package:rom_tracker_app/features/doctors/presentation/models/doctor_profile.dart';
import 'package:rom_tracker_app/features/doctors/presentation/pages/doctor_details_page.dart';
import 'package:rom_tracker_app/features/home/presentation/pages/help_search_page.dart';
import 'package:rom_tracker_app/features/home/presentation/pages/main_layout.dart';
import 'package:rom_tracker_app/features/home/presentation/pages/symptom_list_page.dart';
import 'package:rom_tracker_app/features/notifications/presentation/pages/notifications_page.dart';
import 'package:rom_tracker_app/features/user_profile/presentation/models/user_profile_data.dart';
import 'package:rom_tracker_app/features/user_profile/presentation/models/user_profile_store.dart';
import 'package:rom_tracker_app/features/user_profile/presentation/models/wishlist_store.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _topDoctorsKey = GlobalKey();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _scrollToTopDoctors() async {
    final context = _topDoctorsKey.currentContext;
    if (context == null) return;
    await Scrollable.ensureVisible(
      context,
      duration: const Duration(milliseconds: 550),
      curve: Curves.easeInOutCubic,
      alignment: 0.08,
    );
  }

  @override
  Widget build(BuildContext context) {
    final doctors = DoctorCatalog.topDoctors;
    final isCompact = MediaQuery.sizeOf(context).width < 390;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ValueListenableBuilder<UserProfileData>(
          valueListenable: UserProfileStore.patientProfile,
          builder: (context, profile, _) {
            return SingleChildScrollView(
              controller: _scrollController,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 12.h),
                  AppUserHeader(
                    avatarPath: profile.avatarPath,
                    title: 'Hello, ${profile.firstName}',
                    subtitle: 'How\'s Your Health Today',
                    notificationUserType: 'Patient',
                    onProfileTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MainLayout(
                            userType: 'Patient',
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
                            userType: 'Patient',
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 18.h),
                  AppSearchBar(
                    readOnly: true,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const HelpSearchPage(),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 18.h),
                  Container(
                    height: isCompact ? 156.h : 144.h,
                    padding: EdgeInsets.fromLTRB(16.w, 14.h, 10.w, 12.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCECFF),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Start your recovery with top\nphysical therapy sessions!',
                                style: GoogleFonts.inter(
                                  fontSize: isCompact ? 13.sp : 14.sp,
                                  height: 1.25,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF204A9D),
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                'Great discounts on pain-relief & rehab programs!',
                                style: GoogleFonts.inter(
                                  fontSize: isCompact ? 10.sp : 10.5.sp,
                                  height: 1.25,
                                  color: const Color(0xFF5B6B88),
                                ),
                              ),
                              SizedBox(height: isCompact ? 10.h : 8.h),
                              SizedBox(
                                height: 36.h,
                                child: ElevatedButton(
                                  onPressed: _scrollToTopDoctors,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 14.w,
                                      vertical: 0,
                                    ),
                                    minimumSize: Size(92.w, 36.h),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.r),
                                    ),
                                  ),
                                  child: Text(
                                    'Book now!',
                                    style: GoogleFonts.inter(
                                      color: Colors.white,
                                      fontSize: isCompact ? 11.sp : 11.5.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 10.w),
                        SizedBox(
                          width: isCompact ? 92.w : 100.w,
                          height: isCompact ? 124.h : 118.h,
                          child: Image.asset(
                            AppAssets.phase2BannerDoctor,
                            fit: BoxFit.contain,
                            alignment: Alignment.bottomCenter,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 8.w,
                        height: 8.w,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Container(
                        width: 6.w,
                        height: 6.w,
                        decoration: const BoxDecoration(
                          color: Color(0xFFD6D6D6),
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Container(
                        width: 6.w,
                        height: 6.w,
                        decoration: const BoxDecoration(
                          color: Color(0xFFD6D6D6),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 18.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'All symptoms',
                        style: GoogleFonts.inter(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SymptomListPage(),
                            ),
                          );
                        },
                        child: Text(
                          'See all',
                          style: GoogleFonts.inter(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Wrap(
                    spacing: 10.w,
                    runSpacing: 10.h,
                    children: [
                      _SymptomChip(
                        label: 'Sporty',
                        icon: Icons.fitness_center_rounded,
                        background: const Color(0xFF2F80ED),
                        onTap: () => _openSymptoms(context),
                      ),
                      _SymptomChip(
                        label: 'Orthopedic',
                        icon: Icons.accessibility_new_rounded,
                        background: const Color(0xFFE8FFF6),
                        iconColor: const Color(0xFF63E6BE),
                        onTap: () => _openSymptoms(context),
                      ),
                      _SymptomChip(
                        label: 'Rheumatological',
                        icon: Icons.elderly_outlined,
                        background: const Color(0xFFFFF6D8),
                        iconColor: const Color(0xFFF4C542),
                        onTap: () => _openSymptoms(context),
                      ),
                      _SymptomChip(
                        label: 'Trauma',
                        icon: Icons.airline_seat_flat_angled_outlined,
                        background: const Color(0xFFE6F0FF),
                        iconColor: const Color(0xFF5C9EFF),
                        onTap: () => _openSymptoms(context),
                      ),
                    ],
                  ),
                  SizedBox(height: 18.h),
                  Row(
                    key: _topDoctorsKey,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Top Doctors',
                        style: GoogleFonts.inter(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      TextButton(
                        onPressed: _scrollToTopDoctors,
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'See all',
                          style: GoogleFonts.inter(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  ValueListenableBuilder<Set<String>>(
                    valueListenable: WishlistStore.favorites,
                    builder: (context, favorites, _) {
                      return GridView.builder(
                        itemCount: doctors.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10.w,
                          mainAxisSpacing: 12.h,
                          childAspectRatio: isCompact ? 0.61 : 0.665,
                        ),
                        itemBuilder: (context, index) {
                          final doctor = doctors[index];
                          return _DoctorCard(
                            data: doctor,
                            isFavorite: favorites.contains(doctor.name),
                            onFavoriteTap: () =>
                                WishlistStore.toggle(doctor.name),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      DoctorDetailsPage(doctor: doctor),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
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

  void _openSymptoms(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SymptomListPage()),
    );
  }
}

class _SymptomChip extends StatelessWidget {
  const _SymptomChip({
    required this.label,
    required this.icon,
    required this.background,
    required this.onTap,
    this.iconColor = Colors.white,
  });

  final String label;
  final IconData icon;
  final Color background;
  final Color iconColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      overlayColor: const MaterialStatePropertyAll(Colors.transparent),
      child: Container(
        width: 78.w,
        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 8.w),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          children: [
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: background,
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Icon(icon, color: iconColor, size: 22.sp),
            ),
            SizedBox(height: 8.h),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DoctorCard extends StatelessWidget {
  const _DoctorCard({
    required this.data,
    required this.onTap,
    required this.isFavorite,
    required this.onFavoriteTap,
  });

  final DoctorProfile data;
  final VoidCallback onTap;
  final bool isFavorite;
  final VoidCallback onFavoriteTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      overlayColor: const MaterialStatePropertyAll(Colors.transparent),
      child: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 118.h,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.asset(
                    data.imagePath,
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ),
                Positioned(
                  top: 6.h,
                  left: 6.w,
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.star_rounded,
                          color: const Color(0xFFF4C542),
                          size: 12.sp,
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          '4.9',
                          style: GoogleFonts.inter(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Row(
              children: [
                SizedBox(width: 2.w),
                const Spacer(),
                IconButton(
                  onPressed: onFavoriteTap,
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                  style: ButtonStyle(
                    overlayColor:
                        const MaterialStatePropertyAll(Colors.transparent),
                    splashFactory: NoSplash.splashFactory,
                  ),
                  icon: Icon(
                    isFavorite
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    size: 18,
                    color: isFavorite
                        ? const Color(0xFFEF4444)
                        : const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            Text(
              data.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF202939),
              ),
            ),
            Text(
              '${data.specialty}\nyears of experience +${data.experienceYears}',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 10.5.sp,
                color: AppColors.textSecondary,
                height: 1.35,
              ),
            ),
            SizedBox(height: 5.h),
            Text(
              'Session: ${data.cardPrice}',
              style: GoogleFonts.inter(
                fontSize: 10.8.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

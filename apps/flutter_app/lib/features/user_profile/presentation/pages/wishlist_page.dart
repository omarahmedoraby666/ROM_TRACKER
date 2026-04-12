import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rom_tracker_app/core/constants/app_colors.dart';
import 'package:rom_tracker_app/features/doctors/presentation/models/doctor_catalog.dart';
import 'package:rom_tracker_app/features/doctors/presentation/models/doctor_profile.dart';
import 'package:rom_tracker_app/features/doctors/presentation/pages/doctor_details_page.dart';
import 'package:rom_tracker_app/features/user_profile/presentation/models/wishlist_store.dart';

class WishlistPage extends StatelessWidget {
  const WishlistPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Wishlist',
          style: GoogleFonts.inter(
            color: Colors.black,
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ValueListenableBuilder<Set<String>>(
          valueListenable: WishlistStore.favorites,
          builder: (context, favorites, _) {
            final items = DoctorCatalog.topDoctors
                .where((doctor) => favorites.contains(doctor.name))
                .toList();

            if (items.isEmpty) {
              return Center(
                child: Text(
                  'No favorite doctors yet.',
                  style: GoogleFonts.inter(
                    fontSize: 15.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              );
            }

            return ListView.separated(
              padding: EdgeInsets.all(16.w),
              itemCount: items.length,
              separatorBuilder: (_, __) => SizedBox(height: 12.h),
              itemBuilder: (context, index) {
                final doctor = items[index];
                return _WishlistCard(doctor: doctor);
              },
            );
          },
        ),
      ),
    );
  }
}

class _WishlistCard extends StatelessWidget {
  const _WishlistCard({required this.doctor});

  final DoctorProfile doctor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DoctorDetailsPage(doctor: doctor),
          ),
        );
      },
      borderRadius: BorderRadius.circular(18.r),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      overlayColor: const MaterialStatePropertyAll(Colors.transparent),
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(18.r),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14.r),
              child: Image.asset(
                doctor.imagePath,
                width: 78.w,
                height: 78.h,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doctor.name,
                    style: GoogleFonts.inter(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    doctor.specialty,
                    style: GoogleFonts.inter(
                      fontSize: 13.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Session: ${doctor.cardPrice}',
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => WishlistStore.toggle(doctor.name),
              style: ButtonStyle(
                overlayColor:
                    const MaterialStatePropertyAll(Colors.transparent),
                splashFactory: NoSplash.splashFactory,
              ),
              icon: const Icon(
                Icons.favorite_rounded,
                color: Color(0xFFEF4444),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rom_tracker_app/core/constants/app_colors.dart';
import 'package:rom_tracker_app/features/sessions/presentation/models/booking_store.dart';
import 'package:rom_tracker_app/features/sessions/presentation/models/session_entry.dart';

class ReviewsPage extends StatelessWidget {
  const ReviewsPage({super.key});

  @override
  Widget build(BuildContext context) {
    BookingStore.ensureSeeded();
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
          'Reviews',
          style: GoogleFonts.inter(
            color: Colors.black,
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: Listenable.merge([
            BookingStore.completedSessions,
            BookingStore.canceledSessions,
          ]),
          builder: (context, _) {
            final reviews = [
              ...BookingStore.completedSessions.value,
              ...BookingStore.canceledSessions.value,
            ].where((session) => (session.review ?? '').trim().isNotEmpty).toList();

            if (reviews.isEmpty) {
              return Center(
                child: Text(
                  'No reviews added yet.',
                  style: GoogleFonts.inter(
                    fontSize: 15.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              );
            }

            return ListView.separated(
              padding: EdgeInsets.all(16.w),
              itemCount: reviews.length,
              separatorBuilder: (_, __) => SizedBox(height: 12.h),
              itemBuilder: (context, index) {
                return _ReviewCard(session: reviews[index]);
              },
            );
          },
        ),
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.session});

  final SessionEntry session;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14.r),
            child: Image.asset(
              session.imagePath,
              width: 74.w,
              height: 74.h,
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
                SizedBox(height: 4.h),
                Text(
                  session.specialty,
                  style: GoogleFonts.inter(
                    fontSize: 13.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  session.review ?? '',
                  style: GoogleFonts.inter(
                    fontSize: 13.sp,
                    height: 1.45,
                    color: const Color(0xFF334155),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

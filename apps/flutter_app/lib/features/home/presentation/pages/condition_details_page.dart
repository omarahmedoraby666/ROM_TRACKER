import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rom_tracker_app/core/constants/app_colors.dart';
import 'package:rom_tracker_app/core/widgets/app_page_shell.dart';
import 'package:rom_tracker_app/features/camera/presentation/pages/camera_page.dart';

class ConditionDetailsPage extends StatelessWidget {
  const ConditionDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPageShell(
      title: 'Condition Details',
      subtitle:
          'Explain the issue clearly, suggest exercises, and move the patient into the guided camera session.',
      onBack: () => Navigator.pop(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            height: 220.h,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(24.r),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 148.w,
                    height: 148.w,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E2E2),
                      borderRadius: BorderRadius.circular(42.r),
                    ),
                    child: Icon(
                      Icons.accessibility_new_rounded,
                      size: 64.sp,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            'Arthritis Overview',
            style: GoogleFonts.inter(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            'Arthritis can cause pain, stiffness, and lower flexibility in the affected joints. A guided home routine helps the patient move safely while the doctor tracks progress over time.',
            style: GoogleFonts.inter(
              fontSize: 15.sp,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
          SizedBox(height: 28.h),
          Text(
            'Recommended Exercises',
            style: GoogleFonts.inter(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 18.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              _ExerciseCard('Stretching', Icons.accessibility_new_rounded),
              _ExerciseCard('Squats', Icons.downhill_skiing),
              _ExerciseCard('Treadmill', Icons.directions_run),
            ],
          ),
          SizedBox(height: 30.h),
          AppPrimaryButton(
            label: 'Start Now',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CameraPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  const _ExerciseCard(this.title, this.icon);

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100.w,
      padding: EdgeInsets.symmetric(vertical: 14.h),
      decoration: BoxDecoration(
        color: const Color(0xFFBFDBFE),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          Icon(icon, size: 34.sp, color: Colors.black87),
          SizedBox(height: 12.h),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

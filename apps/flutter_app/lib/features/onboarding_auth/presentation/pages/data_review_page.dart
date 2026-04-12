import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rom_tracker_app/core/constants/app_colors.dart';
import 'package:rom_tracker_app/core/widgets/app_page_shell.dart';
import 'package:rom_tracker_app/features/onboarding_auth/presentation/models/registration_draft.dart';
import 'package:rom_tracker_app/features/onboarding_auth/presentation/pages/login_page.dart';

class DataReviewPage extends StatelessWidget {
  const DataReviewPage({
    super.key,
    required this.draft,
  });

  final RegistrationDraft draft;

  @override
  Widget build(BuildContext context) {
    return AppPageShell(
      title: 'Under Review',
      subtitle:
          'Doctor accounts stay pending until the submitted professional data is reviewed and approved.',
      onBack: () => Navigator.pop(context),
      child: Column(
        children: [
          Row(
            children: List.generate(
              4,
              (_) => Expanded(
                child: Container(
                  height: 4.h,
                  margin: EdgeInsets.symmetric(horizontal: 4.w),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 36.h),
          Container(
            width: 150.w,
            height: 150.w,
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              shape: BoxShape.circle,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 120.w,
                  height: 120.w,
                  child: CircularProgressIndicator(
                    value: 0.72,
                    strokeWidth: 10.w,
                    backgroundColor: Colors.white,
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),
                Icon(
                  Icons.pending_actions_rounded,
                  size: 42.sp,
                  color: AppColors.primary,
                ),
              ],
            ),
          ),
          SizedBox(height: 26.h),
          Text(
            'Your account is under review',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 24.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            'We will review the submitted data and activate the doctor account within 24 hours.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 15.sp,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
          SizedBox(height: 20.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(18.w),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              '${draft.firstName} ${draft.lastName}\n${draft.specialization ?? 'Physiotherapy'}',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 15.sp,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ),
          SizedBox(height: 24.h),
          AppPrimaryButton(
            label: 'Back to Login',
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}

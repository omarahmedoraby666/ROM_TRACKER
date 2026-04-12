import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rom_tracker_app/core/constants/app_assets.dart';
import 'package:rom_tracker_app/core/constants/app_colors.dart';
import 'package:rom_tracker_app/features/onboarding_auth/presentation/models/registration_draft.dart';
import 'package:rom_tracker_app/features/onboarding_auth/presentation/pages/condition_selection_page.dart';
import 'package:rom_tracker_app/features/onboarding_auth/presentation/pages/specialization_selection_page.dart';
import 'package:rom_tracker_app/features/onboarding_auth/presentation/widgets/auth_progress_bar.dart';

class UserTypeSelectionPage extends StatefulWidget {
  const UserTypeSelectionPage({super.key});

  @override
  State<UserTypeSelectionPage> createState() => _UserTypeSelectionPageState();
}

class _UserTypeSelectionPageState extends State<UserTypeSelectionPage> {
  String selectedType = 'Patient';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'User Types',
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF262626),
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            children: [
              SizedBox(height: 10.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 62.w),
                child: const AuthProgressBar(currentStep: 1),
              ),
              SizedBox(height: 26.h),
              Text(
                'Tell Us About Yourself ?',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF272727),
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'To give you a better experience and results\nwe need to know your gender.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 13.sp,
                  height: 1.4,
                  color: const Color(0xFF777777),
                ),
              ),
              SizedBox(height: 28.h),
              Container(
                width: double.infinity,
                height: 188.h,
                padding: EdgeInsets.symmetric(horizontal: 34.w, vertical: 30.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFD9E8FF),
                  borderRadius: BorderRadius.circular(24.r),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: _buildTypeCard(
                        title: 'Patient',
                        imagePath: AppAssets.patientAvatarRef,
                        isSelected: selectedType == 'Patient',
                        onTap: () => setState(() => selectedType = 'Patient'),
                      ),
                    ),
                    SizedBox(width: 22.w),
                    Expanded(
                      child: _buildTypeCard(
                        title: 'Doctor',
                        imagePath: AppAssets.doctorAvatarRef,
                        isSelected: selectedType == 'Doctor',
                        onTap: () => setState(() => selectedType = 'Doctor'),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => selectedType == 'Patient'
                            ? ConditionSelectionPage(
                                draft: RegistrationDraft(userType: selectedType),
                              )
                            : SpecializationSelectionPage(
                                draft: RegistrationDraft(userType: selectedType),
                              ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    minimumSize: Size(double.infinity, 52.h),
                  ),
                  child: Text(
                    'Next',
                    style: GoogleFonts.inter(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 26.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeCard({
    required String title,
    required String imagePath,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            height: 104.h,
            padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 8.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: isSelected ? AppColors.primary : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                ClipOval(
                  child: Container(
                    width: 48.w,
                    height: 48.w,
                    color: const Color(0xFFE6F1E8),
                    child: Image.asset(
                      imagePath,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2B2B2B),
                  ),
                ),
              ],
            ),
          ),
          if (isSelected)
            Positioned(
              top: 8.h,
              right: 8.w,
              child: Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(5.r),
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 16),
              ),
            ),
        ],
      ),
    );
  }
}

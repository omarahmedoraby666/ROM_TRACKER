import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rom_tracker_app/core/constants/app_colors.dart';
import 'package:rom_tracker_app/core/widgets/app_page_shell.dart';
import 'package:rom_tracker_app/features/onboarding_auth/presentation/models/registration_draft.dart';
import 'package:rom_tracker_app/features/onboarding_auth/presentation/pages/basic_data_page.dart';
import 'package:rom_tracker_app/features/onboarding_auth/presentation/widgets/auth_progress_bar.dart';

class AgeSelectionPage extends StatefulWidget {
  const AgeSelectionPage({
    super.key,
    required this.draft,
  });

  final RegistrationDraft draft;

  @override
  State<AgeSelectionPage> createState() => _AgeSelectionPageState();
}

class _AgeSelectionPageState extends State<AgeSelectionPage> {
  late int selectedAge;
  late final FixedExtentScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    selectedAge = widget.draft.age ?? 24;
    _scrollController =
        FixedExtentScrollController(initialItem: selectedAge - 18);
  }

  @override
  Widget build(BuildContext context) {
    return AppPageShell(
      title: 'Age',
      subtitle:
          'We use age as part of building a more realistic recovery plan and safer exercise guidance.',
      onBack: () => Navigator.pop(context),
      child: Column(
        children: [
          const AuthProgressBar(currentStep: 3),
          SizedBox(height: 26.h),
          Container(
            padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 18.w),
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(28.r),
            ),
            child: Column(
              children: [
                Text(
                  'What\'s your age?',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Scroll to choose the age that matches the account owner.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 20.h),
                SizedBox(
                  height: 220.h,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        height: 58.h,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18.r),
                        ),
                      ),
                      ListWheelScrollView.useDelegate(
                        controller: _scrollController,
                        itemExtent: 65.h,
                        perspective: 0.005,
                        diameterRatio: 1.5,
                        physics: const FixedExtentScrollPhysics(),
                        onSelectedItemChanged: (index) {
                          setState(() => selectedAge = 18 + index);
                        },
                        childDelegate: ListWheelChildBuilderDelegate(
                          childCount: 80,
                          builder: (context, index) {
                            final age = 18 + index;
                            final isSelected = age == selectedAge;
                            return Center(
                              child: Text(
                                age.toString(),
                                style: GoogleFonts.inter(
                                  fontSize: isSelected ? 32.sp : 24.sp,
                                  fontWeight: isSelected
                                      ? FontWeight.w800
                                      : FontWeight.w500,
                                  color: isSelected
                                      ? AppColors.textPrimary
                                      : const Color(0xFFCBD5E1),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 22.h),
          AppPrimaryButton(
            label: 'Next',
            onPressed: () {
              final updatedDraft = widget.draft.copyWith(age: selectedAge);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BasicDataPage(draft: updatedDraft),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

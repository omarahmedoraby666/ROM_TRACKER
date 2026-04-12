import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rom_tracker_app/core/constants/app_colors.dart';
import 'package:rom_tracker_app/core/widgets/app_page_shell.dart';
import 'package:rom_tracker_app/features/onboarding_auth/presentation/models/registration_draft.dart';
import 'package:rom_tracker_app/features/onboarding_auth/presentation/pages/age_selection_page.dart';
import 'package:rom_tracker_app/features/onboarding_auth/presentation/widgets/auth_progress_bar.dart';

class ConditionSelectionPage extends StatefulWidget {
  const ConditionSelectionPage({
    super.key,
    required this.draft,
  });

  final RegistrationDraft draft;

  @override
  State<ConditionSelectionPage> createState() => _ConditionSelectionPageState();
}

class _ConditionSelectionPageState extends State<ConditionSelectionPage> {
  final List<String> conditions = const [
    'Back pain',
    'Knee pain',
    'Neck pain',
    'Sports injury',
    'Post-surgery recovery',
  ];

  String? selectedCondition = 'Back pain';

  @override
  Widget build(BuildContext context) {
    return AppPageShell(
      title: 'Condition & Symptoms',
      subtitle:
          'Select the condition that best describes the patient so the registration and home experience stay relevant from the first day.',
      onBack: () => Navigator.pop(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AuthProgressBar(currentStep: 2),
          SizedBox(height: 26.h),
          ...conditions.map(
            (condition) {
              final isSelected = selectedCondition == condition;
              return Padding(
                padding: EdgeInsets.only(bottom: 14.h),
                child: GestureDetector(
                  onTap: () => setState(() => selectedCondition = condition),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white : AppColors.surface,
                      borderRadius: BorderRadius.circular(22.r),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            condition,
                            style: GoogleFonts.inter(
                              fontSize: 16.sp,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ),
                        Container(
                          height: 24.h,
                          width: 24.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected ? AppColors.primary : Colors.transparent,
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : const Color(0xFFCBD5E1),
                            ),
                          ),
                          child: isSelected
                              ? Icon(Icons.check, color: Colors.white, size: 14.sp)
                              : null,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          SizedBox(height: 14.h),
          AppPrimaryButton(
            label: 'Next',
            onPressed: () {
              final updatedDraft =
                  widget.draft.copyWith(condition: selectedCondition);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AgeSelectionPage(draft: updatedDraft),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

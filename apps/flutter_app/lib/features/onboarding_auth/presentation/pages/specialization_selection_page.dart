import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rom_tracker_app/core/constants/app_colors.dart';
import 'package:rom_tracker_app/core/widgets/app_page_shell.dart';
import 'package:rom_tracker_app/features/onboarding_auth/presentation/models/registration_draft.dart';
import 'package:rom_tracker_app/features/onboarding_auth/presentation/pages/age_selection_page.dart';
import 'package:rom_tracker_app/features/onboarding_auth/presentation/widgets/auth_progress_bar.dart';

class SpecializationSelectionPage extends StatefulWidget {
  const SpecializationSelectionPage({
    super.key,
    required this.draft,
  });

  final RegistrationDraft draft;

  @override
  State<SpecializationSelectionPage> createState() =>
      _SpecializationSelectionPageState();
}

class _SpecializationSelectionPageState
    extends State<SpecializationSelectionPage> {
  final List<String> specializations = const [
    'Physiotherapy',
    'Orthopedics',
    'Neurology',
    'Sports Injuries',
    'Rehabilitation',
  ];

  String? selectedSpecialization = 'Physiotherapy';

  @override
  Widget build(BuildContext context) {
    return AppPageShell(
      title: 'Specialization',
      subtitle:
          'Choose the medical field that best represents the doctor account before continuing to age and profile data.',
      onBack: () => Navigator.pop(context),
      child: Column(
        children: [
          const AuthProgressBar(currentStep: 2),
          SizedBox(height: 24.h),
          ...specializations.map(
            (specialization) {
              final isSelected = selectedSpecialization == specialization;
              return Padding(
                padding: EdgeInsets.only(bottom: 14.h),
                child: GestureDetector(
                  onTap: () =>
                      setState(() => selectedSpecialization = specialization),
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
                            specialization,
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
                        Icon(
                          isSelected
                              ? Icons.check_circle
                              : Icons.circle_outlined,
                          color: isSelected
                              ? AppColors.primary
                              : const Color(0xFFCBD5E1),
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
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AgeSelectionPage(
                    draft: widget.draft.copyWith(
                      specialization: selectedSpecialization,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

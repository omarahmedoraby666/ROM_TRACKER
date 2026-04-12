import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rom_tracker_app/core/constants/app_colors.dart';

class AuthProgressBar extends StatelessWidget {
  const AuthProgressBar({
    super.key,
    required this.currentStep,
    this.totalSteps = 4,
  });

  final int currentStep;
  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        totalSteps,
        (index) => Expanded(
          child: Container(
            height: 4.h,
            margin: EdgeInsets.symmetric(horizontal: 4.w),
            decoration: BoxDecoration(
              color: index < currentStep
                  ? AppColors.primary
                  : const Color(0xFFD7E5FF),
              borderRadius: BorderRadius.circular(100.r),
            ),
          ),
        ),
      ),
    );
  }
}

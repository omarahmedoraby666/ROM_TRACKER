import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rom_tracker_app/core/constants/app_colors.dart';
import 'package:rom_tracker_app/core/widgets/app_page_shell.dart';
import 'package:rom_tracker_app/features/onboarding_auth/presentation/pages/login_page.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;
  bool hasError = false;

  @override
  Widget build(BuildContext context) {
    return AppPageShell(
      title: 'Reset Password',
      subtitle:
          'Create a secure new password for your ROM Tracker account. Matching passwords with at least 6 characters are accepted.',
      onBack: () => Navigator.pop(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(22.w),
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(28.r),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Update your password and get back to your therapy plan.',
                    style: GoogleFonts.inter(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      height: 1.4,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Container(
                  width: 76.w,
                  height: 76.w,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.lock_reset_rounded,
                    color: AppColors.primary,
                    size: 38,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 28.h),
          Text(
            'New Password',
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 8.h),
          TextField(
            controller: _passwordController,
            obscureText: !isPasswordVisible,
            decoration: _decoration(
              isPasswordVisible,
              () => setState(() => isPasswordVisible = !isPasswordVisible),
            ),
          ),
          SizedBox(height: 22.h),
          Text(
            'Confirm New Password',
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: hasError ? AppColors.error : Colors.black,
            ),
          ),
          SizedBox(height: 8.h),
          TextField(
            controller: _confirmPasswordController,
            obscureText: !isConfirmPasswordVisible,
            decoration: _decoration(
              isConfirmPasswordVisible,
              () => setState(
                () => isConfirmPasswordVisible = !isConfirmPasswordVisible,
              ),
              borderColor: hasError ? AppColors.error : AppColors.border,
            ),
          ),
          if (hasError)
            Padding(
              padding: EdgeInsets.only(top: 12.h),
              child: Center(
                child: Text(
                  'Passwords do not match or are too short.',
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    color: AppColors.error,
                  ),
                ),
              ),
            ),
          SizedBox(height: 30.h),
          AppPrimaryButton(
            label: 'Confirm',
            onPressed: () {
              setState(() {
                hasError = _passwordController.text.trim().length < 6 ||
                    _passwordController.text.trim() !=
                        _confirmPasswordController.text.trim();
              });

              if (!hasError) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
    );
  }

  InputDecoration _decoration(
    bool visible,
    VoidCallback onTap, {
    Color borderColor = AppColors.border,
  }) {
    return InputDecoration(
      hintText: 'Enter your password',
      suffixIcon: IconButton(
        icon: Icon(
          visible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          color: const Color(0xFF64748B),
        ),
        onPressed: onTap,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: borderColor, width: 1.5),
      ),
    );
  }
}

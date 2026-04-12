import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rom_tracker_app/core/constants/app_colors.dart';
import 'package:rom_tracker_app/core/widgets/app_page_shell.dart';
import 'package:rom_tracker_app/features/onboarding_auth/presentation/pages/reset_password_page.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({
    super.key,
    required this.target,
    required this.isEmail,
  });

  final String target;
  final bool isEmail;

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _controllers =
      List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());

  @override
  Widget build(BuildContext context) {
    return AppPageShell(
      title: 'OTP Code',
      subtitle:
          'Enter the 4-digit verification code sent to ${widget.target}. This step is reserved for password recovery only.',
      onBack: () => Navigator.pop(context),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 26.h),
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(28.r),
            ),
            child: Column(
              children: [
                Container(
                  width: 84.w,
                  height: 84.w,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: const Icon(
                    Icons.verified_user_rounded,
                    color: AppColors.primary,
                    size: 42,
                  ),
                ),
                SizedBox(height: 18.h),
                Text(
                  'OTP Code',
                  style: GoogleFonts.inter(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryDark,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  widget.target,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 28.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(
              4,
              (index) => Container(
                width: 62.w,
                height: 64.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: AppColors.border, width: 1.5),
                ),
                child: TextField(
                  controller: _controllers[index],
                  focusNode: _focusNodes[index],
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  maxLength: 1,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: GoogleFonts.inter(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w800,
                  ),
                  onChanged: (value) {
                    if (value.isNotEmpty && index < 3) {
                      _focusNodes[index + 1].requestFocus();
                    } else if (value.isEmpty && index > 0) {
                      _focusNodes[index - 1].requestFocus();
                    }
                  },
                  decoration: const InputDecoration(
                    counterText: '',
                    border: InputBorder.none,
                    filled: false,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 18.h),
          TextButton(
            onPressed: () {},
            child: const Text('Resend OTP'),
          ),
          SizedBox(height: 18.h),
          AppPrimaryButton(
            label: 'Verify',
            onPressed: _handleVerify,
          ),
        ],
      ),
    );
  }

  void _handleVerify() {
    final isComplete =
        _controllers.every((controller) => controller.text.isNotEmpty);
    if (!isComplete) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the full 4-digit code')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ResetPasswordPage()),
    );
  }
}

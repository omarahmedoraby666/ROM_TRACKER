import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rom_tracker_app/core/constants/app_assets.dart';
import 'package:rom_tracker_app/core/constants/app_colors.dart';
import 'package:rom_tracker_app/core/widgets/app_page_shell.dart';
import 'package:rom_tracker_app/features/onboarding_auth/presentation/pages/otp_screen.dart';

class ForgetPasswordPage extends StatefulWidget {
  const ForgetPasswordPage({super.key});

  @override
  State<ForgetPasswordPage> createState() => _ForgetPasswordPageState();
}

class _ForgetPasswordPageState extends State<ForgetPasswordPage> {
  static final _emailRegex =
      RegExp(r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$');
  bool isPhoneSelected = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AppPageShell(
      title: 'Forget Password',
      subtitle:
          'Choose whether to recover your account by email or phone number. This flow is separate from sign up and is used only for password reset.',
      onBack: () => Navigator.pop(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _RecoveryIllustration(isPhoneSelected: isPhoneSelected),
          SizedBox(height: 28.h),
          AppSurfaceCard(
            color: AppColors.primarySoft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 64.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => isPhoneSelected = true),
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isPhoneSelected
                                  ? AppColors.primary
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                            child: Text(
                              'Phone number',
                              style: GoogleFonts.inter(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w700,
                                color: isPhoneSelected
                                    ? Colors.white
                                    : AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => isPhoneSelected = false),
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: !isPhoneSelected
                                  ? AppColors.primary
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                            child: Text(
                              'Email',
                              style: GoogleFonts.inter(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w700,
                                color: !isPhoneSelected
                                    ? Colors.white
                                    : AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24.h),
                Text(
                  isPhoneSelected ? 'Phone Number' : 'Email Address',
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 12.h),
                if (isPhoneSelected)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    height: 56.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Row(
                      children: [
                        Text('+20', style: GoogleFonts.inter(fontSize: 14.sp)),
                        SizedBox(width: 12.w),
                        Container(
                          width: 1,
                          height: 24.h,
                          color: AppColors.border,
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: TextField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(11),
                            ],
                            decoration: const InputDecoration(
                              hintText: 'Enter your phone',
                              border: InputBorder.none,
                              filled: false,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      hintText: 'Enter your email',
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: 28.h),
          AppPrimaryButton(
            label: 'Confirm',
            onPressed: () {
              final target = isPhoneSelected
                  ? _phoneController.text.trim()
                  : _emailController.text.trim();
              final isValid = isPhoneSelected
                  ? RegExp(r'^\d{10,11}$').hasMatch(target)
                  : _emailRegex.hasMatch(target);
              if (!isValid) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isPhoneSelected
                          ? 'Enter a valid phone number'
                          : 'Enter a valid email address',
                    ),
                  ),
                );
                return;
              }
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => OtpScreen(
                    target: target,
                    isEmail: !isPhoneSelected,
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

class _RecoveryIllustration extends StatelessWidget {
  const _RecoveryIllustration({required this.isPhoneSelected});

  final bool isPhoneSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFEAF3FF), Color(0xFFF7FBFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30.r),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 150.h,
            child: Image.asset(
              AppAssets.forgotPasswordArt,
              fit: BoxFit.contain,
            ),
          ),
          SizedBox(height: 14.h),
          Text(
            isPhoneSelected ? 'Verify by phone' : 'Verify by email',
            style: GoogleFonts.inter(
              fontSize: 20.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryDark,
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            'We will send a short code so you can safely reset your password.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 13.sp,
              height: 1.5,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

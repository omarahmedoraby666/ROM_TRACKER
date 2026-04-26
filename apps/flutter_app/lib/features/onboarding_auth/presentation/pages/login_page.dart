import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rom_tracker_app/core/constants/app_assets.dart';
import 'package:rom_tracker_app/core/constants/app_colors.dart';
import 'package:rom_tracker_app/features/home/presentation/pages/main_layout.dart';
import 'package:rom_tracker_app/features/onboarding_auth/data/auth_contract.dart';
import 'package:rom_tracker_app/features/onboarding_auth/data/backend_auth_api.dart';
import 'package:rom_tracker_app/features/onboarding_auth/presentation/models/mock_auth_service.dart';
import 'package:rom_tracker_app/features/onboarding_auth/presentation/models/auth_session_store.dart';
import 'package:rom_tracker_app/features/onboarding_auth/presentation/models/registration_draft.dart';
import 'package:rom_tracker_app/features/onboarding_auth/presentation/pages/auth_entry_page.dart';
import 'package:rom_tracker_app/features/onboarding_auth/presentation/pages/data_review_page.dart';
import 'package:rom_tracker_app/features/onboarding_auth/presentation/pages/doctor_rejection_page.dart';
import 'package:rom_tracker_app/features/onboarding_auth/presentation/pages/forget_password_page.dart';
import 'package:rom_tracker_app/features/payment_wallet/presentation/models/doctor_wallet_store.dart';
import 'package:rom_tracker_app/features/notifications/presentation/models/notification_store.dart';
import 'package:rom_tracker_app/features/sessions/presentation/models/booking_store.dart';
import 'package:rom_tracker_app/features/sessions/presentation/models/doctor_session_store.dart';
import 'package:rom_tracker_app/features/user_profile/presentation/models/user_profile_store.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  static final _emailRegex =
      RegExp(r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$');

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _hasError = false;
  String? _errorText;
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 40.h),
                Center(
                  child: Text(
                    'Welcome back',
                    style: GoogleFonts.inter(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF242424),
                    ),
                  ),
                ),
                SizedBox(height: 8.h),
                Center(
                  child: Text(
                    'Login your account to access valuable',
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      color: const Color(0xFF828282),
                    ),
                  ),
                ),
                SizedBox(height: 18.h),
                Center(
                  child: SizedBox(
                    height: 132.h,
                    child: Image.asset(
                      AppAssets.loginArt,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                SizedBox(height: 26.h),
                Text(
                  'Email',
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 8.h),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  inputFormatters: [
                    FilteringTextInputFormatter.deny(RegExp(r'\s')),
                  ],
                  decoration: _inputDecoration('Enter your Email'),
                  validator: (value) {
                    final email = value?.trim() ?? '';
                    if (!_emailRegex.hasMatch(email)) {
                      return 'Enter a valid email';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 18.h),
                Text(
                  'Password',
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 8.h),
                TextFormField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  decoration: _inputDecoration(
                    'Enter your Password',
                    isPassword: true,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().length < 6) {
                      return 'At least 6 characters';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 2.h),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ForgetPasswordPage(),
                        ),
                      );
                    },
                    child: Text(
                      'Forget Password?',
                      style: GoogleFonts.inter(
                        fontSize: 13.sp,
                        color: const Color(0xFF4E4E4E),
                      ),
                    ),
                  ),
                ),
                if (_hasError)
                  Padding(
                    padding: EdgeInsets.only(bottom: 8.h),
                    child: Text(
                      _errorText ?? 'Wrong email or password',
                      style: GoogleFonts.inter(
                        color: AppColors.error,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                SizedBox(height: 18.h),
                SizedBox(
                  width: double.infinity,
                  height: 40.h,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                    ),
                    child: _isSubmitting
                        ? SizedBox(
                            width: 20.w,
                            height: 20.w,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            'Login',
                            style: GoogleFonts.inter(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
                SizedBox(height: 28.h),
                Row(
                  children: [
                    const Expanded(child: Divider(color: Color(0xFFB9B9B9))),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Text(
                        'or',
                        style: GoogleFonts.inter(
                          fontSize: 16.sp,
                          color: const Color(0xFF666666),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Expanded(child: Divider(color: Color(0xFFB9B9B9))),
                  ],
                ),
                SizedBox(height: 28.h),
                Center(
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 16.w,
                    runSpacing: 12.h,
                    children: [
                      _SocialButton(
                        assetPath: AppAssets.googleIcon,
                        onTap: () => _showSocialMessage('Google'),
                      ),
                      _SocialButton(
                        assetPath: AppAssets.facebookIcon,
                        onTap: () => _showSocialMessage('Facebook'),
                      ),
                      _SocialButton(
                        assetPath: AppAssets.appleIcon,
                        onTap: () => _showSocialMessage('Apple'),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24.h),
                Center(
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        'Don\'t have account ? ',
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          color: const Color(0xFF707070),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AuthEntryPage(),
                            ),
                          );
                        },
                        child: Text(
                          'Sign Up',
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 18.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(14.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: Text(
                    'Demo:\npatient@app.com / 123456\ndoctor@app.com / 123456\npending@app.com / 123456\nrejected@app.com / 123456',
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ),
                SizedBox(height: 22.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    setState(() {
      _hasError = false;
      _errorText = null;
    });

    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    final localResult = MockAuthService.login(
      email: email,
      password: password,
    );

    if (localResult != null &&
        localResult.userType == 'Doctor' &&
        localResult.status != 'approved') {
      _resetAppSession();
      _continueWithAuthResult(localResult);
      return;
    }

    setState(() => _isSubmitting = true);

    final backendResult = await BackendAuthApi.instance.login(
      LoginRequest(
        email: email,
        password: password,
      ),
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (backendResult.isFailure) {
      setState(() {
        _hasError = true;
        _errorText =
            backendResult.failure?.message ?? 'Wrong email or password';
      });
      return;
    }

    final session = backendResult.data!;
    final user = session.user;
    final role = (user['role'] ?? '').toString().toLowerCase();
    final status = (user['approvalStatus'] ?? 'approved').toString();
    final userType = role == 'doctor' ? 'Doctor' : 'Patient';

    _resetAppSession();
    AuthSessionStore.setSession(
      token: session.accessToken,
      resolvedUserType: userType,
      resolvedApprovalStatus: status,
    );
    UserProfileStore.setFromBackendUser(user);

    _continueWithAuthResult(
      MockAuthResult(
        userType: userType,
        status: status,
      ),
    );
  }

  void _resetAppSession() {
    AuthSessionStore.clear();
    BookingStore.reset();
    DoctorSessionStore.reset();
    NotificationStore.reset();
    DoctorWalletStore.reset();
    UserProfileStore.reset();
  }

  void _continueWithAuthResult(MockAuthResult result) {
    if (result.userType == 'Doctor' && result.status == 'pending') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => DataReviewPage(
            draft: const RegistrationDraft(userType: 'Doctor'),
          ),
        ),
      );
      return;
    }

    if (result.userType == 'Doctor' && result.status == 'rejected') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DoctorRejectionPage()),
      );
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => MainLayout(userType: result.userType),
      ),
    );
  }

  void _showSocialMessage(String provider) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$provider sign in is not connected yet')),
    );
  }

  InputDecoration _inputDecoration(
    String hint, {
    bool isPassword = false,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.inter(
        color: const Color(0xFF8C8C8C),
        fontSize: 14.sp,
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      suffixIcon: isPassword
          ? IconButton(
              icon: const Icon(
                Icons.visibility_outlined,
                color: Color(0xFF9A9A9A),
              ),
              onPressed: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              },
            )
          : null,
      filled: false,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),
        borderSide: const BorderSide(color: Color(0xFF9E9E9E)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),
        borderSide: const BorderSide(color: Color(0xFF9E9E9E)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),
        borderSide: const BorderSide(color: AppColors.primary),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.assetPath,
    required this.onTap,
  });

  final String assetPath;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999.r),
        child: Container(
          width: 52.w,
          height: 52.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFD4D4D4)),
          ),
          child: Center(
            child: Image.asset(
              assetPath,
              width: 24.w,
              height: 24.w,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}

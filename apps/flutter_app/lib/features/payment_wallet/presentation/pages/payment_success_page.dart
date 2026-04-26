import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rom_tracker_app/core/constants/app_colors.dart';
import 'package:rom_tracker_app/features/home/presentation/pages/main_layout.dart';

class PaymentSuccessPage extends StatelessWidget {
  const PaymentSuccessPage({
    super.key,
    this.userType = 'Patient',
  });

  final String userType;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0x80000000),
      body: SafeArea(
        child: Center(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 36.w),
            padding: EdgeInsets.symmetric(horizontal: 26.w, vertical: 28.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 28,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  top: 18.h,
                  left: 22.w,
                  child: _dot(10.w, const Color(0xFFA9C2FF)),
                ),
                Positioned(
                  top: 30.h,
                  right: 26.w,
                  child: _dot(12.w, const Color(0xFFA9C2FF)),
                ),
                Positioned(
                  bottom: 86.h,
                  left: 34.w,
                  child: _dot(8.w, const Color(0xFFA9C2FF)),
                ),
                Positioned(
                  bottom: 76.h,
                  right: 14.w,
                  child: _dot(7.w, const Color(0xFFA9C2FF)),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 86.w,
                      height: 86.w,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.check_rounded,
                          color: Colors.white, size: 48.sp),
                    ),
                    SizedBox(height: 18.h),
                    Text(
                      'Payment done successfully.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 22.h),
                    SizedBox(
                      width: double.infinity,
                      height: 50.h,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (_) => MainLayout(
                                userType: userType,
                                initialIndex: 1,
                              ),
                            ),
                            (route) => false,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14.r),
                          ),
                        ),
                        child: Text(
                          'Go to Sessions',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _dot(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}

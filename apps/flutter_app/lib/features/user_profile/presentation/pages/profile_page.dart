import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rom_tracker_app/features/home/presentation/pages/main_layout.dart';
import 'package:rom_tracker_app/features/payment_wallet/presentation/pages/doctor_wallet_page.dart';
import 'package:rom_tracker_app/features/payment_wallet/presentation/pages/payment_methods_page.dart';
import 'package:rom_tracker_app/features/user_profile/presentation/models/user_profile_data.dart';
import 'package:rom_tracker_app/features/user_profile/presentation/models/user_profile_store.dart';
import 'package:rom_tracker_app/features/user_profile/presentation/pages/edit_profile_page.dart';
import 'package:rom_tracker_app/features/user_profile/presentation/pages/logout_dialog_page.dart';
import 'package:rom_tracker_app/features/user_profile/presentation/pages/reviews_page.dart';
import 'package:rom_tracker_app/features/user_profile/presentation/pages/settings_page.dart';
import 'package:rom_tracker_app/features/user_profile/presentation/pages/wishlist_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({
    super.key,
    required this.userType,
  });

  final String userType;

  @override
  Widget build(BuildContext context) {
    final isDoctor = userType == 'Doctor';
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ValueListenableBuilder<UserProfileData>(
          valueListenable: UserProfileStore.notifierFor(userType),
          builder: (context, profile, _) {
            final displayName =
                isDoctor ? 'Dr ${profile.fullName}' : profile.fullName;
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                children: [
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MainLayout(
                                userType: userType,
                                initialIndex: 0,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.arrow_back),
                      ),
                      Expanded(
                        child: Text(
                          'Profile',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      SizedBox(width: 48.w),
                    ],
                  ),
                  SizedBox(height: 18.h),
                  Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 116.w,
                        height: 116.w,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFE7EEF7),
                        ),
                      ),
                      SizedBox(
                        width: 122.w,
                        height: 122.w,
                        child: CircularProgressIndicator(
                          value: 0.72,
                          strokeWidth: 9.w,
                          backgroundColor: Colors.transparent,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFF2759C8),
                          ),
                        ),
                      ),
                      ClipOval(
                        child: Image.asset(
                          profile.avatarPath,
                          width: 98.w,
                          height: 98.w,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        right: 6.w,
                        bottom: 6.h,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => EditProfilePage(
                                  userType: userType,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            width: 34.w,
                            height: 34.w,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFFD6E0EE),
                              ),
                            ),
                            child: Icon(
                              Icons.edit_outlined,
                              size: 18.sp,
                              color: const Color(0xFF5A6C8D),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 14.h),
                  Text(
                    displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 21.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    profile.email,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  SizedBox(height: 26.h),
                  _ProfileTile(
                    icon: Icons.person_outline,
                    title: 'Edit profile',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EditProfilePage(userType: userType),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 12.h),
                  _ProfileTile(
                    icon: Icons.account_balance_wallet_outlined,
                    title: 'Wallet',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => isDoctor
                              ? const DoctorWalletPage()
                              : const PaymentMethodsPage(),
                        ),
                      );
                    },
                  ),
                  if (!isDoctor) ...[
                    SizedBox(height: 12.h),
                    _ProfileTile(
                      icon: Icons.favorite_border_rounded,
                      title: 'Wishlist',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const WishlistPage(),
                          ),
                        );
                      },
                    ),
                  ],
                  SizedBox(height: 12.h),
                  _ProfileTile(
                    icon: Icons.settings_outlined,
                    title: 'Settings',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SettingsPage(userType: userType),
                        ),
                      );
                    },
                  ),
                  if (!isDoctor) ...[
                    SizedBox(height: 12.h),
                    _ProfileTile(
                      icon: Icons.reviews_outlined,
                      title: 'Reviews',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ReviewsPage(),
                          ),
                        );
                      },
                    ),
                  ],
                  SizedBox(height: 12.h),
                  _ProfileTile(
                    icon: Icons.logout,
                    title: 'Log out',
                    iconColor: const Color(0xFFEF4444),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => LogoutDialogPage(
                            userType: userType,
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 18.h),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

}

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({
    required this.icon,
    required this.title,
    this.onTap,
    this.iconColor,
  });

  final IconData icon;
  final String title;
  final VoidCallback? onTap;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18.r),
      onTap: onTap,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      overlayColor: const MaterialStatePropertyAll(Colors.transparent),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 18.h),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F6FB),
          borderRadius: BorderRadius.circular(18.r),
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor ?? Colors.black87),
            SizedBox(width: 14.w),
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 16),
          ],
        ),
      ),
    );
  }
}

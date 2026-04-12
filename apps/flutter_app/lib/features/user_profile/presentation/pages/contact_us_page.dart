import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rom_tracker_app/core/constants/app_assets.dart';
import 'package:rom_tracker_app/core/widgets/profile_section_navigation_bar.dart';

class ContactUsPage extends StatelessWidget {
  const ContactUsPage({
    super.key,
    required this.userType,
  });

  final String userType;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Contact us',
          style: GoogleFonts.inter(
            color: Colors.black,
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      bottomNavigationBar: ProfileSectionNavigationBar(userType: userType),
      body: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          children: [
            SizedBox(height: 10.h),
            _contactTile(
              context,
              title: 'Contact us via WhatsApp',
              iconPath: AppAssets.whatsappIcon,
            ),
            SizedBox(height: 14.h),
            _contactTile(
              context,
              title: 'Contact us via Facebook',
              iconPath: AppAssets.facebookColorIcon,
            ),
            SizedBox(height: 14.h),
            _contactTile(
              context,
              title: 'Contact us via Instagram',
              iconPath: AppAssets.instagramColorIcon,
            ),
          ],
        ),
      ),
    );
  }

  Widget _contactTile(
    BuildContext context, {
    required String title,
    required String iconPath,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16.r),
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$title is not available yet')),
        );
      },
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      overlayColor: const MaterialStatePropertyAll(Colors.transparent),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 30.w,
              height: 30.w,
              child: SvgPicture.asset(
                iconPath,
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(width: 14.w),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

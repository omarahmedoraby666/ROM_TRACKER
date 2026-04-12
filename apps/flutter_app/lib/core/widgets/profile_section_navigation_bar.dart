import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rom_tracker_app/core/constants/app_colors.dart';
import 'package:rom_tracker_app/features/home/presentation/pages/main_layout.dart';

class ProfileSectionNavigationBar extends StatelessWidget {
  const ProfileSectionNavigationBar({
    super.key,
    required this.userType,
  });

  final String userType;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: 3,
      onDestinationSelected: (index) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => MainLayout(
              userType: userType,
              initialIndex: index,
            ),
          ),
          (route) => false,
        );
      },
      height: 78.h,
      backgroundColor: Colors.white,
      indicatorColor: const Color(0xFFE8F0FF),
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home_rounded, color: AppColors.primary),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.calendar_month_outlined),
          selectedIcon:
              Icon(Icons.calendar_month_rounded, color: AppColors.primary),
          label: 'Sessions',
        ),
        NavigationDestination(
          icon: Icon(Icons.chat_bubble_outline),
          selectedIcon:
              Icon(Icons.chat_bubble_rounded, color: AppColors.primary),
          label: 'Chat',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person, color: AppColors.primary),
          label: 'Profile',
        ),
      ],
    );
  }
}

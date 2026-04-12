import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rom_tracker_app/core/constants/app_colors.dart';
import 'package:rom_tracker_app/features/chat/presentation/pages/chat_list_page.dart';
import 'package:rom_tracker_app/features/home/presentation/pages/doctor_home_page.dart';
import 'package:rom_tracker_app/features/home/presentation/pages/doctor_sessions_page.dart';
import 'package:rom_tracker_app/features/home/presentation/pages/home_page.dart';
import 'package:rom_tracker_app/features/sessions/presentation/pages/sessions_page.dart';
import 'package:rom_tracker_app/features/user_profile/presentation/pages/profile_page.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({
    super.key,
    required this.userType,
    this.initialIndex = 0,
  });

  final String userType;
  final int initialIndex;

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      widget.userType == 'Doctor'
          ? const DoctorHomePage()
          : const HomePage(),
      widget.userType == 'Doctor'
          ? const DoctorSessionsPage()
          : SessionsPage(userType: widget.userType),
      ChatListPage(userType: widget.userType),
      ProfilePage(userType: widget.userType),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
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
      ),
    );
  }
}

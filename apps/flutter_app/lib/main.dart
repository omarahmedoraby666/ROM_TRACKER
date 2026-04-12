import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rom_tracker_app/core/theme/app_theme.dart';
import 'package:rom_tracker_app/features/onboarding_auth/presentation/pages/splash_screen.dart';

void main() {
  runApp(const RomTrackerApp());
}

class RomTrackerApp extends StatelessWidget {
  const RomTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'ROM Tracker',
          theme: AppTheme.lightTheme,
          builder: (context, appChild) {
            final mediaQuery = MediaQuery.of(context);
            return MediaQuery(
              data: mediaQuery.copyWith(
                textScaler: const TextScaler.linear(1),
              ),
              child: appChild ?? const SizedBox.shrink(),
            );
          },
          home: const SplashScreen(),
        );
      },
    );
  }
}

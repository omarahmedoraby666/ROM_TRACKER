import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class AppSearchBar extends StatelessWidget {
  const AppSearchBar({
    super.key,
    this.controller,
    this.hintText = 'Search',
    this.onChanged,
    this.onTap,
    this.onMicTap,
    this.readOnly = false,
    this.showMic = true,
  });

  final TextEditingController? controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final VoidCallback? onMicTap;
  final bool readOnly;
  final bool showMic;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52.h,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFCCD5E1)),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        onChanged: onChanged,
        onTap: onTap,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: GoogleFonts.inter(
            color: const Color(0xFF94A3B8),
          ),
          border: InputBorder.none,
          contentPadding:
              EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: Color(0xFF94A3B8),
          ),
          suffixIcon: showMic
              ? IconButton(
                  style: ButtonStyle(
                    overlayColor:
                        const MaterialStatePropertyAll(Colors.transparent),
                    splashFactory: NoSplash.splashFactory,
                  ),
                  icon: const Icon(
                    Icons.mic_none_rounded,
                    color: Color(0xFF94A3B8),
                  ),
                  onPressed: onMicTap ??
                      () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Voice search is not available yet'),
                          ),
                        );
                      },
                )
              : null,
        ),
      ),
    );
  }
}

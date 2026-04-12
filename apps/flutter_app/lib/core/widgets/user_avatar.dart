import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    required this.name,
    this.radius = 24,
    this.backgroundColor,
  });

  final String name;
  final double radius;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final initials = _initials(name);
    final color = backgroundColor ?? _colorForName(name);

    return CircleAvatar(
      radius: radius.r,
      backgroundColor: color,
      child: Text(
        initials,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: (radius * 0.7).sp,
        ),
      ),
    );
  }

  String _initials(String value) {
    final parts = value.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'U';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  Color _colorForName(String value) {
    const palette = [
      Color(0xFF4F46E5),
      Color(0xFF0F766E),
      Color(0xFF1D4ED8),
      Color(0xFF7C3AED),
      Color(0xFFBE185D),
      Color(0xFF2563EB),
    ];
    final index = value.runes.fold<int>(0, (sum, rune) => sum + rune) %
        palette.length;
    return palette[index];
  }
}

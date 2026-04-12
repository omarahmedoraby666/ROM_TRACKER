import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class CameraPage extends StatelessWidget {
  const CameraPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2E2A28),
      body: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF5F554D),
                    const Color(0xFF2E2A28),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: CustomPaint(
                painter: _CameraGuidePainter(),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _circleButton(Icons.grid_view_rounded),
                      _circleButton(Icons.pause_rounded),
                    ],
                  ),
                  SizedBox(height: 18.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      _ExerciseTab(title: 'Stretching', active: false),
                      _ExerciseTab(title: 'Physio', active: true),
                      _ExerciseTab(title: 'Treadmill', active: false),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 18.h, horizontal: 22.w),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(18.r),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Text(
                      'Raise your left leg slowly',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _circleButton(IconData icon) {
    return Container(
      width: 42.w,
      height: 42.w,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white24),
      ),
      child: Icon(icon, color: Colors.white),
    );
  }
}

class _ExerciseTab extends StatelessWidget {
  const _ExerciseTab({
    required this.title,
    required this.active,
  });

  final String title;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 6.w),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: active ? const Color(0xFFBFDFFF) : Colors.white.withOpacity(0.14),
        borderRadius: BorderRadius.circular(18.r),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.accessibility_new_rounded,
            color: active ? Colors.black : Colors.white,
          ),
          SizedBox(height: 6.h),
          Text(
            title,
            style: GoogleFonts.inter(
              color: active ? Colors.black : Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _CameraGuidePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final dashed = Paint()
      ..color = Colors.white70
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final path = Path()
      ..moveTo(size.width * 0.22, size.height * 0.78)
      ..quadraticBezierTo(
        size.width * 0.26,
        size.height * 0.62,
        size.width * 0.42,
        size.height * 0.64,
      )
      ..quadraticBezierTo(
        size.width * 0.56,
        size.height * 0.66,
        size.width * 0.62,
        size.height * 0.82,
      );

    _drawDashedPath(canvas, path, dashed);

    final arrowPaint = Paint()
      ..color = Colors.white70
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(size.width * 0.36, size.height * 0.58),
      Offset(size.width * 0.48, size.height * 0.5),
      arrowPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.45, size.height * 0.47),
      Offset(size.width * 0.48, size.height * 0.5),
      arrowPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.42, size.height * 0.54),
      Offset(size.width * 0.48, size.height * 0.5),
      arrowPaint,
    );
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    for (final metric in path.computeMetrics()) {
      double distance = 0;
      const dashLength = 12.0;
      const gapLength = 8.0;
      while (distance < metric.length) {
        final next = distance + dashLength;
        canvas.drawPath(metric.extractPath(distance, next), paint);
        distance = next + gapLength;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

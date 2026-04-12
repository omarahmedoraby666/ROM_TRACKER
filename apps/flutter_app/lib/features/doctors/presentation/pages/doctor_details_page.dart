import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rom_tracker_app/core/constants/app_colors.dart';
import 'package:rom_tracker_app/features/doctors/presentation/models/doctor_profile.dart';
import 'package:rom_tracker_app/features/doctors/presentation/pages/patient_details_page.dart';
import 'package:rom_tracker_app/features/sessions/presentation/models/patient_booking.dart';

class DoctorDetailsPage extends StatefulWidget {
  const DoctorDetailsPage({
    super.key,
    required this.doctor,
  });

  final DoctorProfile doctor;

  @override
  State<DoctorDetailsPage> createState() => _DoctorDetailsPageState();
}

class _DoctorDetailsPageState extends State<DoctorDetailsPage> {
  int _selectedDay = 0;
  int _selectedPeriod = 0;
  int _selectedTime = 0;

  static const _days = [
    ('WED', '15'),
    ('THUS', '16'),
    ('FRI', '17'),
    ('SAT', '18'),
    ('SUN', '19'),
    ('MON', '20'),
  ];

  static const _periods = ['Morning', 'Afternoon', 'Evening'];

  static const _times = [
    '7:00AM',
    '8:00AM',
    '9:00AM',
    '10:00AM',
    '11:00AM',
    '12:00AM',
  ];

  @override
  Widget build(BuildContext context) {
    final doctor = widget.doctor;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Doctor Detail',
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF272727),
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(14.w, 8.h, 14.w, 24.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F4FA),
                  borderRadius: BorderRadius.circular(18.r),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14.r),
                      child: Image.asset(
                        doctor.imagePath,
                        width: 96.w,
                        height: 82.h,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            doctor.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF2B2B2B),
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            doctor.specialty,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 13.sp,
                              color: const Color(0xFF7A7A7A),
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            'years of experience +${doctor.experienceYears}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 13.sp,
                              color: const Color(0xFF7A7A7A),
                            ),
                          ),
                          SizedBox(height: 6.h),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on_outlined,
                                size: 16,
                                color: Color(0xFF6D6D6D),
                              ),
                              SizedBox(width: 4.w),
                              Expanded(
                            child: Text(
                              'Active Care Physiotherapy Center Cairo',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                fontSize: 11.5.sp,
                                color: const Color(0xFF6D6D6D),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                'personal Bio',
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF2C2C2C),
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                doctor.bio,
                style: GoogleFonts.inter(
                  fontSize: 13.sp,
                  height: 1.45,
                  color: const Color(0xFF7A7A7A),
                ),
              ),
              SizedBox(height: 18.h),
              Text(
                'Make an Appointment',
                style: GoogleFonts.inter(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF2C2C2C),
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                'June2026',
                style: GoogleFonts.inter(
                  fontSize: 13.sp,
                  color: const Color(0xFF4A4A4A),
                ),
              ),
              SizedBox(height: 10.h),
              SizedBox(
                height: 64.h,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _days.length,
                  separatorBuilder: (_, __) => SizedBox(width: 8.w),
                  itemBuilder: (context, index) {
                    final selected = _selectedDay == index;
                    final day = _days[index];
                    return GestureDetector(
                      onTap: () => setState(() => _selectedDay = index),
                      child: Container(
                        width: 48.w,
                        decoration: BoxDecoration(
                          color: selected
                              ? const Color(0xFF94F56A)
                              : const Color(0xFFF3F4F7),
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              day.$1,
                              style: GoogleFonts.inter(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF535353),
                              ),
                            ),
                            SizedBox(height: 6.h),
                            Text(
                              day.$2,
                              style: GoogleFonts.inter(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF2D2D2D),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                'Choose Time',
                style: GoogleFonts.inter(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF2C2C2C),
                ),
              ),
              SizedBox(height: 12.h),
              Row(
                children: List.generate(
                  _periods.length,
                  (index) {
                    final selected = _selectedPeriod == index;
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(right: index == 2 ? 0 : 8.w),
                        child: InkWell(
                          onTap: () => setState(() => _selectedPeriod = index),
                          borderRadius: BorderRadius.circular(22.r),
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          overlayColor:
                              const MaterialStatePropertyAll(Colors.transparent),
                          child: Container(
                            height: 38.h,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(22.r),
                              border: Border.all(
                                color: selected
                                    ? AppColors.primary
                                    : const Color(0xFFE2E6ED),
                              ),
                            ),
                            child: Text(
                              _periods[index],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF2C2C2C),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 12.h),
              Wrap(
                spacing: 10.w,
                runSpacing: 10.h,
                children: List.generate(
                  _times.length,
                  (index) {
                    final selected = _selectedTime == index;
                    return InkWell(
                      onTap: () => setState(() => _selectedTime = index),
                      borderRadius: BorderRadius.circular(20.r),
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      overlayColor:
                          const MaterialStatePropertyAll(Colors.transparent),
                      child: Container(
                        width: 98.w,
                        height: 38.h,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: selected
                              ? const Color(0xFFB9F28D)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(
                            color: selected
                                ? const Color(0xFFB9F28D)
                                : const Color(0xFFE3E5EA),
                          ),
                        ),
                        child: Text(
                          _times[index],
                          style: GoogleFonts.inter(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF3C3C3C),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                'Session Price',
                style: GoogleFonts.inter(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF2C2C2C),
                ),
              ),
              SizedBox(height: 8.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 18.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F4FA),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Text(
                  '${doctor.sessionPrice} per session',
                  style: GoogleFonts.inter(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF4A4A4A),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                'Reason For Visit',
                style: GoogleFonts.inter(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF2C2C2C),
                ),
              ),
              SizedBox(height: 8.h),
              TextField(
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Type Here....',
                  filled: true,
                  fillColor: const Color(0xFFF5F6F8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.r),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.r),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: 24.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PatientDetailsPage(
                          booking: PatientBooking(
                            doctorName: doctor.name,
                            specialty: doctor.specialty,
                            imagePath: doctor.imagePath,
                            dayLabel: _days[_selectedDay].$1,
                            dayNumber: _days[_selectedDay].$2,
                            timeLabel: _times[_selectedTime],
                            reason: '',
                          ),
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    minimumSize: Size(double.infinity, 54.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                  ),
                  child: Text(
                    'Book Now',
                    style: GoogleFonts.inter(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

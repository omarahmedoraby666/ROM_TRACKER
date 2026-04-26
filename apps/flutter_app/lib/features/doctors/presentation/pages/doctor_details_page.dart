import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rom_tracker_app/core/constants/app_colors.dart';
import 'package:rom_tracker_app/features/doctors/data/backend_doctors_api.dart';
import 'package:rom_tracker_app/features/doctors/presentation/models/doctor_profile.dart';
import 'package:rom_tracker_app/features/doctors/presentation/models/doctor_slot.dart';
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
  final TextEditingController _reasonController = TextEditingController();
  List<DoctorSlot> _slots = [];
  bool _isLoadingSlots = false;
  String? _slotError;

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

  static const _monthNames = [
    '',
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  @override
  void initState() {
    super.initState();
    _loadSlots();
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _loadSlots() async {
    final doctorId = widget.doctor.id;
    if (doctorId == null || doctorId.isEmpty) return;

    setState(() {
      _isLoadingSlots = true;
      _slotError = null;
    });

    try {
      final slots = await BackendDoctorsApi.instance.fetchDoctorSlots(doctorId);
      if (!mounted) return;
      setState(() {
        _slots = slots.where((slot) => !slot.isBooked).toList();
        _selectedDay = 0;
        _selectedPeriod = 0;
        _selectedTime = 0;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _slotError = error.toString();
      });
    } finally {
      if (mounted) {
        setState(() => _isLoadingSlots = false);
      }
    }
  }

  List<DateTime> get _slotDays {
    final unique = <String, DateTime>{};
    for (final slot in _slots) {
      final scheduledAt = DateTime.tryParse(slot.scheduledAt);
      if (scheduledAt == null) continue;
      final key =
          '${scheduledAt.year}-${scheduledAt.month}-${scheduledAt.day}';
      unique.putIfAbsent(
        key,
        () => DateTime(scheduledAt.year, scheduledAt.month, scheduledAt.day),
      );
    }
    final days = unique.values.toList()
      ..sort((a, b) => a.compareTo(b));
    return days;
  }

  List<DoctorSlot> get _selectedDaySlots {
    if (_slotDays.isEmpty) return const <DoctorSlot>[];
    final safeIndex = _selectedDay.clamp(0, _slotDays.length - 1);
    final selectedDate = _slotDays[safeIndex];
    return _slots.where((slot) {
      final scheduledAt = DateTime.tryParse(slot.scheduledAt);
      if (scheduledAt == null) return false;
      return scheduledAt.year == selectedDate.year &&
          scheduledAt.month == selectedDate.month &&
          scheduledAt.day == selectedDate.day;
    }).toList();
  }

  List<DoctorSlot> get _visibleSlots {
    final slots = _selectedDaySlots;
    if (slots.isEmpty) return const <DoctorSlot>[];
    final selectedPeriod = _periods[_selectedPeriod];
    final filtered = slots.where((slot) {
      final scheduledAt = DateTime.tryParse(slot.scheduledAt);
      if (scheduledAt == null) return false;
      if (selectedPeriod == 'Morning') return scheduledAt.hour < 12;
      if (selectedPeriod == 'Afternoon') {
        return scheduledAt.hour >= 12 && scheduledAt.hour < 17;
      }
      return scheduledAt.hour >= 17;
    }).toList();
    return filtered.isEmpty ? slots : filtered;
  }

  DoctorSlot? get _selectedBackendSlot {
    if (_visibleSlots.isEmpty) return null;
    final safeIndex = _selectedTime.clamp(0, _visibleSlots.length - 1);
    return _visibleSlots[safeIndex];
  }

  String _monthLabel() {
    if (_slotDays.isEmpty) return 'June2026';
    final day = _slotDays[_selectedDay.clamp(0, _slotDays.length - 1)];
    return '${_monthNames[day.month]}${day.year}';
  }

  String _dayShortLabel(DateTime date) {
    const labels = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
    return labels[date.weekday - 1];
  }

  String _formatHourLabel(DateTime date) {
    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    final suffix = date.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute$suffix';
  }

  @override
  Widget build(BuildContext context) {
    final doctor = widget.doctor;
    final usesBackendSlots = doctor.id != null && _slotError == null;
    final selectedBackendSlot = _selectedBackendSlot;
    final days = _slotDays.isNotEmpty
        ? _slotDays
            .map((date) => (_dayShortLabel(date), '${date.day}'))
            .toList()
        : _days;
    final times = _visibleSlots.isNotEmpty
        ? _visibleSlots
            .map((slot) {
              final parsed = DateTime.tryParse(slot.scheduledAt);
              return parsed == null ? slot.displayTime : _formatHourLabel(parsed);
            })
            .toList()
        : _times;

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
                              doctor.clinicAddress?.isNotEmpty == true
                                  ? doctor.clinicAddress!
                                  : 'Active Care Physiotherapy Center Cairo',
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
                _monthLabel(),
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
                  itemCount: days.length,
                  separatorBuilder: (_, __) => SizedBox(width: 8.w),
                  itemBuilder: (context, index) {
                    final selected = _selectedDay == index;
                    final day = days[index];
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedDay = index;
                          _selectedTime = 0;
                        });
                      },
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
                          onTap: () {
                            setState(() {
                              _selectedPeriod = index;
                              _selectedTime = 0;
                            });
                          },
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
              if (_isLoadingSlots)
                const Center(child: CircularProgressIndicator())
              else if (_slotError != null)
                Padding(
                  padding: EdgeInsets.only(bottom: 10.h),
                  child: Text(
                    'Could not load live slots. Showing demo times instead.',
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      color: const Color(0xFFEF4444),
                    ),
                  ),
                )
              else if (usesBackendSlots && times.isEmpty)
                Padding(
                  padding: EdgeInsets.only(bottom: 10.h),
                  child: Text(
                    'No available slots right now for this doctor.',
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ),
              Wrap(
                spacing: 10.w,
                runSpacing: 10.h,
                children: List.generate(
                  times.length,
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
                          times[index],
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
                controller: _reasonController,
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
                  onPressed: usesBackendSlots && selectedBackendSlot == null
                      ? null
                      : () {
                          final slotDate =
                              DateTime.tryParse(selectedBackendSlot?.scheduledAt ?? '');
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PatientDetailsPage(
                                booking: PatientBooking(
                                  doctorId: doctor.id,
                                  slotId: selectedBackendSlot?.id,
                                  doctorName: doctor.name,
                                  specialty: doctor.specialty,
                                  imagePath: doctor.imagePath,
                                  dayLabel: slotDate != null
                                      ? _dayShortLabel(slotDate)
                                      : days[_selectedDay].$1,
                                  dayNumber: slotDate != null
                                      ? '${slotDate.day}'
                                      : days[_selectedDay].$2,
                                  timeLabel: slotDate != null
                                      ? _formatHourLabel(slotDate)
                                      : times[_selectedTime],
                                  reason: _reasonController.text.trim(),
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

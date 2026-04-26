import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rom_tracker_app/core/constants/app_colors.dart';
import 'package:rom_tracker_app/core/widgets/app_page_shell.dart';
import 'package:rom_tracker_app/features/payment_wallet/presentation/pages/payment_methods_page.dart';
import 'package:rom_tracker_app/features/sessions/presentation/models/patient_booking.dart';

class PatientDetailsPage extends StatefulWidget {
  const PatientDetailsPage({
    super.key,
    required this.booking,
  });

  final PatientBooking booking;

  @override
  State<PatientDetailsPage> createState() => _PatientDetailsPageState();
}

class _PatientDetailsPageState extends State<PatientDetailsPage> {
  static final _nameRegex = RegExp(r'^[A-Za-z\u0600-\u06FF ]+$');

  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _ageController = TextEditingController();
  final _problemController = TextEditingController();
  String _selectedGender = 'Male';

  @override
  void initState() {
    super.initState();
    _problemController.text = widget.booking.reason;
  }

  @override
  Widget build(BuildContext context) {
    return AppPageShell(
      title: 'Patient Details',
      subtitle:
          'Confirm the booking data before moving into payment or session confirmation.',
      onBack: () => Navigator.pop(context),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel('Full Name'),
            _buildTextField(
              controller: _fullNameController,
              hint: 'Enter patient full name',
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                  RegExp(r"[A-Za-z\u0600-\u06FF ]"),
                ),
              ],
              validator: (value) {
                final text = value?.trim() ?? '';
                if (text.isEmpty) return 'Full name is required';
                if (!_nameRegex.hasMatch(text)) return 'Letters only';
                return null;
              },
            ),
            _buildLabel('Age'),
            _buildTextField(
              controller: _ageController,
              hint: 'Enter age',
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(2),
              ],
              validator: (value) {
                final text = value?.trim() ?? '';
                if (text.isEmpty) return 'Age is required';
                final age = int.tryParse(text);
                if (age == null || age < 1 || age > 99) return 'Invalid age';
                return null;
              },
            ),
            _buildLabel('Gender'),
            Row(
              children: [
                Expanded(
                  child: _GenderOption(
                    label: 'Male',
                    selected: _selectedGender == 'Male',
                    onTap: () => setState(() => _selectedGender = 'Male'),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: _GenderOption(
                    label: 'Female',
                    selected: _selectedGender == 'Female',
                    onTap: () => setState(() => _selectedGender = 'Female'),
                  ),
                ),
              ],
            ),
            _buildLabel('Write your problem'),
            TextFormField(
              controller: _problemController,
              maxLines: 5,
              validator: (value) {
                if ((value?.trim() ?? '').isEmpty) {
                  return 'Please describe the reason for visit';
                }
                return null;
              },
              decoration: InputDecoration(
                hintText: 'Describe your symptoms or condition...',
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
            SizedBox(height: 30.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _handleBookNow,
                child: const Text('Book Now'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleBookNow() {
    if (!_formKey.currentState!.validate()) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentMethodsPage(
          booking: PatientBooking(
            doctorId: widget.booking.doctorId,
            slotId: widget.booking.slotId,
            doctorName: widget.booking.doctorName,
            specialty: widget.booking.specialty,
            imagePath: widget.booking.imagePath,
            dayLabel: widget.booking.dayLabel,
            dayNumber: widget.booking.dayNumber,
            timeLabel: widget.booking.timeLabel,
            reason: _problemController.text.trim(),
            patientName: _fullNameController.text.trim(),
            patientAge: _ageController.text.trim(),
            patientGender: _selectedGender,
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h, top: 16.h),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    List<TextInputFormatter>? inputFormatters,
    TextInputType? keyboardType,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      decoration: InputDecoration(hintText: hint),
    );
  }
}

class _GenderOption extends StatelessWidget {
  const _GenderOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      overlayColor: const MaterialStatePropertyAll(Colors.transparent),
      child: Container(
        height: 52.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.primarySoft : Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: selected ? AppColors.primary : const Color(0xFFBEC5D1),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: selected ? AppColors.primary : const Color(0xFF3C3C3C),
          ),
        ),
      ),
    );
  }
}

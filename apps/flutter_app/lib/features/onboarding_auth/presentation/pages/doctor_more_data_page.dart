import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rom_tracker_app/core/constants/app_colors.dart';
import 'package:rom_tracker_app/core/widgets/app_page_shell.dart';
import 'package:rom_tracker_app/features/onboarding_auth/presentation/models/registration_draft.dart';
import 'package:rom_tracker_app/features/onboarding_auth/presentation/pages/data_review_page.dart';
import 'package:rom_tracker_app/features/onboarding_auth/presentation/widgets/auth_progress_bar.dart';

class DoctorMoreDataPage extends StatefulWidget {
  const DoctorMoreDataPage({
    super.key,
    required this.draft,
  });

  final RegistrationDraft draft;

  @override
  State<DoctorMoreDataPage> createState() => _DoctorMoreDataPageState();
}

class _DoctorMoreDataPageState extends State<DoctorMoreDataPage> {
  final _formKey = GlobalKey<FormState>();
  late String selectedSpecialization;
  final _universityController = TextEditingController();
  final _graduationYearController = TextEditingController();
  final _experienceController = TextEditingController();
  String? _membershipFileName;
  String? _profileFileName;

  @override
  void initState() {
    super.initState();
    selectedSpecialization = widget.draft.specialization ?? 'Physiotherapy';
    _universityController.text = widget.draft.university;
    _graduationYearController.text = widget.draft.graduationYear;
    _experienceController.text = widget.draft.yearsOfExperience;
  }

  @override
  Widget build(BuildContext context) {
    return AppPageShell(
      title: 'Professional Details',
      subtitle:
          'Add the doctor verification information and upload the required files before the account enters review.',
      onBack: () => Navigator.pop(context),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AuthProgressBar(currentStep: 4),
            SizedBox(height: 24.h),
            AppSurfaceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('Specialization'),
                  _buildDropdownField(),
                  _buildLabel('University'),
                  _buildTextField(_universityController, 'University name'),
                  _buildLabel('Graduation year'),
                  _buildTextField(
                    _graduationYearController,
                    'Year',
                    digitsOnly: true,
                    maxLength: 4,
                  ),
                  _buildLabel('Years of experience'),
                  _buildTextField(
                    _experienceController,
                    'Years',
                    digitsOnly: true,
                    maxLength: 2,
                  ),
                  SizedBox(height: 10.h),
                  _buildLabel('Union membership card'),
                  _buildUploadBox(
                    'Upload membership proof',
                    _membershipFileName,
                    () => _pickFile(isMembership: true),
                  ),
                  SizedBox(height: 14.h),
                  _buildLabel('Profile photo'),
                  _buildUploadBox(
                    'Upload profile image',
                    _profileFileName,
                    () => _pickFile(isMembership: false),
                  ),
                ],
              ),
            ),
            SizedBox(height: 22.h),
            AppPrimaryButton(
              label: 'Submit For Review',
              onPressed: () {
                if (!_formKey.currentState!.validate()) return;
                if (_membershipFileName == null || _profileFileName == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please upload both files')),
                  );
                  return;
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DataReviewPage(
                      draft: widget.draft.copyWith(
                        specialization: selectedSpecialization,
                        university: _universityController.text.trim(),
                        graduationYear: _graduationYearController.text.trim(),
                        yearsOfExperience: _experienceController.text.trim(),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h, top: 12.h),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 15.sp,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint, {
    bool digitsOnly = false,
    int? maxLength,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: digitsOnly ? TextInputType.number : TextInputType.text,
      inputFormatters: digitsOnly
          ? [
              FilteringTextInputFormatter.digitsOnly,
              if (maxLength != null) LengthLimitingTextInputFormatter(maxLength),
            ]
          : null,
      validator: (value) {
        if (value == null || value.trim().isEmpty) return 'Field required';
        return null;
      },
      decoration: InputDecoration(hintText: hint, counterText: ''),
    );
  }

  Widget _buildDropdownField() {
    return Container(
      height: 56.h,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedSpecialization,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black),
          items: const [
            'Physiotherapy',
            'Orthopedics',
            'Neurology',
            'Sports Injuries',
          ].map((value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (newValue) {
            setState(() => selectedSpecialization = newValue!);
          },
        ),
      ),
    );
  }

  Widget _buildUploadBox(
    String title,
    String? fileName,
    VoidCallback onTap,
  ) {
    return Container(
      width: double.infinity,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18.r),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 16.w),
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(18.r),
          ),
          child: Column(
            children: [
              Icon(
                Icons.cloud_upload_outlined,
                size: 40.sp,
                color: AppColors.primary,
              ),
              SizedBox(height: 8.h),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                fileName ?? 'Tap to browse or drag and drop files',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  color: fileName == null
                      ? AppColors.textSecondary
                      : AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickFile({required bool isMembership}) async {
    final result = await FilePicker.platform.pickFiles(withData: false);
    if (result == null || result.files.isEmpty) return;
    setState(() {
      if (isMembership) {
        _membershipFileName = result.files.single.name;
      } else {
        _profileFileName = result.files.single.name;
      }
    });
  }
}

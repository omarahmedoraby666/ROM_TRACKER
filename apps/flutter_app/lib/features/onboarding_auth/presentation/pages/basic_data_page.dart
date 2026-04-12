import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rom_tracker_app/core/constants/app_colors.dart';
import 'package:rom_tracker_app/core/widgets/app_page_shell.dart';
import 'package:rom_tracker_app/features/home/presentation/pages/main_layout.dart';
import 'package:rom_tracker_app/features/onboarding_auth/presentation/models/registration_draft.dart';
import 'package:rom_tracker_app/features/onboarding_auth/presentation/pages/doctor_more_data_page.dart';
import 'package:rom_tracker_app/features/onboarding_auth/presentation/widgets/auth_progress_bar.dart';

class BasicDataPage extends StatefulWidget {
  const BasicDataPage({
    super.key,
    required this.draft,
  });

  final RegistrationDraft draft;

  @override
  State<BasicDataPage> createState() => _BasicDataPageState();
}

class _BasicDataPageState extends State<BasicDataPage> {
  static final _emailRegex =
      RegExp(r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$');
  static final _nameRegex = RegExp(r'^[A-Za-z\u0600-\u06FF ]+$');
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  String _selectedCountry = 'Egypt';
  String _selectedGender = 'Male';

  @override
  void initState() {
    super.initState();
    _firstNameController.text = widget.draft.firstName;
    _lastNameController.text = widget.draft.lastName;
    _emailController.text = widget.draft.email;
    _phoneController.text = widget.draft.phone;
    _selectedCountry = widget.draft.country;
    _selectedGender = widget.draft.gender;
  }

  @override
  Widget build(BuildContext context) {
    return AppPageShell(
      title: 'Basic Information',
      subtitle:
          'Enter the essential account details. For patients this completes the account, and for doctors it leads into verification data.',
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
                  _buildLabel('First Name'),
                  _buildField(_firstNameController, 'Enter first name'),
                  _buildLabel('Last Name'),
                  _buildField(_lastNameController, 'Enter last name'),
                  _buildLabel('Email'),
                  _buildField(_emailController, 'Enter your email', isEmail: true),
                  _buildLabel('Phone'),
                  _buildPhoneField(),
                  _buildLabel('Country'),
                  _buildDropdownField(
                    value: _selectedCountry,
                    items: const ['Egypt', 'Saudi Arabia', 'UAE'],
                    onChanged: (value) => setState(() => _selectedCountry = value!),
                  ),
                  _buildLabel('Gender'),
                  _buildDropdownField(
                    value: _selectedGender,
                    items: const ['Male', 'Female'],
                    onChanged: (value) => setState(() => _selectedGender = value!),
                  ),
                ],
              ),
            ),
            SizedBox(height: 22.h),
            AppPrimaryButton(
              label: widget.draft.isPatient ? 'Create Account' : 'Next',
              onPressed: _handleNext,
            ),
          ],
        ),
      ),
    );
  }

  void _handleNext() {
    if (!_formKey.currentState!.validate()) return;

    final updatedDraft = widget.draft.copyWith(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      country: _selectedCountry,
      gender: _selectedGender,
    );

    if (updatedDraft.isPatient) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainLayout(userType: 'Patient')),
        (route) => false,
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DoctorMoreDataPage(draft: updatedDraft),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: EdgeInsets.only(top: 12.h, bottom: 8.h),
      child: Text(
        text,
        style: GoogleFonts.inter(fontSize: 15.sp, fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget _buildField(
    TextEditingController controller,
    String hint, {
    bool isEmail = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType:
          isEmail ? TextInputType.emailAddress : TextInputType.name,
      inputFormatters: isEmail
          ? [
              FilteringTextInputFormatter.deny(RegExp(r'\s')),
            ]
          : [
              FilteringTextInputFormatter.allow(
                RegExp(r"[A-Za-z\u0600-\u06FF ]"),
              ),
            ],
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Field required';
        }
        if (!isEmail && !_nameRegex.hasMatch(value.trim())) {
          return 'Letters only';
        }
        if (isEmail && !_emailRegex.hasMatch(value.trim())) {
          return 'Invalid email';
        }
        return null;
      },
      decoration: InputDecoration(hintText: hint),
    );
  }

  Widget _buildPhoneField() {
    return Row(
      children: [
        Container(
          width: 80.w,
          height: 56.h,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: const Center(child: Text('+20')),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(11),
            ],
            validator: (value) {
              final phone = value?.trim() ?? '';
              if (phone.isEmpty) return 'Field required';
              if (phone.length < 10) return 'Invalid phone number';
              return null;
            },
            decoration: const InputDecoration(hintText: '1234567891'),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      height: 56.h,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          items: items
              .map(
                (item) => DropdownMenuItem<String>(
                  value: item,
                  child: Text(item),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

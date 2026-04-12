import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rom_tracker_app/core/constants/app_colors.dart';
import 'package:rom_tracker_app/features/user_profile/presentation/models/user_profile_data.dart';
import 'package:rom_tracker_app/features/user_profile/presentation/models/user_profile_store.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({
    super.key,
    required this.userType,
  });

  final String userType;

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _clinicAddressController;
  late UserProfileData _initial;
  late String _country;
  late String _gender;
  late String _phoneCode;
  late String _specialization;

  static const _countries = ['Egypt', 'Saudi Arabia', 'UAE'];
  static const _genders = ['Male', 'Female'];
  static const _phoneCodes = ['+20', '+966', '+971'];
  static const _specializations = [
    'Physiotherapy',
    'Rehabilitation',
    'Orthopedic therapy',
  ];

  List<String> get _doctorSpecializations {
    final items = List<String>.from(_specializations);
    if (_specialization.isNotEmpty && !items.contains(_specialization)) {
      items.insert(0, _specialization);
    }
    return items;
  }

  bool get _isDoctor => widget.userType == 'Doctor';

  @override
  void initState() {
    super.initState();
    _initial = UserProfileStore.dataFor(widget.userType);
    _firstNameController = TextEditingController(text: _initial.firstName);
    _lastNameController = TextEditingController(text: _initial.lastName);
    _emailController = TextEditingController(text: _initial.email);
    _phoneController = TextEditingController(text: _initial.phoneNumber);
    _clinicAddressController =
        TextEditingController(text: _initial.clinicAddress ?? '');
    _country = _initial.country;
    _gender = _initial.gender;
    _phoneCode = _initial.phoneCode;
    _specialization = _initial.specialization ?? _specializations.first;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _clinicAddressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final displayName = _isDoctor
        ? 'Dr ${_firstNameController.text} ${_lastNameController.text}'
        : '${_firstNameController.text} ${_lastNameController.text}';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Edit profile',
          style: GoogleFonts.inter(
            color: Colors.black,
            fontWeight: FontWeight.w700,
            fontSize: 20.sp,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 12.h),
                Center(
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 118.w,
                        height: 118.w,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFE7EEF7),
                        ),
                      ),
                      SizedBox(
                        width: 124.w,
                        height: 124.w,
                        child: CircularProgressIndicator(
                          value: 0.72,
                          strokeWidth: 9.w,
                          backgroundColor: Colors.transparent,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFF2759C8),
                          ),
                        ),
                      ),
                      ClipOval(
                        child: Image.asset(
                          _initial.avatarPath,
                          width: 100.w,
                          height: 100.w,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        right: 6.w,
                        bottom: 6.h,
                        child: Container(
                          width: 34.w,
                          height: 34.w,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFFD6E0EE),
                            ),
                          ),
                          child: Icon(
                            Icons.edit_outlined,
                            size: 18.sp,
                            color: const Color(0xFF5A6C8D),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12.h),
                Center(
                  child: Text(
                    displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 21.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    _emailController.text,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ),
                SizedBox(height: 18.h),
                if (!_isDoctor) ...[
                  _label('First Name'),
                  _field(
                    controller: _firstNameController,
                    onChanged: (_) => setState(() {}),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r"[a-zA-Z\s']"),
                      ),
                    ],
                    validator: _requiredLetters,
                  ),
                  _label('Last Name'),
                  _field(
                    controller: _lastNameController,
                    onChanged: (_) => setState(() {}),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r"[a-zA-Z\s']"),
                      ),
                    ],
                    validator: _requiredLetters,
                  ),
                ] else ...[
                  _label('Specialization'),
                  _dropdownField(
                    value: _specialization,
                    items: _doctorSpecializations,
                    onChanged: (value) {
                      setState(() => _specialization = value!);
                    },
                  ),
                ],
                _label('Email'),
                _field(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (_) => setState(() {}),
                  validator: (value) {
                    final text = value?.trim() ?? '';
                    if (text.isEmpty) return 'Email is required';
                    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                    if (!emailRegex.hasMatch(text)) {
                      return 'Enter a valid email';
                    }
                    return null;
                  },
                ),
                if (_isDoctor) ...[
                  _label('Clinic Address'),
                  _field(
                    controller: _clinicAddressController,
                    validator: (value) {
                      if ((value ?? '').trim().isEmpty) {
                        return 'Clinic address is required';
                      }
                      return null;
                    },
                  ),
                ],
                _label('Phone'),
                Row(
                  children: [
                    SizedBox(
                      width: 84.w,
                      child: _dropdownField(
                        value: _phoneCode,
                        items: _phoneCodes,
                        onChanged: (value) {
                          setState(() => _phoneCode = value!);
                        },
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: _field(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[0-9 ]'),
                          ),
                        ],
                        validator: (value) {
                          final text = value?.trim() ?? '';
                          if (text.isEmpty) return 'Phone is required';
                          if (text.replaceAll(' ', '').length < 8) {
                            return 'Enter a valid phone';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                if (!_isDoctor) ...[
                  _label('Select Country'),
                  _dropdownField(
                    value: _country,
                    items: _countries,
                    onChanged: (value) => setState(() => _country = value!),
                  ),
                  _label('Gennder'),
                  _dropdownField(
                    value: _gender,
                    items: _genders,
                    onChanged: (value) => setState(() => _gender = value!),
                  ),
                ],
                SizedBox(height: 22.h),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 50.h,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF1F5F9),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                          ),
                          child: Text(
                            'Cancel',
                            style: GoogleFonts.inter(
                              color: AppColors.primary,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: SizedBox(
                        height: 50.h,
                        child: ElevatedButton(
                          onPressed: _save,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                          ),
                          child: Text(
                            'Save',
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String? _requiredLetters(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'This field is required';
    if (!RegExp(r"^[a-zA-Z\s']+$").hasMatch(text)) {
      return 'Letters only';
    }
    return null;
  }

  Widget _label(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h, top: 14.h),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 16.sp,
          fontWeight: FontWeight.w500,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    ValueChanged<String>? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
      cursorColor: AppColors.primary,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: Color(0xFFBEC5D1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: Color(0xFFBEC5D1)),
        ),
      ),
    );
  }

  Widget _dropdownField({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      isExpanded: true,
      value: value,
      focusColor: Colors.transparent,
      items: items
          .map(
            (item) => DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            ),
          )
          .toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: Color(0xFFBEC5D1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: Color(0xFFBEC5D1)),
        ),
      ),
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final updated = _initial.copyWith(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      email: _emailController.text.trim(),
      phoneCode: _phoneCode,
      phoneNumber: _phoneController.text.trim(),
      country: _country,
      gender: _gender,
      specialization: _isDoctor ? _specialization : _initial.specialization,
      clinicAddress:
          _isDoctor ? _clinicAddressController.text.trim() : _initial.clinicAddress,
    );

    UserProfileStore.update(widget.userType, updated);
    Navigator.pop(context);
  }
}

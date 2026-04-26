import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rom_tracker_app/core/constants/app_colors.dart';
import 'package:rom_tracker_app/features/payment_wallet/presentation/models/demo_payment_config.dart';
import 'package:rom_tracker_app/features/payment_wallet/presentation/pages/payment_success_page.dart';
import 'package:rom_tracker_app/features/sessions/presentation/models/local_demo_sync_store.dart';
import 'package:rom_tracker_app/features/sessions/presentation/models/patient_booking.dart';

class AddCardPage extends StatefulWidget {
  const AddCardPage({
    super.key,
    this.booking,
    required this.selectedMethod,
    required this.holderName,
  });

  final PatientBooking? booking;
  final String selectedMethod;
  final String holderName;

  @override
  State<AddCardPage> createState() => _AddCardPageState();
}

class _AddCardPageState extends State<AddCardPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _primaryController = TextEditingController();
  final _expiryController = TextEditingController();
  final _codeController = TextEditingController();
  bool _saveCard = false;
  bool _isSubmitting = false;

  DemoPaymentConfig get _config => DemoPaymentConfig.of(
        widget.selectedMethod,
        holderName: widget.holderName,
      );

  @override
  void dispose() {
    _nameController.dispose();
    _primaryController.dispose();
    _expiryController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          _config.requiresCardFields ? 'Add Card' : 'Demo Payment',
          style: GoogleFonts.inter(
            color: Colors.black,
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 24.h),
                Container(
                  height: 180.h,
                  width: double.infinity,
                  padding: EdgeInsets.all(18.w),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _config.gradient ??
                          const [Color(0xFF9C6AF1), Color(0xFF6D5EF0)],
                    ),
                    borderRadius: BorderRadius.circular(22.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _config.displayName,
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        _config.requiresCardFields
                            ? _config.secondaryValue
                            : _config.primaryValue,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 22.sp,
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        _config.requiresCardFields
                            ? 'VALID THRU ${_config.expiry}'
                            : _config.secondaryValue,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          color: Colors.white70,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 18.h),
                _DemoHintCard(config: _config),
                SizedBox(height: 24.h),
                _label(_config.requiresCardFields
                    ? 'Card Holder Name'
                    : 'Account Holder Name'),
                _field(
                  controller: _nameController,
                  hint: _config.primaryValue,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'This field is required';
                    }
                    if (_normalize(value) != _normalize(_config.primaryValue)) {
                      return 'Use the demo name shown above';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 18.h),
                _label(_config.requiresCardFields ? 'Card Number' : 'Account'),
                _field(
                  controller: _primaryController,
                  hint: _config.secondaryValue,
                  keyboardType: _config.requiresCardFields
                      ? TextInputType.number
                      : TextInputType.emailAddress,
                  inputFormatters: _config.requiresCardFields
                      ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9 ]'))]
                      : null,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'This field is required';
                    }
                    if (value.trim() != _config.secondaryValue) {
                      return _config.requiresCardFields
                          ? 'Use the demo card number shown above'
                          : 'Use the demo account shown above';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 18.h),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _label(_config.requiresCardFields
                              ? 'Expiry Date'
                              : 'Security Code'),
                          _field(
                            controller: _expiryController,
                            hint: _config.requiresCardFields
                                ? (_config.expiry ?? '')
                                : (_config.cvvOrCode ?? ''),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(_config.requiresCardFields
                                    ? r'[0-9/]'
                                    : r'[0-9]'),
                              ),
                            ],
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Required';
                              }
                              final expected = _config.requiresCardFields
                                  ? _config.expiry
                                  : _config.cvvOrCode;
                              if (value.trim() != expected) {
                                return _config.requiresCardFields
                                    ? 'Use demo expiry'
                                    : 'Use demo code';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: _config.requiresCardFields
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _label('CVV'),
                                _field(
                                  controller: _codeController,
                                  hint: _config.cvvOrCode ?? '',
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Required';
                                    }
                                    if (value.trim() != _config.cvvOrCode) {
                                      return 'Use demo CVV';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            )
                          : SizedBox(height: 88.h),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Checkbox(
                      value: _saveCard,
                      onChanged: (value) {
                        setState(() => _saveCard = value ?? false);
                      },
                    ),
                    Text(
                      'Save Card',
                      style: GoogleFonts.inter(fontSize: 14.sp),
                    ),
                  ],
                ),
                SizedBox(height: 24.h),
                SizedBox(
                  width: double.infinity,
                  height: 56.h,
                  child: ElevatedButton(
                    onPressed: _isSubmitting
                        ? null
                        : () async {
                      if (!_formKey.currentState!.validate()) return;
                      setState(() => _isSubmitting = true);
                      try {
                        if (widget.booking != null) {
                          await LocalDemoSyncStore.confirmPatientBooking(
                            widget.booking!,
                          );
                        }
                        if (!mounted) return;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PaymentSuccessPage(
                              userType: 'Patient',
                            ),
                          ),
                        );
                      } catch (error) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(error.toString())),
                        );
                      } finally {
                        if (mounted) {
                          setState(() => _isSubmitting = false);
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                    ),
                    child: _isSubmitting
                        ? SizedBox(
                            width: 20.w,
                            height: 20.w,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              'Pay now',
                              style: GoogleFonts.inter(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                  ),
                ),
                SizedBox(height: 24.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 15.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String hint,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
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

  String _normalize(String? value) {
    return (value ?? '').trim().toLowerCase();
  }
}

class _DemoHintCard extends StatelessWidget {
  const _DemoHintCard({required this.config});

  final DemoPaymentConfig config;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFD6E0EE)),
      ),
      child: Text(
        config.requiresCardFields
            ? 'Demo ${config.displayName}\nName: ${config.primaryValue}\nCard: ${config.secondaryValue}\nExpiry: ${config.expiry}\nCVV: ${config.cvvOrCode}'
            : 'Demo ${config.displayName}\nName: ${config.primaryValue}\nAccount: ${config.secondaryValue}\nCode: ${config.cvvOrCode}',
        style: GoogleFonts.inter(
          fontSize: 12.5.sp,
          height: 1.45,
          color: const Color(0xFF475569),
        ),
      ),
    );
  }
}

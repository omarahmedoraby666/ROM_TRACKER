import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rom_tracker_app/core/constants/app_colors.dart';
import 'package:rom_tracker_app/features/payment_wallet/presentation/models/demo_payment_config.dart';
import 'package:rom_tracker_app/features/payment_wallet/presentation/pages/add_card_page.dart';
import 'package:rom_tracker_app/features/payment_wallet/presentation/pages/payment_success_page.dart';
import 'package:rom_tracker_app/features/sessions/presentation/models/local_demo_sync_store.dart';
import 'package:rom_tracker_app/features/sessions/presentation/models/patient_booking.dart';
import 'package:rom_tracker_app/features/user_profile/presentation/models/user_profile_store.dart';

class PaymentMethodsPage extends StatefulWidget {
  const PaymentMethodsPage({
    super.key,
    this.booking,
  });

  final PatientBooking? booking;

  @override
  State<PaymentMethodsPage> createState() => _PaymentMethodsPageState();
}

class _PaymentMethodsPageState extends State<PaymentMethodsPage> {
  String selectedMethod = 'PayPal';

  @override
  Widget build(BuildContext context) {
    final isWalletMode = widget.booking == null;
    final holderName = UserProfileStore.patientProfile.value.fullName;
    final demo = DemoPaymentConfig.of(
      selectedMethod,
      holderName: holderName,
    );
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
          isWalletMode ? 'Wallet' : 'Payment Methods',
          style: GoogleFonts.inter(
            color: Colors.black,
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 18.h),
                  Text(
                    isWalletMode ? 'Saved Methods' : 'Select Method',
                    style: GoogleFonts.inter(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 18.h),
                  _PaymentOption(
                    label: 'PayPal',
                    brand: const _PayPalBrand(),
                    showLabel: false,
                    selected: selectedMethod == 'PayPal',
                    onTap: () => setState(() => selectedMethod = 'PayPal'),
                  ),
                  SizedBox(height: 14.h),
                  _PaymentOption(
                    label: 'VISA',
                    brand: const _VisaBrand(),
                    showLabel: false,
                    selected: selectedMethod == 'VISA',
                    onTap: () => setState(() => selectedMethod = 'VISA'),
                  ),
                  SizedBox(height: 14.h),
                  _PaymentOption(
                    label: 'Mastercard',
                    brand: const _MastercardBrand(),
                    showLabel: false,
                    selected: selectedMethod == 'Mastercard',
                    onTap: () => setState(() => selectedMethod = 'Mastercard'),
                  ),
                  SizedBox(height: 14.h),
                  _PaymentOption(
                    label: 'G Pay',
                    brand: const _GPayBrand(),
                    showLabel: false,
                    selected: selectedMethod == 'G Pay',
                    onTap: () => setState(() => selectedMethod = 'G Pay'),
                  ),
                  SizedBox(height: 18.h),
                  Text(
                    'Other',
                    style: GoogleFonts.inter(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  _PaymentOption(
                    label: 'Cash',
                    brand: const _CashBrand(),
                    selected: selectedMethod == 'Cash',
                    onTap: () => setState(() => selectedMethod = 'Cash'),
                  ),
                  SizedBox(height: 20.h),
                  _DemoMethodCard(config: demo),
                  SizedBox(height: 16.h),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(14.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Text(
                      isWalletMode
                          ? 'This wallet is view-only. Payments happen only when you book a session.'
                          : 'Use the selected demo method to complete your booking payment.',
                      style: GoogleFonts.inter(
                        fontSize: 13.sp,
                        height: 1.45,
                        color: const Color(0xFF475569),
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),
                  if (!isWalletMode) ...[
                    SizedBox(
                      width: double.infinity,
                      height: 56.h,
                      child: ElevatedButton(
                        onPressed: () {
                          if (selectedMethod != 'Cash') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AddCardPage(
                                  booking: widget.booking,
                                  selectedMethod: selectedMethod,
                                  holderName: holderName,
                                ),
                              ),
                            );
                            return;
                          }
                          if (widget.booking != null) {
                            LocalDemoSyncStore.confirmPatientBooking(
                              widget.booking!,
                            );
                          }
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const PaymentSuccessPage(
                                userType: 'Patient',
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'Confirm Payment',
                            style: GoogleFonts.inter(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                  SizedBox(height: 30.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DemoMethodCard extends StatelessWidget {
  const _DemoMethodCard({required this.config});

  final DemoPaymentConfig config;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: config.gradient ??
              const [Color(0xFFE8EEF9), Color(0xFFDCE7F6)],
        ),
        borderRadius: BorderRadius.circular(18.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Demo ${config.displayName}',
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF243B6B),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            config.requiresCardFields
                ? 'Name: ${config.primaryValue}\nCard: ${config.secondaryValue}\nExpiry: ${config.expiry}\nCVV: ${config.cvvOrCode}'
                : config.method == 'Cash'
                    ? 'Use this option as a demo cash payment with no extra details.'
                    : 'Name: ${config.primaryValue}\nAccount: ${config.secondaryValue}\nCode: ${config.cvvOrCode}',
            style: GoogleFonts.inter(
              fontSize: 12.5.sp,
              height: 1.45,
              color: const Color(0xFF324C7A),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentOption extends StatelessWidget {
  const _PaymentOption({
    required this.label,
    required this.brand,
    required this.selected,
    required this.onTap,
    this.showLabel = true,
  });

  final String label;
  final Widget brand;
  final bool selected;
  final VoidCallback onTap;
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18.r),
      onTap: onTap,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      overlayColor: const MaterialStatePropertyAll(Colors.transparent),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 18.h),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(18.r),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 112.w,
              child: Align(
                alignment: Alignment.centerLeft,
                child: brand,
              ),
            ),
            if (showLabel) ...[
              SizedBox(width: 14.w),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
            if (!showLabel) const Spacer(),
            Container(
              width: 22.w,
              height: 22.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? AppColors.primary : const Color(0xFFB8C4D7),
                  width: 1.5,
                ),
              ),
              child: selected
                  ? Padding(
                      padding: const EdgeInsets.all(3),
                      child: Container(
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _PayPalBrand extends StatelessWidget {
  const _PayPalBrand();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 84.w,
      child: Row(
        children: [
          SizedBox(
            width: 18.w,
            height: 18.w,
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  top: 0,
                  child: Text(
                    'P',
                    style: GoogleFonts.inter(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF12398E),
                    ),
                  ),
                ),
                Positioned(
                  left: 6.w,
                  top: 1.h,
                  child: Text(
                    'P',
                    style: GoogleFonts.inter(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF1BA0F2),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 6.w),
          Text(
            'PayPal',
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1B4BA3),
            ),
          ),
        ],
      ),
    );
  }
}

class _VisaBrand extends StatelessWidget {
  const _VisaBrand();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 64.w,
      child: Text(
        'VISA',
        style: GoogleFonts.inter(
          fontSize: 20.sp,
          fontWeight: FontWeight.w900,
          fontStyle: FontStyle.italic,
          color: const Color(0xFF2145AE),
          letterSpacing: -0.5,
        ),
      ),
    );
  }
}

class _MastercardBrand extends StatelessWidget {
  const _MastercardBrand();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 52.w,
      height: 24.h,
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          Positioned(
            left: 0,
            child: Container(
              width: 22.w,
              height: 22.w,
              decoration: const BoxDecoration(
                color: Color(0xFFEA001B),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            left: 12.w,
            child: Container(
              width: 22.w,
              height: 22.w,
              decoration: const BoxDecoration(
                color: Color(0xFFFFA200),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GPayBrand extends StatelessWidget {
  const _GPayBrand();

  @override
  Widget build(BuildContext context) {
    TextStyle style(Color color) => GoogleFonts.inter(
          fontSize: 18.sp,
          fontWeight: FontWeight.w700,
          color: color,
        );
    return SizedBox(
      width: 68.w,
      child: Row(
        children: [
          Text('G', style: style(const Color(0xFF4285F4))),
          Text('P', style: style(const Color(0xFF5F6368))),
          Text('a', style: style(const Color(0xFF5F6368))),
          Text('y', style: style(const Color(0xFF5F6368))),
        ],
      ),
    );
  }
}

class _CashBrand extends StatelessWidget {
  const _CashBrand();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.account_balance_wallet_outlined,
            size: 20.sp, color: const Color(0xFF7293D6)),
        SizedBox(width: 8.w),
      ],
    );
  }
}

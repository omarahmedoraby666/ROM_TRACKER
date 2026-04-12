import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rom_tracker_app/core/constants/app_colors.dart';
import 'package:rom_tracker_app/features/payment_wallet/presentation/models/doctor_wallet_store.dart';
import 'package:rom_tracker_app/features/payment_wallet/presentation/models/doctor_wallet_transaction.dart';
import 'package:rom_tracker_app/features/user_profile/presentation/models/user_profile_data.dart';
import 'package:rom_tracker_app/features/user_profile/presentation/models/user_profile_store.dart';

class DoctorWalletPage extends StatelessWidget {
  const DoctorWalletPage({super.key});

  @override
  Widget build(BuildContext context) {
    DoctorWalletStore.ensureSeeded();

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
          'Wallet',
          style: GoogleFonts.inter(
            color: Colors.black,
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: Listenable.merge([
            UserProfileStore.doctorProfile,
            DoctorWalletStore.transactions,
          ]),
          builder: (context, _) {
            final UserProfileData profile = UserProfileStore.doctorProfile.value;
            final transactions = DoctorWalletStore.transactions.value;
            final totalBalance = transactions.fold<int>(
              0,
              (sum, item) => item.status == DoctorWalletTransactionStatus.available
                  ? sum + item.amount
                  : sum,
            );

            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 18.h),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(18.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22.r),
                      border: Border.all(color: AppColors.primary, width: 2.4),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.12),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        ClipOval(
                          child: Image.asset(
                            profile.avatarPath,
                            width: 48.w,
                            height: 48.w,
                            fit: BoxFit.cover,
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Your Balance',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.inter(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                '$totalBalance EGP',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.inter(
                                  fontSize: 26.sp,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 22.h),
                  Text(
                    'My Transactions',
                    style: GoogleFonts.inter(
                      fontSize: 19.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 14.h),
                  if (transactions.isEmpty)
                    Expanded(
                      child: Center(
                        child: Text(
                          'No completed sessions yet, so no wallet transactions are available.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: ListView.separated(
                        itemCount: transactions.length,
                        separatorBuilder: (_, __) => SizedBox(height: 10.h),
                        itemBuilder: (context, index) {
                          final item = transactions[index];
                          return Container(
                            padding: EdgeInsets.all(14.w),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 42.w,
                                  height: 42.w,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  child: const Icon(
                                    Icons.south_west_rounded,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(width: 14.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.inter(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      Text(
                                        '${item.subtitle} • ${_statusLabel(item.status)}',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.inter(
                                          fontSize: 12.sp,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                Flexible(
                                  child: Text(
                                    '${_prefixFor(item.status)}${item.amount} EGP',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.end,
                                    style: GoogleFonts.inter(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w800,
                                      color: _colorFor(item.status),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  String _prefixFor(DoctorWalletTransactionStatus status) {
    switch (status) {
      case DoctorWalletTransactionStatus.pending:
        return '+';
      case DoctorWalletTransactionStatus.available:
        return '+';
      case DoctorWalletTransactionStatus.canceled:
        return '-';
    }
  }

  Color _colorFor(DoctorWalletTransactionStatus status) {
    switch (status) {
      case DoctorWalletTransactionStatus.pending:
        return const Color(0xFFF59E0B);
      case DoctorWalletTransactionStatus.available:
        return const Color(0xFF22C55E);
      case DoctorWalletTransactionStatus.canceled:
        return const Color(0xFFEF4444);
    }
  }

  String _statusLabel(DoctorWalletTransactionStatus status) {
    switch (status) {
      case DoctorWalletTransactionStatus.pending:
        return 'Pending';
      case DoctorWalletTransactionStatus.available:
        return 'Available';
      case DoctorWalletTransactionStatus.canceled:
        return 'Canceled';
    }
  }
}

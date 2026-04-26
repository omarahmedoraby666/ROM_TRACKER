import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rom_tracker_app/core/constants/app_colors.dart';
import 'package:rom_tracker_app/core/network/backend_client.dart';
import 'package:rom_tracker_app/features/chat/presentation/pages/chat_detail_page.dart';
import 'package:rom_tracker_app/features/sessions/data/backend_sessions_api.dart';
import 'package:rom_tracker_app/features/sessions/presentation/models/doctor_session_entry.dart';
import 'package:rom_tracker_app/features/sessions/presentation/models/doctor_session_store.dart';
import 'package:rom_tracker_app/features/sessions/presentation/models/local_demo_sync_store.dart';

class DoctorPatientDetailsPage extends StatefulWidget {
  const DoctorPatientDetailsPage({
    super.key,
    required this.session,
  });

  final DoctorSessionEntry session;

  @override
  State<DoctorPatientDetailsPage> createState() =>
      _DoctorPatientDetailsPageState();
}

class _DoctorPatientDetailsPageState extends State<DoctorPatientDetailsPage> {
  late final TextEditingController _notesController;

  DoctorSessionEntry get _session =>
      DoctorSessionStore.byId(widget.session.id) ?? widget.session;

  @override
  void initState() {
    super.initState();
    DoctorSessionStore.ensureSeeded();
    _notesController = TextEditingController(text: widget.session.notes);
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = _session;
    final statusText = switch (session.stage) {
      DoctorSessionStage.upcoming => 'Upcoming',
      DoctorSessionStage.completed => 'Completed',
      DoctorSessionStage.canceled => 'Canceled',
    };

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
          'Patient Details',
          style: GoogleFonts.inter(
            color: Colors.black,
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 24.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(14.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F6FB),
                  borderRadius: BorderRadius.circular(18.r),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16.r),
                      child: Image.asset(
                        session.imagePath,
                        width: 88.w,
                        height: 92.h,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            session.patientName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF2A5DC8),
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            session.condition,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 13.sp,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Row(
                            children: [
                              const Icon(
                                Icons.access_time_rounded,
                                size: 16,
                                color: Color(0xFF64748B),
                              ),
                              SizedBox(width: 4.w),
                              Expanded(
                                child: Text(
                                  session.time,
                                  style: GoogleFonts.inter(
                                    fontSize: 12.5.sp,
                                    color: const Color(0xFF475569),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8.h),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10.w,
                              vertical: 6.h,
                            ),
                            decoration: BoxDecoration(
                              color: session.stage ==
                                      DoctorSessionStage.completed
                                  ? const Color(0xFFE6FFF3)
                                  : session.stage == DoctorSessionStage.canceled
                                      ? const Color(0xFFFFECEC)
                                      : const Color(0xFFEAF2FF),
                              borderRadius: BorderRadius.circular(999.r),
                            ),
                            child: Text(
                              statusText,
                              style: GoogleFonts.inter(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w700,
                                color: session.stage ==
                                        DoctorSessionStage.completed
                                    ? const Color(0xFF16A34A)
                                    : session.stage ==
                                            DoctorSessionStage.canceled
                                        ? const Color(0xFFEF4444)
                                        : AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 18.h),
              Text(
                'Quick Actions',
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 10.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChatDetailPage(
                              userType: 'Doctor',
                              threadId: session.threadId,
                            ),
                          ),
                        );
                      },
                      child: const Text('Message'),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _handlePrimaryAction(session),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(_primaryActionLabel(session.stage)),
                      ),
                    ),
                  ),
                ],
              ),
              if (session.stage == DoctorSessionStage.upcoming) ...[
                SizedBox(height: 10.h),
                SizedBox(
                  width: double.infinity,
                      child: OutlinedButton(
                    onPressed: () async {
                      try {
                        await LocalDemoSyncStore.doctorCancelUpcoming(session.id);
                      } catch (error) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(error.toString())),
                        );
                        return;
                      }
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Session moved to canceled'),
                        ),
                      );
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFEF4444)),
                    ),
                    child: Text(
                      'Cancel Session',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        color: const Color(0xFFEF4444),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
              SizedBox(height: 18.h),
              Text(
                'Doctor Notes',
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 8.h),
              TextField(
                controller: _notesController,
                maxLines: 6,
                decoration: InputDecoration(
                  hintText: 'Write your notes for this patient...',
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
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
              SizedBox(height: 14.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (BackendClient.instance.isConfigured) {
                      final result =
                          await BackendSessionsApi.instance.updateSessionStatus(
                        sessionId: session.id,
                        status: _statusValue(session.stage),
                        doctorNotes: _notesController.text.trim(),
                      );
                      if (result.isFailure) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              result.failure?.message ?? 'Failed to save notes',
                            ),
                          ),
                        );
                        return;
                      }
                      await DoctorSessionStore.refreshFromBackend();
                    } else {
                      DoctorSessionStore.updateNotes(
                        stage: session.stage,
                        id: session.id,
                        notes: _notesController.text.trim(),
                      );
                    }
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Notes updated')),
                    );
                  },
                  child: const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text('Save Notes'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _primaryActionLabel(DoctorSessionStage stage) {
    switch (stage) {
      case DoctorSessionStage.upcoming:
        return 'Complete Session';
      case DoctorSessionStage.completed:
        return 'Restore Upcoming';
      case DoctorSessionStage.canceled:
        return 'Reschedule';
    }
  }

  void _handlePrimaryAction(DoctorSessionEntry session) {
    _handlePrimaryActionAsync(session);
  }

  Future<void> _handlePrimaryActionAsync(DoctorSessionEntry session) async {
    try {
      switch (session.stage) {
        case DoctorSessionStage.upcoming:
          await LocalDemoSyncStore.doctorCompleteUpcoming(session.id);
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Session marked as completed')),
          );
          Navigator.pop(context);
          return;
        case DoctorSessionStage.completed:
          await LocalDemoSyncStore.doctorRestoreToUpcoming(
            fromStage: DoctorSessionStage.completed,
            doctorSessionId: session.id,
          );
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Session moved back to upcoming')),
          );
          Navigator.pop(context);
          return;
        case DoctorSessionStage.canceled:
          await LocalDemoSyncStore.doctorRestoreToUpcoming(
            fromStage: DoctorSessionStage.canceled,
            doctorSessionId: session.id,
          );
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Session rescheduled to upcoming')),
          );
          Navigator.pop(context);
          return;
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    }
  }

  String _statusValue(DoctorSessionStage stage) {
    switch (stage) {
      case DoctorSessionStage.completed:
        return 'completed';
      case DoctorSessionStage.canceled:
        return 'canceled';
      case DoctorSessionStage.upcoming:
        return 'upcoming';
    }
  }
}

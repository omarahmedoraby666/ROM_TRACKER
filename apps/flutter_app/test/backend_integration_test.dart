import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:rom_tracker_app/features/doctors/data/backend_doctors_api.dart';
import 'package:rom_tracker_app/features/onboarding_auth/data/auth_contract.dart';
import 'package:rom_tracker_app/features/onboarding_auth/data/backend_auth_api.dart';
import 'package:rom_tracker_app/features/onboarding_auth/presentation/models/auth_session_store.dart';
import 'package:rom_tracker_app/features/sessions/data/backend_sessions_api.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    HttpOverrides.global = null;
  });

  tearDown(() {
    AuthSessionStore.clear();
  });

  test('backend auth, doctors, booking, and doctor sessions flow works', () async {
    final authApi = BackendAuthApi.instance;
    final doctorsApi = BackendDoctorsApi.instance;
    final sessionsApi = BackendSessionsApi.instance;

    final patientLogin = await authApi.login(
      const LoginRequest(email: 'patient@app.com', password: '123456'),
    );
    expect(patientLogin.isSuccess, isTrue, reason: patientLogin.failure?.message);

    final patientUser = patientLogin.data!.user;
    AuthSessionStore.setSession(
      token: patientLogin.data!.accessToken,
      resolvedUserType: (patientUser['role'] ?? 'patient').toString(),
      resolvedApprovalStatus: patientUser['approvalStatus']?.toString(),
    );

    final doctorsResult = await doctorsApi.getDoctors();
    expect(doctorsResult.isSuccess, isTrue, reason: doctorsResult.failure?.message);
    expect(doctorsResult.data, isNotEmpty);

    Map<String, dynamic>? chosenDoctor;
    Map<String, dynamic>? chosenSlot;
    for (final doctor in doctorsResult.data!) {
      final slotsResult = await doctorsApi.getDoctorSlots((doctor['id'] ?? '').toString());
      expect(slotsResult.isSuccess, isTrue, reason: slotsResult.failure?.message);
      final freeSlot = slotsResult.data!.cast<Map<String, dynamic>?>().firstWhere(
            (slot) => slot != null && slot['isBooked'] != true,
            orElse: () => null,
          );
      if (freeSlot != null) {
        chosenDoctor = doctor;
        chosenSlot = freeSlot;
        break;
      }
    }

    expect(chosenDoctor, isNotNull, reason: 'No doctor with a free slot was found');
    expect(chosenSlot, isNotNull, reason: 'No free slot was found');

    final bookingResult = await sessionsApi.createBooking({
      'doctorId': chosenDoctor!['id'],
      'slotId': chosenSlot!['id'],
      'reason': 'Flutter integration test booking',
      'patientAge': 28,
      'patientGender': 'Male',
    });
    expect(bookingResult.isSuccess, isTrue, reason: bookingResult.failure?.message);

    final bookingSession = Map<String, dynamic>.from(
      (bookingResult.data!['session'] as Map?) ?? const <String, dynamic>{},
    );
    final bookedSessionId = (bookingSession['id'] ?? '').toString();
    expect(bookedSessionId, isNotEmpty);

    final patientSessions = await sessionsApi.getPatientSessions();
    expect(patientSessions.isSuccess, isTrue, reason: patientSessions.failure?.message);
    expect(
      patientSessions.data!.any((item) => item['id'] == bookedSessionId),
      isTrue,
    );

    AuthSessionStore.clear();

    final doctorEmail = (chosenDoctor['email'] ?? '').toString();
    final doctorLogin = await authApi.login(
      LoginRequest(email: doctorEmail, password: '123456'),
    );
    expect(doctorLogin.isSuccess, isTrue, reason: doctorLogin.failure?.message);

    final doctorUser = doctorLogin.data!.user;
    AuthSessionStore.setSession(
      token: doctorLogin.data!.accessToken,
      resolvedUserType: (doctorUser['role'] ?? 'doctor').toString(),
      resolvedApprovalStatus: doctorUser['approvalStatus']?.toString(),
    );

    final doctorSessions = await sessionsApi.getDoctorSessions();
    expect(doctorSessions.isSuccess, isTrue, reason: doctorSessions.failure?.message);
    expect(
      doctorSessions.data!.any((item) => item['id'] == bookedSessionId),
      isTrue,
    );

    final canceled = await sessionsApi.updateSessionStatus(
      sessionId: bookedSessionId,
      status: 'canceled',
    );
    expect(canceled.isSuccess, isTrue, reason: canceled.failure?.message);
    expect(canceled.data?['session']?['status'], 'canceled');
  });
}

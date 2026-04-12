abstract final class ApiEndpoints {
  static const String login = '/auth/login';
  static const String registerPatient = '/auth/register/patient';
  static const String registerDoctor = '/auth/register/doctor';
  static const String forgotPassword = '/auth/forgot-password';
  static const String verifyOtp = '/auth/verify-otp';
  static const String resetPassword = '/auth/reset-password';

  static const String me = '/users/me';
  static const String doctors = '/doctors';
  static const String patientSessions = '/sessions/patient';
  static const String doctorSessions = '/sessions/doctor';
  static const String bookings = '/bookings';
  static const String notifications = '/notifications';
  static const String doctorWallet = '/wallet/doctor';
  static const String contactUs = '/support/contact';
  static const String search = '/search';
  static const String chatThreads = '/chat/threads';
  static const String doctorApplicationStatus = '/doctor-application/status';
  static const String wishlist = '/wishlist';

  static String doctorDetails(String doctorId) => '/doctors/$doctorId';

  static String doctorSlots(String doctorId) => '/doctors/$doctorId/slots';

  static String sessionStatus(String sessionId) =>
      '/sessions/$sessionId/status';

  static String sessionReview(String sessionId) =>
      '/sessions/$sessionId/review';

  static String sessionAiResult(String sessionId) =>
      '/sessions/$sessionId/ai-result';

  static String notificationRead(String notificationId) =>
      '/notifications/$notificationId/read';

  static String wishlistDoctor(String doctorId) => '/wishlist/$doctorId';

  static String chatMessages(String threadId) => '/chat/threads/$threadId/messages';
}

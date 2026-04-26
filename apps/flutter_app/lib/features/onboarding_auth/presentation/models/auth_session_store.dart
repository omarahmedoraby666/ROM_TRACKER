import 'package:flutter/foundation.dart';

class AuthSessionStore {
  AuthSessionStore._();

  static final ValueNotifier<String?> accessToken =
      ValueNotifier<String?>(null);
  static final ValueNotifier<String?> userType = ValueNotifier<String?>(null);
  static final ValueNotifier<String?> approvalStatus =
      ValueNotifier<String?>(null);

  static bool get isAuthenticated => accessToken.value != null;

  static void setSession({
    required String token,
    required String resolvedUserType,
    String? resolvedApprovalStatus,
  }) {
    accessToken.value = token;
    userType.value = resolvedUserType;
    approvalStatus.value = resolvedApprovalStatus;
  }

  static void clear() {
    accessToken.value = null;
    userType.value = null;
    approvalStatus.value = null;
  }
}

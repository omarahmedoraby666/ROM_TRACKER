class MockAuthResult {
  const MockAuthResult({
    required this.userType,
    this.status = 'approved',
  });

  final String userType;
  final String status;
}

class MockAuthService {
  static const Map<String, Map<String, String>> _accounts = {
    'patient@app.com': {
      'password': '123456',
      'userType': 'Patient',
      'status': 'approved',
    },
    'doctor@app.com': {
      'password': '123456',
      'userType': 'Doctor',
      'status': 'approved',
    },
    'pending@app.com': {
      'password': '123456',
      'userType': 'Doctor',
      'status': 'pending',
    },
    'rejected@app.com': {
      'password': '123456',
      'userType': 'Doctor',
      'status': 'rejected',
    },
  };

  static MockAuthResult? login({
    required String email,
    required String password,
  }) {
    final normalizedEmail = email.trim().toLowerCase();
    final account = _accounts[normalizedEmail];

    if (account == null || account['password'] != password) {
      return null;
    }

    return MockAuthResult(
      userType: account['userType']!,
      status: account['status'] ?? 'approved',
    );
  }
}

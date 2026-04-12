class IntegrationReadiness {
  const IntegrationReadiness._();

  static const requiredPackagesWhenIntegrationStarts = <String>[
    'dio',
    'flutter_secure_storage',
  ];

  static const notes = <String>[
    'Do not add networking packages until the backend base URL and first endpoints are ready.',
    'Keep the current local demo flow active until each real API replacement is tested screen by screen.',
    'The Unity AI module can be integrated later. The backend AI endpoint can be prepared now.',
  ];
}

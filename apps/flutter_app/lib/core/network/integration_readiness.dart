class IntegrationReadiness {
  const IntegrationReadiness._();

  static const requiredPackagesWhenIntegrationStarts = <String>[
    'dio',
  ];

  static const notes = <String>[
    'Backend integration is in progress for auth, doctors, slots, bookings, sessions, notifications, and wallet.',
    'Local demo fallbacks remain active on screens that are not fully migrated yet or when the backend is unavailable.',
    'The Unity AI module can be connected later on top of the existing backend AI endpoints.',
  ];
}

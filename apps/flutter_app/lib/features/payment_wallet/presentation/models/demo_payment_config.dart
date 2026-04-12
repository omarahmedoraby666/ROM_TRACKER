import 'package:flutter/material.dart';

class DemoPaymentConfig {
  const DemoPaymentConfig._({
    required this.method,
    required this.displayName,
    required this.primaryValue,
    required this.secondaryValue,
    this.expiry,
    this.cvvOrCode,
    this.requiresCardFields = true,
    this.gradient,
  });

  final String method;
  final String displayName;
  final String primaryValue;
  final String secondaryValue;
  final String? expiry;
  final String? cvvOrCode;
  final bool requiresCardFields;
  final List<Color>? gradient;

  static DemoPaymentConfig of(
    String method, {
    String holderName = 'Gamal Ali',
  }) {
    final effectiveHolderName = holderName.trim().isEmpty
        ? 'Gamal Ali'
        : holderName.trim();
    switch (method) {
      case 'PayPal':
        return DemoPaymentConfig._(
          method: 'PayPal',
          displayName: 'PayPal',
          primaryValue: effectiveHolderName,
          secondaryValue: 'demo.paypal@physixia.com',
          cvvOrCode: '2244',
          requiresCardFields: false,
          gradient: const [Color(0xFFB9D9FF), Color(0xFF75B2FF)],
        );
      case 'VISA':
        return DemoPaymentConfig._(
          method: 'VISA',
          displayName: 'Visa',
          primaryValue: effectiveHolderName,
          secondaryValue: '4242 4242 4242 4242',
          expiry: '12/30',
          cvvOrCode: '123',
          gradient: const [Color(0xFF9C6AF1), Color(0xFF6D5EF0)],
        );
      case 'Mastercard':
        return DemoPaymentConfig._(
          method: 'Mastercard',
          displayName: 'Mastercard',
          primaryValue: effectiveHolderName,
          secondaryValue: '5555 5555 5555 4444',
          expiry: '11/29',
          cvvOrCode: '456',
          gradient: const [Color(0xFFF58A7A), Color(0xFFEF5C57)],
        );
      case 'G Pay':
        return DemoPaymentConfig._(
          method: 'G Pay',
          displayName: 'Google Pay',
          primaryValue: effectiveHolderName,
          secondaryValue: 'demo.gpay@physixia.com',
          cvvOrCode: '7788',
          requiresCardFields: false,
          gradient: const [Color(0xFFD5E6FF), Color(0xFFB6D1FF)],
        );
      case 'Cash':
      default:
        return const DemoPaymentConfig._(
          method: 'Cash',
          displayName: 'Cash',
          primaryValue: 'Cash Payment',
          secondaryValue: 'No demo credentials required',
          requiresCardFields: false,
          gradient: [Color(0xFFE6EEF8), Color(0xFFD7E3F1)],
        );
    }
  }
}

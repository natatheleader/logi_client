import 'package:equatable/equatable.dart'; // Provides the Equatable mixin

class PhoneVerification extends Equatable {
  final String phoneNumber;
  final String verificationId;
  final int? resendToken;
  final DateTime expiresAt;
  final int attemptCount;

  const PhoneVerification({
    required this.phoneNumber,
    required this.verificationId,
    this.resendToken,
    required this.expiresAt,
    this.attemptCount = 0,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  bool get canResend => attemptCount < 3;

  PhoneVerification copyWith({
    String? phoneNumber,
    String? verificationId,
    int? resendToken,
    DateTime? expiresAt,
    int? attemptCount,
  }) {
    return PhoneVerification(
      phoneNumber: phoneNumber ?? this.phoneNumber,
      verificationId: verificationId ?? this.verificationId,
      resendToken: resendToken ?? this.resendToken,
      expiresAt: expiresAt ?? this.expiresAt,
      attemptCount: attemptCount ?? this.attemptCount,
    );
  }

  @override
  List<Object?> get props => [
        phoneNumber,
        verificationId,
        resendToken,
        expiresAt,
        attemptCount,
      ];
}

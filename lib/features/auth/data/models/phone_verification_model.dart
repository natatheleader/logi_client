import '../../domain/entities/phone_verification.dart';

class PhoneVerificationModel extends PhoneVerification {
  const PhoneVerificationModel({
    required super.phoneNumber,
    required super.verificationId,
    super.resendToken,
    required super.expiresAt,
    super.attemptCount,
  });

  factory PhoneVerificationModel.fromJson(Map<String, dynamic> json) {
    return PhoneVerificationModel(
      phoneNumber: json['phoneNumber'] as String,
      verificationId: json['verificationId'] as String,
      resendToken: json['resendToken'] as int?,
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      attemptCount: json['attemptCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'phoneNumber': phoneNumber,
      'verificationId': verificationId,
      'resendToken': resendToken,
      'expiresAt': expiresAt.toIso8601String(),
      'attemptCount': attemptCount,
    };
  }
}

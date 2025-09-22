part of 'phone_auth_cubit.dart';

enum PhoneAuthStatus { 
  initial, 
  loading, 
  codeSent, 
  verifying, 
  verified, 
  error 
}

class PhoneAuthState extends Equatable {
  final PhoneAuthStatus status;
  final PhoneVerification? phoneVerification;
  final User? user;
  final String? error;

  const PhoneAuthState({
    this.status = PhoneAuthStatus.initial,
    this.phoneVerification,
    this.user,
    this.error,
  });

  bool get isLoading => status == PhoneAuthStatus.loading;
  bool get isCodeSent => status == PhoneAuthStatus.codeSent;
  bool get isVerifying => status == PhoneAuthStatus.verifying;
  bool get isVerified => status == PhoneAuthStatus.verified;
  bool get hasError => status == PhoneAuthStatus.error;
  bool get canResend => phoneVerification?.canResend ?? false;

  PhoneAuthState copyWith({
    PhoneAuthStatus? status,
    PhoneVerification? phoneVerification,
    User? user,
    String? error,
  }) {
    return PhoneAuthState(
      status: status ?? this.status,
      phoneVerification: phoneVerification ?? this.phoneVerification,
      user: user ?? this.user,
      error: error,
    );
  }

  @override
  List<Object?> get props => [status, phoneVerification, user, error];
}

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/phone_verification.dart';
import '../../domain/entities/user.dart';
import '../../domain/use_cases/phone_auth_use_cases.dart';

part 'phone_auth_state.dart';

class PhoneAuthCubit extends Cubit<PhoneAuthState> {
  final InitiatePhoneVerification initiatePhoneVerification;
  final VerifyPhoneCode verifyPhoneCode;
  final ResendPhoneCode resendPhoneCode;

  PhoneAuthCubit({
    required this.initiatePhoneVerification,
    required this.verifyPhoneCode,
    required this.resendPhoneCode,
  }) : super(const PhoneAuthState());

  Future<void> sendVerificationCode(String phoneNumber) async {
    emit(state.copyWith(status: PhoneAuthStatus.loading));
    
    final result = await initiatePhoneVerification(phoneNumber);
    
    result.fold(
      (failure) => emit(state.copyWith(
        status: PhoneAuthStatus.error,
        error: failure.message,
      )),
      (verification) => emit(state.copyWith(
        status: PhoneAuthStatus.codeSent,
        phoneVerification: verification,
        error: null,
      )),
    );
  }

  Future<void> verifyCode(String code) async {
    if (state.phoneVerification == null) return;
    
    emit(state.copyWith(status: PhoneAuthStatus.verifying));
    
    final params = VerifyPhoneCodeParams(
      verificationId: state.phoneVerification!.verificationId,
      code: code,
    );
    
    final result = await verifyPhoneCode(params);
    
    result.fold(
      (failure) => emit(state.copyWith(
        status: PhoneAuthStatus.error,
        error: failure.message,
      )),
      (user) => emit(state.copyWith(
        status: PhoneAuthStatus.verified,
        user: user,
        error: null,
      )),
    );
  }

  Future<void> resendCode() async {
    if (state.phoneVerification == null) return;
    
    emit(state.copyWith(status: PhoneAuthStatus.loading));
    
    final params = ResendPhoneCodeParams(
      phoneNumber: state.phoneVerification!.phoneNumber,
      resendToken: state.phoneVerification!.resendToken,
    );
    
    final result = await resendPhoneCode(params);
    
    result.fold(
      (failure) => emit(state.copyWith(
        status: PhoneAuthStatus.error,
        error: failure.message,
      )),
      (verification) => emit(state.copyWith(
        status: PhoneAuthStatus.codeSent,
        phoneVerification: verification.copyWith(
          attemptCount: state.phoneVerification!.attemptCount + 1,
        ),
        error: null,
      )),
    );
  }

  void resetState() {
    emit(const PhoneAuthState());
  }

  void clearError() {
    emit(state.copyWith(error: null));
  }
}

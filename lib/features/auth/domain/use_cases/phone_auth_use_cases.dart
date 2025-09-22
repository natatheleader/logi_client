import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/use_cases/use_case.dart';
import '../entities/phone_verification.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class InitiatePhoneVerification implements UseCase<PhoneVerification, String> {
  final AuthRepository repository;

  InitiatePhoneVerification(this.repository);

  @override
  Future<Either<Failure, PhoneVerification>> call(String phoneNumber) async {
    // Validate phone number format
    if (phoneNumber.isEmpty || phoneNumber.length < 10) {
      return Left(ValidationFailure(message: 'Please enter a valid phone number'));
    }

    return await repository.initiatePhoneVerification(phoneNumber);
  }
}

class VerifyPhoneCodeParams {
  final String verificationId;
  final String code;

  VerifyPhoneCodeParams({
    required this.verificationId,
    required this.code,
  });
}

class VerifyPhoneCode implements UseCase<User, VerifyPhoneCodeParams> {
  final AuthRepository repository;

  VerifyPhoneCode(this.repository);

  @override
  Future<Either<Failure, User>> call(VerifyPhoneCodeParams params) async {
    if (params.code.isEmpty || params.code.length != 6) {
      return Left(ValidationFailure(message: 'Please enter a valid 6-digit code'));
    }

    return await repository.verifyPhoneCode(params.verificationId, params.code);
  }
}

class ResendPhoneCodeParams {
  final String phoneNumber;
  final int? resendToken;

  ResendPhoneCodeParams({
    required this.phoneNumber,
    this.resendToken,
  });
}

class ResendPhoneCode implements UseCase<PhoneVerification, ResendPhoneCodeParams> {
  final AuthRepository repository;

  ResendPhoneCode(this.repository);

  @override
  Future<Either<Failure, PhoneVerification>> call(ResendPhoneCodeParams params) async {
    return await repository.resendPhoneCode(params.phoneNumber, params.resendToken);
  }
}

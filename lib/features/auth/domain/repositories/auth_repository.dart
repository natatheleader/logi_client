import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user.dart';
import '../entities/auth_tokens.dart';
import '../entities/phone_verification.dart';

abstract class AuthRepository {
  // Phone Authentication
  Future<Either<Failure, PhoneVerification>> initiatePhoneVerification(String phoneNumber);
  Future<Either<Failure, User>> verifyPhoneCode(String verificationId, String code);
  Future<Either<Failure, PhoneVerification>> resendPhoneCode(String phoneNumber, int? resendToken);
  
  // Google Authentication
  Future<Either<Failure, User>> signInWithGoogle();
  
  // Guest Authentication
  Future<Either<Failure, User>> continueAsGuest();
  
  // Token Management
  Future<Either<Failure, AuthTokens>> exchangeFirebaseToken(String firebaseToken);
  Future<Either<Failure, AuthTokens>> refreshTokens(String refreshToken);
  
  // User Management
  Future<Either<Failure, User>> getCurrentUser();
  Future<Either<Failure, void>> signOut();
  Future<Either<Failure, User>> updateProfile({
    String? name,
    String? email,
    String? phone,
  });
  
  // Account Management
  Future<Either<Failure, void>> deleteAccount();
  Future<Either<Failure, User>> convertGuestToRegistered(AuthProvider provider);
}
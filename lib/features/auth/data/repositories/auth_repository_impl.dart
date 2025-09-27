import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/services/storage_service.dart';
import '../../domain/entities/auth_tokens.dart';
import '../../domain/entities/phone_verification.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../data_sources/auth_remote_data_source.dart';
import '../data_sources/firebase_auth_data_source.dart';
import '../models/user_model.dart';
import 'dart:convert';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthDataSource firebaseDataSource;
  final AuthRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;
  final StorageService storageService;

  AuthRepositoryImpl({
    required this.firebaseDataSource,
    required this.remoteDataSource,
    required this.networkInfo,
    required this.storageService,
  });

  @override
  Future<Either<Failure, PhoneVerification>> initiatePhoneVerification(
      String phoneNumber) async {
    try {
      if (!await networkInfo.isConnected) {
        return Left(NetworkFailure(message: 'No internet connection'));
      }

      final result = await firebaseDataSource.initiatePhoneVerification(phoneNumber);
      return Right(result);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on AuthenticationException catch (e) {
      return Left(AuthenticationFailure(message: e.message, code: e.statusCode));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.statusCode));
    } catch (e) {
      return Left(UnknownFailure(message: 'An unexpected error occurred: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, User>> verifyPhoneCode(String verificationId, String code) async {
    try {
      if (!await networkInfo.isConnected) {
        return Left(NetworkFailure(message: 'No internet connection'));
      }

      // Step 1: Verify with Firebase first
      final firebaseUser = await firebaseDataSource.verifyPhoneCode(verificationId, code);
      
      // Step 2: Get Firebase token
      final firebaseToken = await firebaseDataSource.getCurrentFirebaseToken();
      
      // Step 3: Exchange Firebase token for backend tokens
      final authTokens = await remoteDataSource.exchangeFirebaseToken(firebaseToken);
      
      // Step 4: Get complete user data from backend
      final backendUser = await remoteDataSource.getCurrentUser();
      
      // Step 5: Store tokens and user data
      await _storeAuthData(authTokens, backendUser);
      
      return Right(backendUser);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on AuthenticationException catch (e) {
      return Left(AuthenticationFailure(message: e.message, code: e.statusCode));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.statusCode));
    } catch (e) {
      return Left(UnknownFailure(message: 'An unexpected error occurred: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, PhoneVerification>> resendPhoneCode(
      String phoneNumber, int? resendToken) async {
    try {
      if (!await networkInfo.isConnected) {
        return Left(NetworkFailure(message: 'No internet connection'));
      }

      final result = await firebaseDataSource.resendPhoneCode(phoneNumber, resendToken);
      return Right(result);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on AuthenticationException catch (e) {
      return Left(AuthenticationFailure(message: e.message, code: e.statusCode));
    } catch (e) {
      return Left(UnknownFailure(message: 'An unexpected error occurred: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, User>> signInWithGoogle() async {
    try {
      if (!await networkInfo.isConnected) {
        return Left(NetworkFailure(message: 'No internet connection'));
      }

      // Step 1: Sign in with Firebase Google
      final firebaseUser = await firebaseDataSource.signInWithGoogle();
      
      // Step 2: Get Firebase token
      final firebaseToken = await firebaseDataSource.getCurrentFirebaseToken();
      
      // Step 3: Exchange Firebase token for backend tokens
      final authTokens = await remoteDataSource.exchangeFirebaseToken(firebaseToken);
      
      // Step 4: Get complete user data from backend
      final backendUser = await remoteDataSource.getCurrentUser();
      
      // Step 5: Store tokens and user data
      await _storeAuthData(authTokens, backendUser);
      
      return Right(backendUser);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on AuthenticationException catch (e) {
      return Left(AuthenticationFailure(message: e.message, code: e.statusCode));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.statusCode));
    } catch (e) {
      return Left(UnknownFailure(message: 'An unexpected error occurred: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, User>> continueAsGuest() async {
    try {
      // Create a guest user
      final guestUser = UserModel(
        id: 'guest_${DateTime.now().millisecondsSinceEpoch}',
        userType: UserType.guest,
        authProvider: AuthProvider.guest,
        createdAt: DateTime.now(),
      );

      // Store guest user data
      await storageService.setUserData(jsonEncode(guestUser.toJson()));
      
      return Right(guestUser);
    } catch (e) {
      return Left(UnknownFailure(message: 'Failed to continue as guest: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, AuthTokens>> exchangeFirebaseToken(String firebaseToken) async {
    try {
      if (!await networkInfo.isConnected) {
        return Left(NetworkFailure(message: 'No internet connection'));
      }

      final tokens = await remoteDataSource.exchangeFirebaseToken(firebaseToken);
      await _storeTokens(tokens);
      return Right(tokens);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on AuthenticationException catch (e) {
      return Left(AuthenticationFailure(message: e.message, code: e.statusCode));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.statusCode));
    } catch (e) {
      return Left(UnknownFailure(message: 'Token exchange failed: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, AuthTokens>> refreshTokens(String refreshToken) async {
    try {
      if (!await networkInfo.isConnected) {
        return Left(NetworkFailure(message: 'No internet connection'));
      }

      final tokens = await remoteDataSource.refreshTokens(refreshToken);
      await _storeTokens(tokens);
      return Right(tokens);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on AuthenticationException catch (e) {
      return Left(AuthenticationFailure(message: e.message, code: e.statusCode));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.statusCode));
    } catch (e) {
      return Left(UnknownFailure(message: 'Token refresh failed: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    try {
      // Check if we have a Firebase user and can get fresh data from backend
      final firebaseUser = firebaseDataSource.getCurrentFirebaseUser();
      
      if (firebaseUser != null && await networkInfo.isConnected && storageService.isLoggedIn()) {
        try {
          // We have a Firebase user and network, get fresh data from backend
          final serverUser = await remoteDataSource.getCurrentUser();
          await storageService.setUserData(jsonEncode(serverUser.toJson()));
          return Right(serverUser);
        } catch (e) {
          // If backend call fails, fall back to cached data
        }
      }
      
      // Check cached user data
      final userData = storageService.getUserData();
      if (userData != null) {
        final userJson = jsonDecode(userData);
        final user = UserModel.fromJson(userJson);
        return Right(user);
      }
      
      // No user found
      return Left(AuthenticationFailure(message: 'No user found'));
    } catch (e) {
      return Left(UnknownFailure(message: 'Failed to get user: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      // Sign out from Firebase
      await firebaseDataSource.signOut();
      
      // Clear local storage
      await storageService.clearAuthData();
      
      return Right(null);
    } catch (e) {
      return Left(UnknownFailure(message: 'Sign out failed: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, User>> updateProfile({
    String? name,
    String? email,
    String? phone,
  }) async {
    try {
      if (!await networkInfo.isConnected) {
        return Left(NetworkFailure(message: 'No internet connection'));
      }

      if (!storageService.isLoggedIn()) {
        return Left(AuthenticationFailure(message: 'User not authenticated'));
      }

      final updatedUser = await remoteDataSource.updateProfile(
        name: name,
        email: email,
        phone: phone,
      );
      
      // Update local storage
      await storageService.setUserData(jsonEncode(updatedUser.toJson()));
      
      return Right(updatedUser);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on AuthenticationException catch (e) {
      return Left(AuthenticationFailure(message: e.message, code: e.statusCode));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.statusCode));
    } catch (e) {
      return Left(UnknownFailure(message: 'Profile update failed: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAccount() async {
    try {
      if (!await networkInfo.isConnected) {
        return Left(NetworkFailure(message: 'No internet connection'));
      }

      if (!storageService.isLoggedIn()) {
        return Left(AuthenticationFailure(message: 'User not authenticated'));
      }

      await remoteDataSource.deleteAccount();
      await firebaseDataSource.signOut();
      await storageService.clearAll();
      
      return Right(null);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on AuthenticationException catch (e) {
      return Left(AuthenticationFailure(message: e.message, code: e.statusCode));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.statusCode));
    } catch (e) {
      return Left(UnknownFailure(message: 'Account deletion failed: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, User>> convertGuestToRegistered(AuthProvider provider) async {
    try {
      if (!await networkInfo.isConnected) {
        return Left(NetworkFailure(message: 'No internet connection'));
      }

      if (provider == AuthProvider.google) {
        // For Google conversion, use the signInWithGoogle method
        final result = await signInWithGoogle();
        return result.fold(
          (failure) => Left(failure),
          (user) async {
            // Clear guest data on successful conversion
            return Right(user);
          },
        );
      } else {
        return Left(ValidationFailure(message: 'Phone conversion requires separate flow'));
      }
    } catch (e) {
      return Left(UnknownFailure(message: 'Account conversion failed: ${e.toString()}'));
    }
  }

  // Private helper methods
  Future<void> _storeAuthData(AuthTokens tokens, User user) async {
    await Future.wait([
      storageService.setAccessToken(tokens.accessToken),
      storageService.setRefreshToken(tokens.refreshToken),
      storageService.setUserData(jsonEncode((user as UserModel).toJson())),
    ]);
  }

  Future<void> _storeTokens(AuthTokens tokens) async {
    await Future.wait([
      storageService.setAccessToken(tokens.accessToken),
      storageService.setRefreshToken(tokens.refreshToken),
    ]);
  }
}
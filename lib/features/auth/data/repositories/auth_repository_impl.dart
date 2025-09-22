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

      // Verify with Firebase first
      final firebaseUser = await firebaseDataSource.verifyPhoneCode(verificationId, code);
      
      // Get Firebase token and exchange for app token
      final firebaseToken = await firebaseDataSource.getCurrentFirebaseToken();
      final authTokens = await remoteDataSource.exchangeFirebaseToken(firebaseToken);
      
      // Store tokens and user data
      await _storeAuthData(authTokens, firebaseUser);
      
      return Right(firebaseUser);
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

      // Sign in with Firebase Google
      final firebaseUser = await firebaseDataSource.signInWithGoogle();
      
      // Get Firebase token and exchange for app token
      final firebaseToken = await firebaseDataSource.getCurrentFirebaseToken();
      final authTokens = await remoteDataSource.exchangeFirebaseToken(firebaseToken);
      
      // Store tokens and user data
      await _storeAuthData(authTokens, firebaseUser);
      
      return Right(firebaseUser);
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
      // First check if user is stored locally
      final userData = storageService.getUserData();
      if (userData != null) {
        final userJson = jsonDecode(userData);
        final user = UserModel.fromJson(userJson);
        
        // If it's a guest user, return directly
        if (user.isGuest) {
          return Right(user);
        }
        
        // For registered users, check if we need to refresh from server
        if (await networkInfo.isConnected && storageService.isLoggedIn()) {
          try {
            final serverUser = await remoteDataSource.getCurrentUser();
            await storageService.setUserData(jsonEncode(serverUser.toJson()));
            return Right(serverUser);
          } catch (e) {
            // Return cached user if server request fails
            return Right(user);
          }
        }
        
        return Right(user);
      }
      
      // No cached user found
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

            if (provider != AuthProvider.google) {
                return Left(ValidationFailure(message: 'Phone conversion requires separate flow'));
            }

            // Call signInWithGoogle directly and return its result.
            // Dartz's Either will handle the success or failure automatically.
            final result = await signInWithGoogle();
            
            // Clear guest data only if the conversion was successful.
            // The `.then()` call ensures this code runs only on success.
            return result.fold(
                (failure) => Left(failure),
                (user) async {
                    await storageService.clearAll();
                    return Right(user!);
                },
            );

        } on NetworkException catch (e) {
            return Left(NetworkFailure(message: e.message));
        } on AuthenticationException catch (e) {
            return Left(AuthenticationFailure(message: e.message, code: e.statusCode));
        } on ServerException catch (e) {
            return Left(ServerFailure(message: e.message, code: e.statusCode));
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
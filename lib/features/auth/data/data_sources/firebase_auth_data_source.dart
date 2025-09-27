import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import '../../../../core/error/exceptions.dart';
import '../models/phone_verification_model.dart';
import '../models/user_model.dart';
import '../../domain/entities/user.dart';
import 'dart:async';

abstract class FirebaseAuthDataSource {
  Future<PhoneVerificationModel> initiatePhoneVerification(String phoneNumber);
  Future<UserModel> verifyPhoneCode(String verificationId, String code);
  Future<PhoneVerificationModel> resendPhoneCode(String phoneNumber, int? resendToken);
  Future<UserModel> signInWithGoogle();
  Future<String> getCurrentFirebaseToken();
  firebase_auth.User? getCurrentFirebaseUser();
  Future<void> signOut();
}

class FirebaseAuthDataSourceImpl implements FirebaseAuthDataSource {
  final firebase_auth.FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  FirebaseAuthDataSourceImpl({
    firebase_auth.FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  })  : _firebaseAuth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  @override
  Future<PhoneVerificationModel> initiatePhoneVerification(String phoneNumber) async {
    try {
      final completer = Completer<PhoneVerificationModel>();
      
      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (firebase_auth.PhoneAuthCredential credential) {
          // Auto-verification completed (Android only)
        },
        verificationFailed: (firebase_auth.FirebaseAuthException e) {
          completer.completeError(
            AuthenticationException(
              message: e.message ?? 'Phone verification failed',
              statusCode: int.tryParse(e.code),
            ),
          );
        },
        codeSent: (String verificationId, int? resendToken) {
          final phoneVerification = PhoneVerificationModel(
            phoneNumber: phoneNumber,
            verificationId: verificationId,
            resendToken: resendToken,
            expiresAt: DateTime.now().add(const Duration(minutes: 5)),
          );
          completer.complete(phoneVerification);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          // Handle timeout
        },
        timeout: const Duration(seconds: 60),
      );

      return await completer.future;
    } catch (e) {
      throw AuthenticationException(
        message: 'Failed to send verification code: ${e.toString()}',
      );
    }
  }

  @override
  Future<UserModel> verifyPhoneCode(String verificationId, String code) async {
    try {
      final credential = firebase_auth.PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: code,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      
      if (userCredential.user == null) {
        throw AuthenticationException(message: 'Failed to sign in with phone');
      }

      return _mapFirebaseUserToUserModel(userCredential.user!);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw AuthenticationException(
        message: _getAuthErrorMessage(e.code),
        statusCode: int.tryParse(e.code),
      );
    } catch (e) {
      throw AuthenticationException(
        message: 'Phone verification failed: ${e.toString()}',
      );
    }
  }

  @override
  Future<PhoneVerificationModel> resendPhoneCode(String phoneNumber, int? resendToken) async {
    return await initiatePhoneVerification(phoneNumber);
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        throw AuthenticationException(message: 'Google sign in was cancelled');
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      
      if (userCredential.user == null) {
        throw AuthenticationException(message: 'Failed to sign in with Google');
      }

      return _mapFirebaseUserToUserModel(userCredential.user!);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw AuthenticationException(
        message: _getAuthErrorMessage(e.code),
        statusCode: int.tryParse(e.code),
      );
    } catch (e) {
      throw AuthenticationException(
        message: 'Google sign in failed: ${e.toString()}',
      );
    }
  }

  @override
  Future<String> getCurrentFirebaseToken() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw AuthenticationException(message: 'No user signed in');
    }

    final token = await user.getIdToken();
    if (token == null) {
      throw AuthenticationException(message: 'Failed to fetch Firebase token');
    }
    return token;
  }

  @override
  firebase_auth.User? getCurrentFirebaseUser() {
    return _firebaseAuth.currentUser;
  }


  @override
  Future<void> signOut() async {
    try {
      await Future.wait([
        _firebaseAuth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (e) {
      throw AuthenticationException(
        message: 'Sign out failed: ${e.toString()}',
      );
    }
  }

  UserModel _mapFirebaseUserToUserModel(firebase_auth.User firebaseUser) {
    AuthProvider authProvider = AuthProvider.phone;
    
    // Determine auth provider based on provider data
    for (final providerData in firebaseUser.providerData) {
      if (providerData.providerId == 'google.com') {
        authProvider = AuthProvider.google;
        break;
      } else if (providerData.providerId == 'phone') {
        authProvider = AuthProvider.phone;
        break;
      }
    }

    return UserModel(
      id: firebaseUser.uid,
      name: firebaseUser.displayName,
      email: firebaseUser.email,
      phone: firebaseUser.phoneNumber,
      photoUrl: firebaseUser.photoURL,
      userType: UserType.registered,
      authProvider: authProvider,
      createdAt: firebaseUser.metadata.creationTime ?? DateTime.now(),
      lastLoginAt: firebaseUser.metadata.lastSignInTime,
      isEmailVerified: firebaseUser.emailVerified,
      isPhoneVerified: firebaseUser.phoneNumber != null,
    );
  }

  String _getAuthErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'invalid-verification-code':
        return 'The verification code is invalid';
      case 'invalid-verification-id':
        return 'The verification ID is invalid';
      case 'quota-exceeded':
        return 'SMS quota exceeded. Please try again later';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'operation-not-allowed':
        return 'This sign-in method is not allowed';
      case 'account-exists-with-different-credential':
        return 'An account already exists with this email using a different sign-in method';
      case 'credential-already-in-use':
        return 'This credential is already associated with a different account';
      default:
        return 'Authentication failed. Please try again';
    }
  }
}

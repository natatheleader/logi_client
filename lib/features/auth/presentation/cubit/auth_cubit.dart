import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/use_cases/use_case.dart';
import '../../domain/entities/user.dart';
import '../../domain/use_cases/user_management_use_cases.dart';
import '../../domain/use_cases/google_auth_use_cases.dart';
import '../../domain/use_cases/guest_auth_use_cases.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final GetCurrentUser getCurrentUser;
  final SignOut signOut;
  final SignInWithGoogle signInWithGoogle;
  final ContinueAsGuest continueAsGuest;
  final UpdateProfile updateProfile;

  AuthCubit({
    required this.getCurrentUser,
    required this.signOut,
    required this.signInWithGoogle,
    required this.continueAsGuest,
    required this.updateProfile,
  }) : super(const AuthState());

  Future<void> checkAuthStatus() async {
    emit(state.copyWith(status: AuthStatus.loading));
    
    final result = await getCurrentUser(NoParams());
    
    result.fold(
      (failure) => emit(state.copyWith(
        status: AuthStatus.unauthenticated,
        error: failure.message,
      )),
      (user) => emit(state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
        error: null,
      )),
    );
  }

  Future<void> signInWithGoogleAuth() async {
    emit(state.copyWith(status: AuthStatus.loading));
    
    final result = await signInWithGoogle(NoParams());
    
    result.fold(
      (failure) => emit(state.copyWith(
        status: AuthStatus.unauthenticated,
        error: failure.message,
      )),
      (user) => emit(state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
        error: null,
      )),
    );
  }

  Future<void> continueAsGuestUser() async {
    emit(state.copyWith(status: AuthStatus.loading));
    
    final result = await continueAsGuest(NoParams());
    
    result.fold(
      (failure) => emit(state.copyWith(
        status: AuthStatus.unauthenticated,
        error: failure.message,
      )),
      (user) => emit(state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
        error: null,
      )),
    );
  }

  Future<void> updateUserProfile({
    String? name,
    String? email,
    String? phone,
  }) async {
    if (state.user == null) return;
    
    emit(state.copyWith(status: AuthStatus.loading));
    
    final params = UpdateProfileParams(
      name: name,
      email: email,
      phone: phone,
    );
    
    final result = await updateProfile(params);
    
    result.fold(
      (failure) => emit(state.copyWith(
        status: AuthStatus.authenticated,
        error: failure.message,
      )),
      (user) => emit(state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
        error: null,
      )),
    );
  }

  Future<void> signOutUser() async {
    emit(state.copyWith(status: AuthStatus.loading));
    
    final result = await signOut(NoParams());
    
    result.fold(
      (failure) => emit(state.copyWith(
        status: AuthStatus.authenticated, // Keep current state on error
        error: failure.message,
      )),
      (_) => emit(state.copyWith(
        status: AuthStatus.unauthenticated,
        user: null,
        error: null,
      )),
    );
  }

  void clearError() {
    emit(state.copyWith(error: null));
  }
}

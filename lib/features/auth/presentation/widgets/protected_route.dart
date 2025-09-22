import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../cubit/auth_cubit.dart';

class ProtectedRoute extends StatelessWidget {
  final Widget child;
  final bool allowGuest;

  const ProtectedRoute({
    super.key,
    required this.child,
    this.allowGuest = false,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        switch (state.status) {
          case AuthStatus.loading:
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          
          case AuthStatus.unauthenticated:
            // Redirect to auth
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.go(AppRoutes.auth);
            });
            return const SizedBox.shrink();
          
          case AuthStatus.authenticated:
            // Check if this route allows guests
            if (!allowGuest && state.user?.isGuest == true) {
              return _buildGuestRestrictionDialog(context);
            }
            return child;
          
          case AuthStatus.initial:
          default:
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
        }
      },
    );
  }

  Widget _buildGuestRestrictionDialog(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock_outline_rounded,
                size: 80,
                color: AppColors.primary.withOpacity(0.6),
              ),
              
              const SizedBox(height: AppSpacing.lg),
              
              Text(
                'Account Required',
                style: AppTextStyles.h2.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              
              const SizedBox(height: AppSpacing.sm),
              
              Text(
                'This feature requires an account. Please sign up or sign in to continue.',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: AppSpacing.xl),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    context.go(AppRoutes.auth);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Create Account'),
                ),
              ),
              
              const SizedBox(height: AppSpacing.sm),
              
              TextButton(
                onPressed: () {
                  context.pop();
                },
                child: Text(
                  'Go Back',
                  style: AppTextStyles.buttonMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
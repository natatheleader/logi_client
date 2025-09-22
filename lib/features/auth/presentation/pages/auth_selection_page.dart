import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart' hide push, pop;
import '../../../../core/di/injection_container.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/extensions.dart';
import '../cubit/auth_cubit.dart';
import '../widgets/animated_logo.dart';
import '../widgets/auth_button.dart';

class AuthSelectionPage extends StatefulWidget {
  const AuthSelectionPage({super.key});

  @override
  State<AuthSelectionPage> createState() => _AuthSelectionPageState();
}

class _AuthSelectionPageState extends State<AuthSelectionPage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _startAnimations();
  }

  void _startAnimations() {
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _slideController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<AuthCubit>(),
      child: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state.isAuthenticated) {
            context.go(AppRoutes.home);
          } else if (state.error != null) {
            context.showErrorSnackBar(state.error!);
          }
        },
        child: Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary,
                  AppColors.primary.withOpacity(0.8),
                  AppColors.accent.withOpacity(0.6),
                ],
              ),
            ),
            child: SafeArea(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: AppSpacing.xl),
                        
                        // Logo and title
                        const AnimatedLogo(size: 100),
                        const SizedBox(height: AppSpacing.lg),
                        
                        Text(
                          'Welcome to Quick Deliver',
                          style: AppTextStyles.h2.copyWith(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        
                        const SizedBox(height: AppSpacing.sm),
                        
                        Text(
                          'Choose how you\'d like to get started',
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: Colors.white.withOpacity(0.8),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        
                        const Spacer(),
                        
                        // Authentication options
                        _buildAuthOptions(context),
                        
                        const SizedBox(height: AppSpacing.xl),
                        
                        // Terms and privacy
                        _buildTermsText(context),
                        
                        const SizedBox(height: AppSpacing.lg),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAuthOptions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Phone authentication
        AuthButton(
          onTap: () => context.push('/auth/phone'),
          icon: Icons.phone_android_rounded,
          text: 'Continue with Phone',
          backgroundColor: Colors.white,
          textColor: AppColors.primary,
          delay: 0,
        ),
        
        const SizedBox(height: AppSpacing.md),
        
        // Google authentication
        BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            return AuthButton(
              onTap: state.isLoading 
                ? null 
                : () => context.read<AuthCubit>().signInWithGoogleAuth(),
              icon: Icons.g_mobiledata_rounded,
              text: 'Continue with Google',
              backgroundColor: Colors.white.withOpacity(0.1),
              textColor: Colors.white,
              borderColor: Colors.white.withOpacity(0.3),
              isLoading: state.isLoading,
              delay: 100,
            );
          },
        ),
        
        const SizedBox(height: AppSpacing.md),
        
        // Guest access
        BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            return AuthButton(
              onTap: state.isLoading 
                ? null 
                : () => context.read<AuthCubit>().continueAsGuestUser(),
              icon: Icons.person_outline_rounded,
              text: 'Continue as Guest',
              backgroundColor: Colors.transparent,
              textColor: Colors.white,
              borderColor: Colors.white.withOpacity(0.5),
              isLoading: state.isLoading,
              delay: 200,
            );
          },
        ),
      ],
    );
  }

  Widget _buildTermsText(BuildContext context) {
    return Text.rich(
      TextSpan(
        text: 'By continuing, you agree to our ',
        style: AppTextStyles.bodySmall.copyWith(
          color: Colors.white.withOpacity(0.7),
        ),
        children: [
          TextSpan(
            text: 'Terms of Service',
            style: AppTextStyles.bodySmall.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.underline,
            ),
          ),
          const TextSpan(text: ' and '),
          TextSpan(
            text: 'Privacy Policy',
            style: AppTextStyles.bodySmall.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.underline,
            ),
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}

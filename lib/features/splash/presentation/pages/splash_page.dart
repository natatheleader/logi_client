import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/theme/app_theme.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _backgroundController;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoFadeAnimation;
  late Animation<double> _backgroundAnimation;

  @override
  void initState() {
    super.initState();
    
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _backgroundController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _logoScaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    ));

    _logoFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeInOut),
    ));

    _backgroundAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _backgroundController,
      curve: Curves.easeInOut,
    ));

    _startAnimations();
    _navigateAfterDelay();
  }

  void _startAnimations() {
    _backgroundController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _logoController.forward();
    });
  }

  void _navigateAfterDelay() {
    Future.delayed(const Duration(milliseconds: 2500), () {
      _checkInitialRoute();
    });
  }

  void _checkInitialRoute() {
    final storageService = getIt<StorageService>();
    
    if (!storageService.isOnboardingCompleted()) {
      // Show onboarding for first-time users
      context.go(AppRoutes.onboarding);
    } else if (storageService.isLoggedIn() || storageService.getUserData() != null) {
      // Navigate to home for authenticated users (including guests)
      context.go(AppRoutes.home);
    } else {
      // Navigate to auth for users who completed onboarding but not logged in
      context.go(AppRoutes.auth);
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _backgroundController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _backgroundController,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.lerp(
                    const Color(0xFF667eea),
                    const Color(0xFF764ba2),
                    _backgroundAnimation.value,
                  )!,
                  Color.lerp(
                    const Color(0xFF4facfe),
                    const Color(0xFFf093fb),
                    _backgroundAnimation.value,
                  )!,
                ],
              ),
            ),
            child: Stack(
              children: [
                // Background animated particles
                ..._buildFloatingParticles(),
                
                // Main content
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Animated logo
                      FadeTransition(
                        opacity: _logoFadeAnimation,
                        child: ScaleTransition(
                          scale: _logoScaleAnimation,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.8),
                                  blurRadius: 10,
                                  spreadRadius: -5,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.local_shipping_rounded,
                              size: 60,
                              color: Color(0xFF667eea),
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // App name
                      FadeTransition(
                        opacity: _logoFadeAnimation,
                        child: Text(
                          'Quick Deliver',
                          style: AppTextStyles.h1.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 32,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // Tagline
                      FadeTransition(
                        opacity: _logoFadeAnimation,
                        child: Text(
                          'Fast • Reliable • Secure',
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 16,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 48),
                      
                      // Loading indicator
                      FadeTransition(
                        opacity: _logoFadeAnimation,
                        child: SizedBox(
                          width: 40,
                          height: 40,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildFloatingParticles() {
    return List.generate(8, (index) {
      final random = Random(index);
      return AnimatedBuilder(
        animation: _backgroundController,
        builder: (context, child) {
          final progress = _backgroundAnimation.value;
          return Positioned(
            left: random.nextDouble() * 300 * progress,
            top: random.nextDouble() * 600 * progress,
            child: Container(
              width: 20 + random.nextDouble() * 30,
              height: 20 + random.nextDouble() * 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1 * progress),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.2 * progress),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }
}
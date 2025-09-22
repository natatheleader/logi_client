import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/splash/presentation/pages/splash_page.dart';

import '../../features/auth/presentation/pages/auth_selection_page.dart';
import '../../features/auth/presentation/pages/phone_auth_page.dart';

class AppRoutes {
  static const String splash = '/';  // Changed: Make splash the root route
  static const String onboarding = '/onboarding';
  static const String auth = '/auth';
  static const String phoneAuth = '/auth/phone';
  static const String home = '/home';
}

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    routes: [
      // Add splash route as the initial route
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const SplashPage(),
        ),
      ),

      // Onboarding route
      GoRoute(
        path: AppRoutes.onboarding,
        name: 'onboarding',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const OnboardingPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: CurveTween(curve: Curves.easeInOutCirc).animate(animation),
              child: child,
            );
          },
        ),
      ),

      // Authentication routes
      GoRoute(
        path: AppRoutes.auth,
        name: 'auth',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const AuthSelectionPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(CurveTween(curve: Curves.easeInOutCubic).animate(animation)),
              child: child,
            );
          },
        ),
      ),

      GoRoute(
        path: AppRoutes.phoneAuth,
        name: 'phoneAuth',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const PhoneAuthPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(CurveTween(curve: Curves.easeInOutCubic).animate(animation)),
              child: child,
            );
          },
        ),
      ),

      // Home route
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const Scaffold(
            body: Center(
              child: Text('Home Page - Welcome!'),
            ),
          ),
        ),
      ),
    ],
      
      // Placeholder routes for future implementation
    //   GoRoute(
    //     path: AppRoutes.login,
    //     name: 'login',
    //     pageBuilder: (context, state) => MaterialPage(
    //       key: state.pageKey,
    //       child: const Scaffold(
    //         body: Center(
    //           child: Text('Login Page - Coming Soon'),
    //         ),
    //       ),
    //     ),
    //   ),
      
    //   GoRoute(
    //     path: AppRoutes.register,
    //     name: 'register',
    //     pageBuilder: (context, state) => MaterialPage(
    //       key: state.pageKey,
    //       child: const Scaffold(
    //         body: Center(
    //           child: Text('Register Page - Coming Soon'),
    //         ),
    //       ),
    //     ),
    //   ),
      
    //   GoRoute(
    //     path: AppRoutes.home,
    //     name: 'home',
    //     pageBuilder: (context, state) => MaterialPage(
    //       key: state.pageKey,
    //       child: const Scaffold(
    //         body: Center(
    //           child: Text('Home Page - Coming Soon'),
    //         ),
    //       ),
    //     ),
    //   ),
    // ],
    
    errorPageBuilder: (context, state) => MaterialPage(
      key: state.pageKey,
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                'Page not found!',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'The page you are looking for does not exist.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
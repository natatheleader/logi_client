import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/router/app_router.dart';
import '../cubit/auth_cubit.dart';

class AuthWrapper extends StatelessWidget {
  final Widget child;

  const AuthWrapper({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<AuthCubit>()..checkAuthStatus(),
      child: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          // Handle auth state changes globally
          if (state.status == AuthStatus.unauthenticated) {
            // Only redirect to auth if we're not already on auth pages
            final location = GoRouterState.of(context).uri.toString();
            if (!location.startsWith('/auth') && 
                !location.startsWith('/onboarding') &&
                location != '/') {
              context.go(AppRoutes.auth);
            }
          }
        },
        child: child,
      ),
    );
  }
}
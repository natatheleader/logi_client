import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:firebase_core/firebase_core.dart';

import 'core/di/injection_container.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';

import 'features/auth/presentation/widgets/auth_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize dependency injection
  await configureDependencies();
  
  runApp(const QuickDeliverApp());
}

class QuickDeliverApp extends StatelessWidget {
  const QuickDeliverApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthWrapper(
      child: MaterialApp.router(
        title: 'Quick Deliver',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/router/app_router.dart';
import '../cubit/onboarding_cubit.dart';
import '../widgets/onboarding_content.dart';
import '../widgets/onboarding_navigation.dart';
import '../widgets/page_indicator.dart';
import '../../../../core/services/storage_service.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<OnboardingCubit>(),
      child: BlocListener<OnboardingCubit, OnboardingState>(
        listener: (context, state) {
          if (state.isCompleted) {
            // Navigate to login/auth page
            context.go(AppRoutes.auth);
          }
        },
        child: const OnboardingView(),
      ),
    );
  }
}

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _fadeController;
  late AnimationController _skipButtonController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _skipButtonAnimation;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _skipButtonController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _fadeAnimation = CurveTween(curve: Curves.easeInOut).animate(_fadeController);
    
    _skipButtonAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _skipButtonController,
      curve: Curves.elasticOut,
    ));
    
    _fadeController.forward();
    _skipButtonController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    _skipButtonController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    context.read<OnboardingCubit>().goToPage(index);
    
    // Add haptic feedback
    HapticFeedback.lightImpact();
  }

  void _nextPage() {
    final cubit = context.read<OnboardingCubit>();
    
    // Add haptic feedback
    HapticFeedback.mediumImpact();
    
    if (cubit.isLastPage) {
      cubit.completeOnboarding();
    } else {
      cubit.nextPage();
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _previousPage() {
    final cubit = context.read<OnboardingCubit>();
    
    // Add haptic feedback
    HapticFeedback.lightImpact();
    
    if (!cubit.isFirstPage) {
      cubit.previousPage();
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _skipOnboarding() {
    print('Skip button pressed!'); // Add debug print
    
    // Add haptic feedback
    HapticFeedback.mediumImpact();
   
    // Get the last page index (3 for 4 pages)
    final cubit = context.read<OnboardingCubit>();
    final lastPageIndex = cubit.onboardingItems.length - 1;
    
    print('Navigating to page: $lastPageIndex'); // Debug print
    
    // Update cubit state first
    cubit.goToPage(lastPageIndex);
    
    // Then animate to the last page
    _pageController.animateToPage(
      lastPageIndex,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Stack(
          children: [
            // Main content
            Column(
              children: [
                // Page content with parallax effect
                Expanded(
                  child: BlocBuilder<OnboardingCubit, OnboardingState>(
                    builder: (context, state) {
                      return PageView.builder(
                        controller: _pageController,
                        onPageChanged: _onPageChanged,
                        itemCount: context.read<OnboardingCubit>().onboardingItems.length,
                        itemBuilder: (context, index) {
                          final item = context.read<OnboardingCubit>().onboardingItems[index];
                          return OnboardingContent(
                            item: item,
                            isActive: state.currentIndex == index,
                          );
                        },
                      );
                    },
                  ),
                ),
                
                // Bottom section with glassmorphism effect
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.1),
                        Colors.black.withOpacity(0.2),
                      ],
                    ),
                  ),
                  child: Column(
                    children: [
                      // Page indicator
                      BlocBuilder<OnboardingCubit, OnboardingState>(
                        builder: (context, state) {
                          return PageIndicator(
                            currentIndex: state.currentIndex,
                            itemCount: context.read<OnboardingCubit>().onboardingItems.length,
                          );
                        },
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Navigation buttons
                      BlocBuilder<OnboardingCubit, OnboardingState>(
                        builder: (context, state) {
                          return OnboardingNavigation(
                            isFirstPage: context.read<OnboardingCubit>().isFirstPage,
                            isLastPage: context.read<OnboardingCubit>().isLastPage,
                            onNext: _nextPage,
                            onPrevious: _previousPage,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            // Skip button with animated entrance - FIXED VERSION
            BlocBuilder<OnboardingCubit, OnboardingState>(
              builder: (context, state) {
                if (context.read<OnboardingCubit>().isLastPage) {
                  return const SizedBox.shrink();
                }
                
                return Positioned(
                  top: MediaQuery.of(context).padding.top + 2,
                  right: 20,
                  child: SlideTransition(
                    position: _skipButtonAnimation,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          print('Skip button tapped!'); // Debug print
                          _skipOnboarding();
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Skip',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.arrow_forward_ios,
                                size: 12,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
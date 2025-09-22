import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

class OnboardingNavigation extends StatefulWidget {
  final bool isFirstPage;
  final bool isLastPage;
  final VoidCallback onNext;
  final VoidCallback onPrevious;

  const OnboardingNavigation({
    super.key,
    required this.isFirstPage,
    required this.isLastPage,
    required this.onNext,
    required this.onPrevious,
  });

  @override
  State<OnboardingNavigation> createState() => _OnboardingNavigationState();
}

class _OnboardingNavigationState extends State<OnboardingNavigation>
    with TickerProviderStateMixin {
  late AnimationController _buttonController;
  late Animation<double> _buttonAnimation;

  @override
  void initState() {
    super.initState();
    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _buttonAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _buttonController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _buttonController.dispose();
    super.dispose();
  }

  void _onTapDown() {
    _buttonController.forward();
  }

  void _onTapUp() {
    _buttonController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Previous button
          if (!widget.isFirstPage)
            _buildPreviousButton()
          else
            const SizedBox(width: 120), // Placeholder for spacing

          // Next/Get Started button
          _buildNextButton(),
        ],
      ),
    );
  }

  Widget _buildPreviousButton() {
    return GestureDetector(
      onTapDown: (_) => _onTapDown(),
      onTapUp: (_) => _onTapUp(),
      onTapCancel: () => _onTapUp(),
      onTap: widget.onPrevious,
      child: ScaleTransition(
        scale: _buttonAnimation,
        child: Container(
          height: 56,
          width: 120,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 1,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_back_ios,
                  size: 16,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Back',
                style: AppTextStyles.buttonMedium.copyWith(
                  color: Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNextButton() {
    return GestureDetector(
      onTapDown: (_) => _onTapDown(),
      onTapUp: (_) => _onTapUp(),
      onTapCancel: () => _onTapUp(),
      onTap: widget.onNext,
      child: ScaleTransition(
        scale: _buttonAnimation,
        child: Container(
          height: 56,
          width: widget.isLastPage ? 160 : 130,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Colors.white,
                Color(0xFFF8F9FA),
              ],
            ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 15,
                spreadRadius: 2,
                offset: const Offset(0, 6),
              ),
              BoxShadow(
                color: Colors.white.withOpacity(0.8),
                blurRadius: 10,
                spreadRadius: -2,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.isLastPage ? 'Get Started' : 'Next',
                style: AppTextStyles.buttonLarge.copyWith(
                  color: const Color(0xFF2D3748),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  gradient: widget.isLastPage
                      ? const LinearGradient(
                          colors: [
                            Color(0xFF48BB78),
                            Color(0xFF38A169),
                          ],
                        )
                      : const LinearGradient(
                          colors: [
                            Color(0xFF4299E1),
                            Color(0xFF3182CE),
                          ],
                        ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: (widget.isLastPage
                              ? const Color(0xFF48BB78)
                              : const Color(0xFF4299E1))
                          .withOpacity(0.4),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Icon(
                  widget.isLastPage
                      ? Icons.check_rounded
                      : Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
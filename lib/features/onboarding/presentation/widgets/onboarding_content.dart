import 'dart:math';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/onboarding_item.dart';

class OnboardingContent extends StatefulWidget {
  final OnboardingItem item;
  final bool isActive;

  const OnboardingContent({
    super.key,
    required this.item,
    required this.isActive,
  });

  @override
  State<OnboardingContent> createState() => _OnboardingContentState();
}

class _OnboardingContentState extends State<OnboardingContent>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _pulseController;
  late AnimationController _floatController;
  late AnimationController _rotateController;
  
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _floatAnimation;
  late Animation<double> _rotateAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    _mainController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _floatController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    
    _rotateController = AnimationController(
      duration: const Duration(milliseconds: 20000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: Curves.elasticOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _floatAnimation = Tween<double>(
      begin: -10,
      end: 10,
    ).animate(CurvedAnimation(
      parent: _floatController,
      curve: Curves.easeInOut,
    ));

    _rotateAnimation = Tween<double>(
      begin: 0,
      end: 2 * pi,
    ).animate(CurvedAnimation(
      parent: _rotateController,
      curve: Curves.linear,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: Curves.easeOutCubic,
    ));

    // Start animations
    if (widget.isActive) {
      _startAnimations();
    }
  }

  void _startAnimations() {
    _mainController.forward();
    _pulseController.repeat(reverse: true);
    _floatController.repeat(reverse: true);
    _rotateController.repeat();
  }

  @override
  void didUpdateWidget(OnboardingContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _startAnimations();
    } else if (!widget.isActive && oldWidget.isActive) {
      _mainController.reset();
      _pulseController.reset();
      _floatController.reset();
      _rotateController.reset();
    }
  }

  @override
  void dispose() {
    _mainController.dispose();
    _pulseController.dispose();
    _floatController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        gradient: _getBackgroundGradient(),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated illustration area
            SizedBox(
              width: 320,
              height: 320,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Background floating particles
                  ..._buildFloatingParticles(),
                  
                  // Main animated content
                  SlideTransition(
                    position: _slideAnimation,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: _buildMainIllustration(),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: AppSpacing.xl),
            
            // Animated title
            SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.5),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: _mainController,
                curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
              )),
              child: FadeTransition(
                opacity: _mainController,
                child: Text(
                  widget.item.title,
                  style: AppTextStyles.h2.copyWith(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    foreground: Paint()
                      ..shader = _getTitleGradient().createShader(
                        const Rect.fromLTWH(0, 0, 300, 70),
                      ),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            
            const SizedBox(height: AppSpacing.md),
            
            // Animated subtitle
            SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.3),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: _mainController,
                curve: const Interval(0.5, 1.0, curve: Curves.easeOutCubic),
              )),
              child: FadeTransition(
                opacity: CurvedAnimation(
                  parent: _mainController,
                  curve: const Interval(0.5, 1.0),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    widget.item.subtitle,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: Colors.white.withOpacity(0.9),
                      height: 1.6,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  LinearGradient _getBackgroundGradient() {
    switch (widget.item.title) {
      case 'Fast & Reliable Delivery':
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF667eea),
            Color(0xFF764ba2),
            Color(0xFFf093fb),
          ],
          stops: [0.0, 0.5, 1.0],
        );
      case 'Track Your Orders':
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF4facfe),
            Color(0xFF00f2fe),
            Color(0xFF43e97b),
          ],
          stops: [0.0, 0.5, 1.0],
        );
      case 'Simple & Easy Ordering':
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFfa709a),
            Color(0xFFfee140),
            Color(0xFFffa726),
          ],
          stops: [0.0, 0.5, 1.0],
        );
      case 'Always Here to Help':
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF6a11cb),
            Color(0xFF2575fc),
            Color(0xFF00d4ff),
          ],
          stops: [0.0, 0.5, 1.0],
        );
      default:
        return const LinearGradient(
          colors: [AppColors.primary, AppColors.accent],
        );
    }
  }

  LinearGradient _getTitleGradient() {
    return const LinearGradient(
      colors: [
        Colors.white,
        Color(0xFFF0F8FF),
      ],
    );
  }

  List<Widget> _buildFloatingParticles() {
    return List.generate(6, (index) {
      final delay = index * 0.2;
      return AnimatedBuilder(
        animation: _floatController,
        builder: (context, child) {
          return Positioned(
            left: (index % 3) * 100.0 + 20,
            top: (index ~/ 3) * 150.0 + 50,
            child: Transform.translate(
              offset: Offset(
                sin((_floatAnimation.value + delay) * 0.02) * 20,
                cos((_floatAnimation.value + delay) * 0.02) * 15,
              ),
              child: Container(
                width: 20 + (index % 3) * 10,
                height: 20 + (index % 3) * 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.2),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    });
  }

  Widget _buildMainIllustration() {
    return Container(
      width: 240,
      height: 240,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            Colors.white.withOpacity(0.3),
            Colors.white.withOpacity(0.1),
            Colors.transparent,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Rotating background ring
          AnimatedBuilder(
            animation: _rotateController,
            builder: (context, child) {
              return Transform.rotate(
                angle: _rotateAnimation.value,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 2,
                    ),
                  ),
                  child: CustomPaint(
                    painter: DottedCirclePainter(),
                  ),
                ),
              );
            },
          ),
          
          // Pulsing main icon
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.9),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.4),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: _buildMainIcon(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMainIcon() {
    IconData iconData;
    Color iconColor;
    
    switch (widget.item.title) {
      case 'Fast & Reliable Delivery':
        iconData = Icons.local_shipping_rounded;
        iconColor = const Color(0xFF667eea);
        break;
      case 'Track Your Orders':
        iconData = Icons.my_location_rounded;
        iconColor = const Color(0xFF4facfe);
        break;
      case 'Simple & Easy Ordering':
        iconData = Icons.smartphone_rounded;
        iconColor = const Color(0xFFfa709a);
        break;
      case 'Always Here to Help':
        iconData = Icons.support_agent_rounded;
        iconColor = const Color(0xFF6a11cb);
        break;
      default:
        iconData = Icons.local_shipping_rounded;
        iconColor = AppColors.primary;
    }

    return AnimatedBuilder(
      animation: _floatController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _floatAnimation.value * 0.3),
          child: Icon(
            iconData,
            size: 50,
            color: iconColor,
          ),
        );
      },
    );
  }
}

class DottedCirclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    
    for (int i = 0; i < 12; i++) {
      final angle = (i * 30) * (pi / 180);
      final x1 = center.dx + (radius - 10) * cos(angle);
      final y1 = center.dy + (radius - 10) * sin(angle);
      final x2 = center.dx + radius * cos(angle);
      final y2 = center.dy + radius * sin(angle);
      
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
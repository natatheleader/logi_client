import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

class PageIndicator extends StatelessWidget {
  final int currentIndex;
  final int itemCount;

  const PageIndicator({
    super.key,
    required this.currentIndex,
    required this.itemCount,
  });

  @override
  Widget build(BuildContext context) {
    // return ColorFiltered(
    //   colorFilter: const ColorFilter.matrix([
    //     0.8, 0, 0, 0, 0,
    //     0, 0.8, 0, 0, 0,
    //     0, 0, 0.8, 0, 0,
    //     0, 0, 0, 1, 0,
    //   ]),
    //   child: 
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(
            itemCount,
            (index) => _buildIndicator(index, currentIndex == index),
          ),
        ),
      // ),
    );
  }

  Widget _buildIndicator(int index, bool isActive) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      tween: Tween<double>(
        begin: 0,
        end: isActive ? 1 : 0,
      ),
      builder: (context, value, child) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Background circle
              Container(
                height: 12,
                width: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.4),
                ),
              ),
              
              // Active animated indicator
              AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOutCubic,
                height: isActive ? 8 : 4,
                width: isActive ? 24 : 4,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white,
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.6),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ]
                      : null,
                ),
              ),
              
              // Ripple effect for active indicator
              if (isActive)
                Container(
                  height: 20,
                  width: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
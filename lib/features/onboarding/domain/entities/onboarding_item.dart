import 'package:equatable/equatable.dart';

class OnboardingItem extends Equatable {
  final String title;
  final String subtitle;
  final String imagePath;

  const OnboardingItem({
    required this.title,
    required this.subtitle,
    required this.imagePath,
  });

  @override
  List<Object> get props => [title, subtitle, imagePath];
}
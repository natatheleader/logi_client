import '../../domain/entities/onboarding_item.dart';

class OnboardingModel extends OnboardingItem {
  const OnboardingModel({
    required super.title,
    required super.subtitle,
    required super.imagePath,
  });

  factory OnboardingModel.fromJson(Map<String, dynamic> json) {
    return OnboardingModel(
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      imagePath: json['imagePath'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'subtitle': subtitle,
      'imagePath': imagePath,
    };
  }
}
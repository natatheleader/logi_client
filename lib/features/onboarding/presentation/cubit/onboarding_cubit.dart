import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/services/storage_service.dart';
import '../../domain/entities/onboarding_item.dart';
import '../../data/models/onboarding_model.dart';

part 'onboarding_state.dart';

class OnboardingCubit extends Cubit<OnboardingState> {
  final StorageService _storageService;

  OnboardingCubit(this._storageService) : super(const OnboardingState());

  final List<OnboardingItem> _onboardingItems = const [
    OnboardingModel(
      title: 'Fast & Reliable Delivery',
      subtitle: 'Get your packages delivered quickly and safely to your doorstep',
      imagePath: 'assets/images/onboarding_1.png',
    ),
    OnboardingModel(
      title: 'Track Your Orders',
      subtitle: 'Monitor your delivery in real-time from pickup to your door',
      imagePath: 'assets/images/onboarding_2.png',
    ),
    OnboardingModel(
      title: 'Simple & Easy Ordering',
      subtitle: 'Place your delivery requests with just a few taps',
      imagePath: 'assets/images/onboarding_3.png',
    ),
    OnboardingModel(
      title: 'Always Here to Help',
      subtitle: 'Our support team is available around the clock for you',
      imagePath: 'assets/images/onboarding_4.png',
    ),
  ];

  List<OnboardingItem> get onboardingItems => _onboardingItems;

  void nextPage() {
    if (state.currentIndex < _onboardingItems.length - 1) {
      emit(state.copyWith(currentIndex: state.currentIndex + 1));
    }
  }

  void previousPage() {
    if (state.currentIndex > 0) {
      emit(state.copyWith(currentIndex: state.currentIndex - 1));
    }
  }

  void goToPage(int index) {
    if (index >= 0 && index < _onboardingItems.length) {
      emit(state.copyWith(currentIndex: index));
    }
  }

  Future<void> skipOnboarding() async {
    await _storageService.setOnboardingCompleted(true);
    await _storageService.setFirstLaunch(false);
    emit(state.copyWith(isCompleted: true));
  }

  Future<void> completeOnboarding() async {
    await _storageService.setOnboardingCompleted(true);
    await _storageService.setFirstLaunch(false);
    emit(state.copyWith(isCompleted: true));
  }

  bool get isFirstPage => state.currentIndex == 0;
  bool get isLastPage => state.currentIndex == _onboardingItems.length - 1;
  
  OnboardingItem get currentItem => _onboardingItems[state.currentIndex];
}
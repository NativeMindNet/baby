import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/profile_repository.dart';
import 'repository_providers.dart';

/// Provider to check if onboarding is complete
final onboardingCompleteProvider = FutureProvider<bool>((ref) async {
  final profileRepo = ref.watch(profileRepositoryProvider);
  return await profileRepo.hasProfile();
});

/// State notifier for onboarding flow
class OnboardingState {
  final bool isComplete;
  final bool isLoading;

  const OnboardingState({
    required this.isComplete,
    this.isLoading = false,
  });

  OnboardingState copyWith({
    bool? isComplete,
    bool? isLoading,
  }) {
    return OnboardingState(
      isComplete: isComplete ?? this.isComplete,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class OnboardingNotifier extends StateNotifier<OnboardingState> {
  final ProfileRepository _profileRepository;

  OnboardingNotifier(this._profileRepository)
      : super(const OnboardingState(isComplete: false)) {
    _checkOnboardingStatus();
  }

  Future<void> _checkOnboardingStatus() async {
    state = state.copyWith(isLoading: true);
    final hasProfile = await _profileRepository.hasProfile();
    state = state.copyWith(isComplete: hasProfile, isLoading: false);
  }

  Future<void> completeOnboarding() async {
    state = state.copyWith(isComplete: true);
  }

  Future<void> resetOnboarding() async {
    await _profileRepository.deleteProfile();
    state = state.copyWith(isComplete: false);
  }
}

final onboardingProvider = StateNotifierProvider<OnboardingNotifier, OnboardingState>((ref) {
  final profileRepo = ref.watch(profileRepositoryProvider);
  return OnboardingNotifier(profileRepo);
});

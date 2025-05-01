import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OnboardingPage {
  final String imageAsset;
  final String title;
  final String description;

  OnboardingPage({
    required this.imageAsset,
    required this.title,
    required this.description,
  });
}

class OnboardingModel {
  final List<OnboardingPage> pages;
  final int currentPageIndex;
  final bool isLastPage;
  final PageController pageController;

  OnboardingModel({
    required this.pages,
    this.currentPageIndex = 0,
    this.isLastPage = false,
    required this.pageController,
  });

  OnboardingModel copyWith({
    List<OnboardingPage>? pages,
    int? currentPageIndex,
    bool? isLastPage,
    PageController? pageController,
  }) {
    return OnboardingModel(
      pages: pages ?? this.pages,
      currentPageIndex: currentPageIndex ?? this.currentPageIndex,
      isLastPage: isLastPage ?? this.isLastPage,
      pageController: pageController ?? this.pageController,
    );
  }

  OnboardingPage get currentPage => pages[currentPageIndex];
}

/// Houses onboarding state and handles page navigation.
///
/// This notifier manages the onboarding flow state and provides
/// methods to navigate between pages.
class OnboardingViewModel extends Notifier<OnboardingModel> {
  @override
  OnboardingModel build() {
    // Initialize PageController with the proper settings
    final controller = PageController(
      initialPage: 0,
      viewportFraction: 1,
      keepPage: true,
    );

    return OnboardingModel(
      pageController: controller,
      pages: [
        OnboardingPage(
          imageAsset: 'lib/assets/images/onboarding_1.jpg',
          title: 'Get Paid for Your Insights',
          description:
              'Share your opinions through simple surveys and earn rewards seamlessly—no hidden fees, no hassle.',
        ),
        OnboardingPage(
          imageAsset: 'lib/assets/images/onboarding_2.jpg',
          title: 'Fast, Easy, and Transparent Payments',
          description:
              'Withdraw your earnings with ease. Choose from multiple payment options that work best for you.',
        ),
        OnboardingPage(
          imageAsset: 'lib/assets/images/onboarding_3.jpg',
          title: 'Reliable Surveys, Anytime You Need',
          description:
              'Never miss an opportunity! Get notified when new surveys are available and start earning instantly.',
        ),
      ],
    );
  }

  // Getter for the current page
  OnboardingPage get currentPage => state.pages[state.currentPageIndex];

  // Getter for the current image asset
  String get currentImageAsset => currentPage.imageAsset;

  // Getter for the current title
  String get currentTitle => currentPage.title;

  // Getter for the current description
  String get currentDescription => currentPage.description;

  // Getter for checking if we're on the first page
  bool get isFirstPage => state.currentPageIndex == 0;

  // Getter for checking if we're on the last page
  bool get isLastPage => state.currentPageIndex == state.pages.length - 1;

  // Getter for the current page index
  int get currentPageIndex => state.currentPageIndex;

  // Getter for total page count
  int get pageCount => state.pages.length;

  // Getter for the page controller
  PageController get pageController => state.pageController;

  // Navigate to the next page
  void goToNextPage() {
    if (state.currentPageIndex < state.pages.length - 1) {
      final nextIndex = state.currentPageIndex + 1;
      // First update the controller with animation
      state.pageController.animateToPage(
        nextIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );

      // Then update the state
      state = state.copyWith(
        currentPageIndex: nextIndex,
        isLastPage: nextIndex == state.pages.length - 1,
      );
    }
  }

  // Navigate to the previous page
  void goToPreviousPage() {
    if (state.currentPageIndex > 0) {
      final prevIndex = state.currentPageIndex - 1;
      // First update the controller with animation
      state.pageController.animateToPage(
        prevIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );

      // Then update the state
      state = state.copyWith(currentPageIndex: prevIndex, isLastPage: false);
    }
  }

  // Go to a specific page
  void goToPage(int index) {
    if (index >= 0 && index < state.pages.length) {
      // First update the controller with animation
      state.pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );

      // Then update the state
      state = state.copyWith(
        currentPageIndex: index,
        isLastPage: index == state.pages.length - 1,
      );
    }
  }

  // Handle page changes from the PageView widget
  void onPageChanged(int index) {
    if (index != state.currentPageIndex) {
      state = state.copyWith(
        currentPageIndex: index,
        isLastPage: index == state.pages.length - 1,
      );
    }
  }

  void jumpToPage(int index) {
    if (index >= 0 && index < state.pages.length) {
      // Use jumpToPage for immediate navigation without animation
      state.pageController.jumpToPage(index);

      // Update the state
      state = state.copyWith(
        currentPageIndex: index,
        isLastPage: index == state.pages.length - 1,
      );
    }
  }

  void skipOnboarding() {
    // Implementation for skipping onboarding
    // This might involve setting a flag in shared preferences
    // and navigating to the main app screen
  }

  void completeOnboarding() {
    // Implementation for completing onboarding
    // This might involve setting a flag in shared preferences
    // and navigating to the sign-in or main app screen
  }

  void resetOnboarding() {
    // Jump to the first page without animation
    state.pageController.jumpToPage(0);

    // Update the state
    state = state.copyWith(currentPageIndex: 0, isLastPage: false);
  }
}

// Create a combined provider that will rebuild the UI when the state changes
final onboardingViewModelProvider =
    NotifierProvider<OnboardingViewModel, OnboardingModel>(
      OnboardingViewModel.new,
    );

// Usage in your widget:
// @override
// Widget build(BuildContext context) {
//   // First watch the state to ensure rebuilds
//   ref.watch(onboardingViewModelProvider);
//   // Then get the viewModel for all methods
//   final viewModel = ref.read(onboardingViewModelProvider.notifier);
//   
//   // Use viewModel for everything...
// }
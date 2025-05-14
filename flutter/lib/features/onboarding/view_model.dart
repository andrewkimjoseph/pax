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
  final bool isFirstPage;
  final PageController pageController;
  final OnboardingPage currentPage;
  final int pageCount;

  OnboardingModel({
    required this.pages,
    required this.currentPageIndex,
    required this.pageController,
  }) : isLastPage = currentPageIndex == pages.length - 1,
       isFirstPage = currentPageIndex == 0,
       currentPage = pages[currentPageIndex],
       pageCount = pages.length;

  OnboardingModel copyWith({
    List<OnboardingPage>? pages,
    int? currentPageIndex,
    PageController? pageController,
  }) {
    return OnboardingModel(
      pages: pages ?? this.pages,
      currentPageIndex: currentPageIndex ?? this.currentPageIndex,
      pageController: pageController ?? this.pageController,
    );
  }
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
      currentPageIndex: 0,
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
      state = state.copyWith(currentPageIndex: nextIndex);
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
      state = state.copyWith(currentPageIndex: prevIndex);
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
      state = state.copyWith(currentPageIndex: index);
    }
  }

  // Handle page changes from the PageView widget
  void onPageChanged(int index) {
    if (index != state.currentPageIndex) {
      state = state.copyWith(currentPageIndex: index);
    }
  }

  void jumpToPage(int index) {
    if (index >= 0 && index < state.pages.length) {
      // Use jumpToPage for immediate navigation without animation
      state.pageController.jumpToPage(index);

      // Update the state
      state = state.copyWith(currentPageIndex: index);
    }
  }

  void resetOnboarding() {
    // Jump to the first page without animation
    state.pageController.jumpToPage(0);

    // Update the state
    state = state.copyWith(currentPageIndex: 0);
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
//   // Access the state directly, which now contains all necessary data
//   final onboardingState = ref.watch(onboardingViewModelProvider);
//   // Then get the viewModel for methods only
//   final viewModel = ref.read(onboardingViewModelProvider.notifier);
//   
//   // Access state properties: onboardingState.currentPage.title
//   // Call methods: viewModel.goToNextPage()
// }
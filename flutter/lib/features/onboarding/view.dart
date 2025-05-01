import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart' show SvgPicture;
import 'package:go_router/go_router.dart';
import 'package:pax/features/onboarding/view_model.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../theming/colors.dart' show PaxColors;
import '../../utils/clipper.dart';

class OnboardingView extends ConsumerStatefulWidget {
  const OnboardingView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends ConsumerState<OnboardingView> {
  late OnboardingViewModel onboardingViewModel;

  @override
  void initState() {
    onboardingViewModel = ref.read(onboardingViewModelProvider.notifier);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Watch the state to ensure rebuilds when it changes
    ref.watch(onboardingViewModelProvider);

    return Scaffold(
      child: Column(
        children: [
          ClipPath(
            clipper: CurvedBottomClipper(),
            child: Container(
              height:
                  MediaQuery.of(context).size.height *
                  0.5, // Adjust height as needed
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(onboardingViewModel.currentPage.imageAsset),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          // Page content
          Expanded(
            flex: 3,
            child: PageView.builder(
              controller: onboardingViewModel.pageController,
              onPageChanged: (index) {
                // Update the view model when page changes
                onboardingViewModel.onPageChanged(index);
              },
              itemCount: onboardingViewModel.pageCount,
              itemBuilder: (context, index) {
                final page = onboardingViewModel.currentPage;
                return Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      page.title,
                      style: Theme.of(context).typography.base.copyWith(
                        fontWeight: FontWeight.w900,
                        fontSize: 30,
                        color:
                            PaxColors
                                .deepPurple, // The purple color from your images
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      page.description,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).typography.base.copyWith(
                        fontWeight: FontWeight.normal,
                        fontSize: 16,
                        color:
                            PaxColors
                                .black, // The purple color from your images
                      ),
                    ),
                  ],
                ).withPadding(left: 16, right: 16);
              },
            ),
          ),

          // Page indicator
          Expanded(
            child: SmoothPageIndicator(
              controller: onboardingViewModel.pageController,
              count: onboardingViewModel.pageCount,
              onDotClicked: (index) {
                if (onboardingViewModel.currentPageIndex - index == 1 ||
                    onboardingViewModel.currentPageIndex - index == -1) {
                  onboardingViewModel.goToPage(index);
                } else {
                  onboardingViewModel.jumpToPage(index);
                }
              },
              effect: const ExpandingDotsEffect(
                activeDotColor: PaxColors.deepPurple,
                dotHeight: 16,
                dotWidth: 16,
              ),
            ),
          ),

          // Navigation buttons
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: Divider().withPadding(top: 10, bottom: 20),
              ),

              onboardingViewModel.isLastPage
                  ? SizedBox(
                    width: MediaQuery.of(context).size.width * 0.9,
                    height: 48,
                    child: Button(
                      style: const ButtonStyle.outline()
                      // .withBackgroundColor(
                      //   color: Colors.red,
                      //   hoverColor: Colors.purple,
                      // )
                      .withBorder(border: Border.all(color: Colors.black)),

                      onPressed: () {
                        // Handle skip action
                        // onboardingViewModel.skipOnboarding();

                        onboardingViewModel.resetOnboarding();

                        context.pushReplacement('/');
                      },

                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            'lib/assets/svgs/google_icon.svg',
                            height: 16,
                            width: 16,
                          ).withMargin(right: 8),
                          // CircularProgressIndicator().withMargin(right: 8),
                          Text(
                            'Sign in with Google',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 14,
                              color:
                                  PaxColors
                                      .black, // The purple color from your images
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.4,
                        height: 48,
                        child: Button(
                          style: const ButtonStyle.outline()
                              .withBackgroundColor(
                                color: PaxColors.lightGrey,
                                // hoverColor: Colors.purple,
                              )
                              .withBorder(
                                border: Border.all(color: Colors.transparent),
                              ),
                          onPressed: () {
                            // Handle skip action
                            onboardingViewModel.jumpToPage(2);
                          },
                          child: Text(
                            'Skip',
                            style: Theme.of(context).typography.base.copyWith(
                              fontWeight: FontWeight.normal,
                              fontSize: 14,
                              color:
                                  PaxColors
                                      .deepPurple, // The purple color from your images
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.4,
                        height: 48,
                        child: PrimaryButton(
                          onPressed: () {
                            if (onboardingViewModel.isLastPage) {
                              // Handle completion
                              onboardingViewModel.completeOnboarding();
                            } else {
                              // Go to next page
                              onboardingViewModel.goToNextPage();
                            }
                          },
                          child: Text(
                            'Continue',
                            style: Theme.of(context).typography.base.copyWith(
                              fontWeight: FontWeight.normal,
                              fontSize: 14,
                              color:
                                  PaxColors
                                      .white, // The purple color from your images
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
            ],
          ).withPadding(top: 32, bottom: 32),
        ],
      ),
    );
  }

  Widget buildToast(BuildContext context, ToastOverlay overlay) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.95,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [PaxColors.orange, PaxColors.pink],
          stops: [0.0, 1.0], // Optional: control position of each color
        ),
        borderRadius: BorderRadius.circular(
          15,
        ), // Optional: adds rounded corners
        boxShadow: const [
          BoxShadow(
            // color: Colors.black.withValues(),
            spreadRadius: 1,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ], // Optional: adds shadow
      ),
      child: Basic(
        subtitle: const Text(
          'Event created!',
          style: TextStyle(color: PaxColors.white),
        ),
        trailing: PrimaryButton(
          size: ButtonSize.small,
          onPressed: () {
            overlay.close();
          },
          child: const Text('Undo'),
        ),
        trailingAlignment: Alignment.center,
      ),
    );
  }
}

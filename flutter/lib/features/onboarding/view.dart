import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart' show SvgPicture;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:pax/features/onboarding/view_model.dart';
import 'package:pax/models/auth/auth_state_model.dart';
import 'package:pax/providers/auth/auth_provider.dart';
import 'package:pax/providers/db/participant_provider.dart';
import 'package:pax/providers/db/pax_account/pax_account_provider.dart';
import 'package:pax/widgets/toast.dart';
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
  @override
  Widget build(BuildContext context) {
    // Watch the onboarding state - now we directly use the state values
    final onboardingState = ref.watch(onboardingViewModelProvider);
    final onboardingViewModel = ref.read(onboardingViewModelProvider.notifier);

    // Watch the auth state
    final authState = ref.watch(authProvider);
    final bool isAuthLoading = authState.state == AuthState.loading;

    // Watch the participant state
    final participantState = ref.watch(participantProvider);
    final bool isParticipantLoading =
        participantState.state == ParticipantState.loading;

    // Combined loading state
    final bool isLoading = isAuthLoading || isParticipantLoading;

    ref.watch(paxAccountProvider);

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
                  image: AssetImage(onboardingState.currentPage.imageAsset),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          // Page content
          Expanded(
            flex: 3,
            child: PageView.builder(
              controller: onboardingState.pageController,
              onPageChanged: (index) {
                // Update the view model when page changes
                onboardingViewModel.onPageChanged(index);
              },
              itemCount: onboardingState.pageCount,
              itemBuilder: (context, index) {
                final page = onboardingState.currentPage;
                return Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      page.title,
                      style: Theme.of(context).typography.base.copyWith(
                        fontWeight: FontWeight.w900,
                        fontSize: 28,
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
                        fontSize: 14,
                        color:
                            PaxColors
                                .black, // The purple color from your images
                      ),
                    ),

                    // Show user info if authenticated
                    // if (authState.state == AuthState.authenticated &&
                    //     onboardingState.isLastPage)
                    // _buildUserInfo(context, authState.user),
                  ],
                ).withPadding(left: 16, right: 16);
              },
            ),
          ),

          // Page indicator
          Expanded(
            child: SmoothPageIndicator(
              controller: onboardingState.pageController,
              count: onboardingState.pageCount,
              onDotClicked: (index) {
                if (onboardingState.currentPageIndex - index == 1 ||
                    onboardingState.currentPageIndex - index == -1) {
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

              onboardingState.isLastPage
                  ? Column(
                    children: [
                      // Google Sign In Button
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.9,
                        height: 48,
                        child: Button(
                          style: const ButtonStyle.outline().withBorder(
                            border: Border.all(color: Colors.black),
                          ),
                          onPressed:
                              isLoading ||
                                      authState.state == AuthState.authenticated
                                  ? null
                                  : () {
                                    // Handle Google sign in

                                    ref
                                        .read(authProvider.notifier)
                                        .signInWithGoogle()
                                        .then((_) {
                                          if (ref.read(authProvider).state ==
                                                  AuthState.unauthenticated ||
                                              ref.read(authProvider).state ==
                                                  AuthState.error) {
                                            if (context.mounted) {
                                              showErrorToast(context);
                                            }
                                          }

                                          if (ref.read(authProvider).state ==
                                              AuthState.authenticated) {
                                            // Navigate after successful sign in

                                            if (context.mounted) {
                                              showSuccessToast(context);
                                            }

                                            // if (ref
                                            //         .read(participantProvider)
                                            //         .state ==
                                            //     ParticipantState.loaded) {
                                            //   // Navigate after successful sign in and participant loading

                                            // }

                                            onboardingViewModel
                                                .resetOnboarding();

                                            if (context.mounted) {
                                              context.pushReplacement('/');
                                            }
                                          } else {}
                                        })
                                        .onError((error, stackTrace) {
                                          // Handle the error here
                                          if (context.mounted) {
                                            showToast(
                                              context: context,
                                              location: ToastLocation.topCenter,
                                              builder:
                                                  (context, overlay) => Toast(
                                                    leadingIcon:
                                                        FontAwesomeIcons.google,
                                                    toastColor: PaxColors.red,
                                                    text:
                                                        'Google signin incomplete',
                                                    trailingIcon:
                                                        FontAwesomeIcons
                                                            .triangleExclamation,
                                                  ),
                                            );
                                          }
                                        });
                                  },
                          child:
                              isLoading
                                  ? const CircularProgressIndicator()
                                      .withMargin(right: 8)
                                  : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SvgPicture.asset(
                                        'lib/assets/svgs/google_icon.svg',
                                        height: 16,
                                        width: 16,
                                      ).withMargin(right: 8),
                                      Text(
                                        authState.state ==
                                                AuthState.authenticated
                                            ? 'Signed in with Google'
                                            : 'Sign in with Google',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w900,
                                          fontSize: 14,
                                          color: PaxColors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                        ),
                      ).withPadding(bottom: 16),
                    ],
                  )
                  : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.4,
                        height: 48,
                        child: Button(
                          style: const ButtonStyle.outline()
                              .withBackgroundColor(color: PaxColors.lightGrey)
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
                              color: PaxColors.deepPurple,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.4,
                        height: 48,
                        child: PrimaryButton(
                          onPressed: () {
                            // Go to next page
                            onboardingViewModel.goToNextPage();
                          },
                          child: Text(
                            'Continue',
                            style: Theme.of(context).typography.base.copyWith(
                              fontWeight: FontWeight.normal,
                              fontSize: 14,
                              color: PaxColors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ).withPadding(bottom: 16),
            ],
          ).withPadding(top: 32, bottom: 32),
        ],
      ),
    );
  }

  void showErrorToast(BuildContext toastContext) {
    showToast(
      context: toastContext,
      location: ToastLocation.topCenter,
      builder:
          (context, overlay) => Toast(
            leadingIcon: FontAwesomeIcons.google,
            toastColor: PaxColors.red,
            text: 'Sign-in failed',
            trailingIcon: FontAwesomeIcons.triangleExclamation,
          ),
    );
  }

  void showSuccessToast(BuildContext toastContext) {
    showToast(
      context: context,
      location: ToastLocation.topCenter,
      builder:
          (context, overlay) => Toast(
            leadingIcon: FontAwesomeIcons.google,
            toastColor: PaxColors.green,
            text: 'Sign-in complete',
            trailingIcon: FontAwesomeIcons.solidCircleCheck,
          ),
    );
  }
}

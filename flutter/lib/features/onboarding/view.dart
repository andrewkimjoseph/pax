import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart' show SvgPicture;
import 'package:go_router/go_router.dart';
import 'package:pax/features/onboarding/view_model.dart';
import 'package:pax/models/auth/auth_state_model.dart';
import 'package:pax/providers/auth/auth_provider.dart';
import 'package:pax/providers/db/participant_provider.dart';
import 'package:pax/providers/db/pax_account_provider.dart';
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
    // Watch the onboarding state
    ref.watch(onboardingViewModelProvider);

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
                    //     onboardingViewModel.isLastPage)
                    // _buildUserInfo(context, authState.user),
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
                                          // If sign in was successful
                                          if (ref.read(authProvider).state ==
                                              AuthState.authenticated) {
                                            // Navigate after successful sign in

                                            Future.delayed(
                                              const Duration(seconds: 1),
                                              () {
                                                // Check if participant is loaded
                                                if (ref
                                                        .read(
                                                          participantProvider,
                                                        )
                                                        .state ==
                                                    ParticipantState.loaded) {
                                                  // Navigate after successful sign in and participant loading
                                                  onboardingViewModel
                                                      .completeOnboarding();

                                                  if (context.mounted) {
                                                    context.pushReplacement(
                                                      '/',
                                                    );
                                                  }
                                                }
                                              },
                                            );

                                            if (context.mounted) {
                                              context.pushReplacement('/');
                                            }
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

  // Widget to show user information after successful sign in
  // Widget _buildUserInfo(BuildContext context, UserModel user) {
  //   return Container(
  //     margin: const EdgeInsets.only(top: 20),
  //     padding: const EdgeInsets.all(16),
  //     decoration: BoxDecoration(
  //       color: PaxColors.lightGrey.withOpacity(0.3),
  //       borderRadius: BorderRadius.circular(12),
  //     ),
  //     child: Column(
  //       children: [
  //         if (user.photoURL != null)
  //           CircleAvatar(
  //             radius: 24,
  //             backgroundImage: NetworkImage(user.photoURL!),
  //           ).withPadding(bottom: 8),
  //         Text(
  //           'Welcome, ${user.displayName ?? 'User'}!',
  //           style: Theme.of(context).typography.base.copyWith(
  //             fontWeight: FontWeight.w700,
  //             fontSize: 16,
  //             color: PaxColors.deepPurple,
  //           ),
  //         ),
  //         if (user.email != null)
  //           Text(
  //             user.email!,
  //             style: Theme.of(context).typography.base.copyWith(
  //               fontWeight: FontWeight.normal,
  //               fontSize: 12,
  //               color: PaxColors.black,
  //             ),
  //           ).withPadding(top: 4),
  //       ],
  //     ),
  //   );
  // }

  // Toast for successful sign in
  Widget buildToast(BuildContext context, ToastOverlay overlay) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.95,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [PaxColors.orange, PaxColors.pink],
          stops: [0.0, 1.0],
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(spreadRadius: 1, blurRadius: 4, offset: Offset(0, 2)),
        ],
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

  // Error toast when sign in fails
  Widget buildErrorToast(
    BuildContext context,
    ToastOverlay overlay,
    String message,
  ) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.95,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.red.shade600,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(spreadRadius: 1, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Basic(
        subtitle: Text(message, style: const TextStyle(color: PaxColors.white)),
        trailing: PrimaryButton(
          size: ButtonSize.small,
          onPressed: () {
            overlay.close();
          },
          child: const Text('Close'),
        ),
        trailingAlignment: Alignment.center,
      ),
    );
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:pax/exports/views.dart';
import 'package:pax/features/task/task_itself/view.dart';
import 'package:pax/models/auth/auth_state_model.dart';
import 'package:pax/providers/auth/auth_provider.dart';
import 'package:pax/providers/route/route_notifier_provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'routes.dart';

final routerProvider = Provider((ref) {
  final notifier = ref.watch(routerNotifierProvider);

  return GoRouter(
    refreshListenable: notifier,
    initialLocation: Routes.root,
    errorBuilder:
        (context, state) => Scaffold(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'lib/assets/svgs/canvassing.svg',
                height: 48,
              ).withPadding(bottom: 16),
              CircularProgressIndicator(),
            ],
          ),
        ),
    redirect: (context, state) {
      final authState = ref.read(authStateForRouterProvider);

      // If user is not authenticated and trying to access any route other than onboarding
      if (authState != AuthState.authenticated &&
          state.matchedLocation != Routes.onboarding) {
        // Redirect unauthenticated users to onboarding
        return Routes.onboarding;
      }

      // No redirection needed
      return null;
    },
    routes: [
      // Root
      GoRoute(
        path: Routes.root,
        builder:
            (BuildContext context, GoRouterState state) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.noScaling),
              child: RootView(),
            ),

        routes: [
          GoRoute(
            path: "onboarding",
            builder:
                (BuildContext context, GoRouterState state) => OnboardingView(),
          ),
          GoRoute(
            path: "wallet",
            builder:
                (BuildContext context, GoRouterState state) => WalletView(),
            routes: [
              GoRoute(
                path: "withdraw",
                builder:
                    (BuildContext context, GoRouterState state) =>
                        WithdrawView(),

                routes: [
                  GoRoute(
                    path: "select-wallet",
                    builder:
                        (BuildContext context, GoRouterState state) =>
                            SelectWalletView(),
                    routes: [
                      GoRoute(
                        path: "review-summary",
                        builder:
                            (BuildContext context, GoRouterState state) =>
                                ReviewSummaryView(),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: "profile",
            builder:
                (BuildContext context, GoRouterState state) => ProfileView(),
          ),
          GoRoute(
            path: "help-and-support",
            builder:
                (BuildContext context, GoRouterState state) =>
                    HelpAndSupportView(),
            routes: [
              GoRoute(
                path: "faq",
                builder:
                    (BuildContext context, GoRouterState state) => FAQView(),
              ),
              GoRoute(
                path: "contact-support",
                builder:
                    (BuildContext context, GoRouterState state) =>
                        ContactSupportView(),
              ),
            ],
          ),

          GoRoute(
            path: "/task-summary",
            builder:
                (BuildContext context, GoRouterState state) =>
                    TaskSummaryView(),
          ),
          GoRoute(
            path: "/task-itself",
            builder:
                (BuildContext context, GoRouterState state) => TaskItselfView(),
            routes: [],
          ),

          GoRoute(
            path: "task-complete",
            builder:
                (BuildContext context, GoRouterState state) =>
                    TaskCompleteView(),
          ),

          GoRoute(
            path: "payment-methods",
            builder:
                (BuildContext context, GoRouterState state) =>
                    PaymentMethodsView(),

            routes: [
              GoRoute(
                path: "minipay-connection",
                builder:
                    (BuildContext context, GoRouterState state) =>
                        MiniPayConnectionView(),
              ),
            ],
          ),

          // Home and sub-routes
        ],
      ),

      // Onboarding
    ],
  );
});

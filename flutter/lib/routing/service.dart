// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pax/exports/views.dart';
import 'routes.dart';

class RoutingService {
  static final GoRouter routerConfig = GoRouter(
    initialLocation: Routes.onboarding,
    routes: [
      // Root
      GoRoute(
        path: Routes.root,
        builder: (BuildContext context, GoRouterState state) => RootView(),

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
            path: "task",
            builder:
                (BuildContext context, GoRouterState state) => TaskPageView(),
            routes: [
              GoRoute(
                path: "task-complete",
                builder:
                    (BuildContext context, GoRouterState state) =>
                        TaskCompleteView(),
              ),
            ],
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
}

final routerConfig = RoutingService.routerConfig;

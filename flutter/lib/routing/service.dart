import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pax/exports/views.dart';
import 'package:pax/features/account_and_security/view.dart';
import 'package:pax/features/claim_reward/view.dart';
import 'package:pax/features/report_page/view.dart';
import 'package:pax/features/task/task_itself/view.dart';
import 'package:pax/features/webview/view.dart';
import 'package:pax/models/auth/auth_state_model.dart';
import 'package:pax/providers/auth/auth_provider.dart';
import 'package:pax/providers/route/route_notifier_provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'routes.dart';

final routerProvider = Provider((ref) {
  final notifier = ref.watch(routerNotifierProvider);

  return GoRouter(
    refreshListenable: notifier,
    initialLocation: Routes.home,
    errorBuilder: (context, state) {
      final authState = ref.read(authStateForRouterProvider);

      // Only redirect if there's an actual routing error
      if (state.error != null) {
        return StatefulBuilder(
          builder: (context, setState) {
            Future.microtask(() {
              if (context.mounted) {
                final route =
                    authState == AuthState.authenticated
                        ? Routes.home
                        : Routes.onboarding;
                GoRouter.of(context).go(route);
              }
            });
            return const Scaffold(child: SizedBox());
          },
        );
      }

      // If no routing error, just show empty screen
      return const Scaffold(child: SizedBox());
    },
    redirect: (context, state) {
      final authState = ref.read(authStateForRouterProvider);
      final isOnboardingRoute = state.matchedLocation == Routes.onboarding;

      // If not authenticated and not on onboarding, redirect to onboarding
      if (authState != AuthState.authenticated && !isOnboardingRoute) {
        return Routes.onboarding;
      }

      // If authenticated and on onboarding, redirect to home
      if (authState == AuthState.authenticated && isOnboardingRoute) {
        return Routes.home;
      }

      // If authenticated and route doesn't exist, redirect to home
      if (authState == AuthState.authenticated && state.error != null) {
        return Routes.home;
      }

      // If authenticated and on a valid route, stay there
      if (authState == AuthState.authenticated) {
        return null;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: Routes.home,
        builder:
            (BuildContext context, GoRouterState state) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.noScaling),
              child: RootView(),
            ),
      ),
      GoRoute(
        path: Routes.reportPage,
        builder: (context, state) => ReportPageView(state.extra as String),
      ),
      GoRoute(
        path: "/webview",
        builder: (context, state) => WebViewPage(url: state.extra as String),
      ),
      GoRoute(
        path: Routes.onboarding,
        builder: (context, state) => const OnboardingView(),
      ),
      GoRoute(
        path: Routes.activity,
        builder: (context, state) => const ActivityView(),
      ),
      GoRoute(
        path: Routes.accountAndSecurity,
        builder: (context, state) => const AccountAndSecurityView(),
      ),
      GoRoute(
        path: "/wallet",
        builder: (BuildContext context, GoRouterState state) => WalletView(),
        routes: [
          GoRoute(
            path: "withdraw",
            builder:
                (BuildContext context, GoRouterState state) => WithdrawView(),
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
        path: "/profile",
        builder: (BuildContext context, GoRouterState state) => ProfileView(),
      ),
      GoRoute(
        path: "/account-and-security",
        builder:
            (BuildContext context, GoRouterState state) =>
                AccountAndSecurityView(),
      ),
      GoRoute(
        path: "/help-and-support",
        builder:
            (BuildContext context, GoRouterState state) => HelpAndSupportView(),
        routes: [
          GoRoute(
            path: "faq",
            builder: (BuildContext context, GoRouterState state) => FAQView(),
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
            (BuildContext context, GoRouterState state) => TaskSummaryView(),
      ),
      GoRoute(
        path: "/task-itself",
        builder:
            (BuildContext context, GoRouterState state) => TaskItselfView(),
      ),
      GoRoute(
        path: "/task-complete",
        builder:
            (BuildContext context, GoRouterState state) => TaskCompleteView(),
      ),
      GoRoute(
        path: "/payment-methods",
        builder:
            (BuildContext context, GoRouterState state) => PaymentMethodsView(),
        routes: [
          GoRoute(
            path: "minipay-connection",
            builder:
                (BuildContext context, GoRouterState state) =>
                    MiniPayConnectionView(),
          ),
        ],
      ),
      GoRoute(
        path: "/claim-reward",
        builder:
            (BuildContext context, GoRouterState state) => ClaimRewardView(),
      ),
    ],
  );
});

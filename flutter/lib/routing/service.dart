// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pax/features/help_and_support/contact_support/view.dart';
import 'package:pax/features/help_and_support/faq/view.dart';
import 'package:pax/features/help_and_support/view.dart';
import 'package:pax/features/home/view.dart';
import 'package:pax/features/task_page/task_completed/view.dart';
import 'package:pax/features/task_page/view.dart';
import 'package:pax/features/payment_methods/minipay/view.dart';
import 'package:pax/features/payment_methods/view.dart';
import 'package:pax/features/profile/view.dart';
import 'package:pax/features/root/view.dart';
import 'package:pax/features/wallet/view.dart';
import 'package:pax/features/wallet/withdraw/select_wallet/review_summary/view.dart';
import 'package:pax/features/wallet/withdraw/select_wallet/view.dart';
import 'package:pax/features/wallet/withdraw/view.dart';
import '../features/onboarding/view.dart';
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
          GoRoute(
            path: Routes.home,
            builder: (BuildContext context, GoRouterState state) => HomeView(),
            routes: [
              GoRoute(
                path: 'dashboard',
                builder:
                    (BuildContext context, GoRouterState state) => Container(
                      color: Colors.amber.shade200,
                      child: const Center(child: Text('Dashboard View')),
                    ),
              ),
              GoRoute(
                path: 'tasks',
                builder:
                    (BuildContext context, GoRouterState state) => Container(
                      color: Colors.amber.shade300,
                      child: const Center(child: Text('Tasks View')),
                    ),
                routes: [
                  GoRoute(
                    path: ':task-id',
                    builder: (BuildContext context, GoRouterState state) {
                      final taskId = state.pathParameters['task-id'];
                      return Container(
                        color: Colors.amber.shade400,
                        child: Center(child: Text('Task Detail View: $taskId')),
                      );
                    },
                    routes: [
                      GoRoute(
                        path: 'rewarded',
                        builder: (BuildContext context, GoRouterState state) {
                          final taskId = state.pathParameters['task-id'];
                          return Container(
                            color: Colors.amber.shade500,
                            child: Center(
                              child: Text('Task Rewarded View: $taskId'),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
              GoRoute(
                path: 'achievements',
                builder:
                    (BuildContext context, GoRouterState state) => Container(
                      color: Colors.amber.shade600,
                      child: const Center(child: Text('Achievements View')),
                    ),
                routes: [
                  GoRoute(
                    path: 'all',
                    builder:
                        (BuildContext context, GoRouterState state) =>
                            Container(
                              color: Colors.amber.shade700,
                              child: const Center(
                                child: Text('All Achievements View'),
                              ),
                            ),
                  ),
                  GoRoute(
                    path: 'earned',
                    builder:
                        (BuildContext context, GoRouterState state) =>
                            Container(
                              color: Colors.amber.shade800,
                              child: const Center(
                                child: Text('Earned Achievements View'),
                              ),
                            ),
                  ),
                  GoRoute(
                    path: 'in-progress',
                    builder:
                        (BuildContext context, GoRouterState state) =>
                            Container(
                              color: Colors.amber.shade900,
                              child: const Center(
                                child: Text('In-Progress Achievements View'),
                              ),
                            ),
                  ),
                ],
              ),
            ],
          ),

          // Activity and sub-routes
          GoRoute(
            path: "activity",
            builder:
                (BuildContext context, GoRouterState state) => Container(
                  color: Colors.purple.shade100,
                  child: const Center(child: Text('Activity View')),
                ),
            routes: [
              GoRoute(
                path: 'all',
                builder:
                    (BuildContext context, GoRouterState state) => Container(
                      color: Colors.purple.shade200,
                      child: const Center(child: Text('All Activity View')),
                    ),
              ),
              GoRoute(
                path: 'task-completions',
                builder:
                    (BuildContext context, GoRouterState state) => Container(
                      color: Colors.purple.shade300,
                      child: const Center(child: Text('Task Completions View')),
                    ),
              ),
            ],
          ),

          // Account and sub-routes
          GoRoute(
            path: Routes.account,
            builder:
                (BuildContext context, GoRouterState state) => Container(
                  color: Colors.teal.shade100,
                  child: const Center(child: Text('Account View')),
                ),
            routes: [
              GoRoute(
                path: 'profile',
                builder:
                    (BuildContext context, GoRouterState state) => Container(
                      color: Colors.teal.shade200,
                      child: const Center(child: Text('Profile View')),
                    ),
              ),
              GoRoute(
                path: 'payment-methods',
                builder:
                    (BuildContext context, GoRouterState state) => Container(
                      color: Colors.teal.shade300,
                      child: const Center(child: Text('Payment Methods View')),
                    ),
              ),
              GoRoute(
                path: 'help-and-support',
                builder:
                    (BuildContext context, GoRouterState state) => Container(
                      color: Colors.teal.shade400,
                      child: const Center(child: Text('Help and Support View')),
                    ),
                routes: [
                  GoRoute(
                    path: 'faqs',
                    builder:
                        (BuildContext context, GoRouterState state) =>
                            Container(
                              color: Colors.teal.shade500,
                              child: const Center(child: Text('FAQs View')),
                            ),
                  ),
                  GoRoute(
                    path: 'contact-support',
                    builder:
                        (BuildContext context, GoRouterState state) =>
                            Container(
                              color: Colors.teal.shade600,
                              child: const Center(
                                child: Text('Contact Support View'),
                              ),
                            ),
                  ),
                ],
              ),
              GoRoute(
                path: 'security',
                builder:
                    (BuildContext context, GoRouterState state) => Container(
                      color: Colors.teal.shade700,
                      child: const Center(child: Text('Security View')),
                    ),
              ),
            ],
          ),

          // Wallet and sub-routes
          GoRoute(
            path: "wallet",
            builder:
                (BuildContext context, GoRouterState state) => Container(
                  color: Colors.orange.shade100,
                  child: const Center(child: Text('Wallet View')),
                ),
            routes: [
              GoRoute(
                path: 'withdraw',
                builder:
                    (BuildContext context, GoRouterState state) => Container(
                      color: Colors.orange.shade200,
                      child: const Center(child: Text('Withdraw View')),
                    ),
                routes: [
                  GoRoute(
                    path: 'enter-amount',
                    builder:
                        (BuildContext context, GoRouterState state) =>
                            Container(
                              color: Colors.orange.shade300,
                              child: const Center(
                                child: Text('Enter Amount View'),
                              ),
                            ),
                    routes: [
                      GoRoute(
                        path: 'select-wallet',
                        builder:
                            (BuildContext context, GoRouterState state) =>
                                Container(
                                  color: Colors.orange.shade400,
                                  child: const Center(
                                    child: Text('Select Wallet View'),
                                  ),
                                ),
                        routes: [
                          GoRoute(
                            path: 'complete',
                            builder:
                                (BuildContext context, GoRouterState state) =>
                                    Container(
                                      color: Colors.orange.shade500,
                                      child: const Center(
                                        child: Text('Withdraw Complete View'),
                                      ),
                                    ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              GoRoute(
                path: 'connect',
                builder:
                    (BuildContext context, GoRouterState state) => Container(
                      color: Colors.orange.shade600,
                      child: const Center(child: Text('Connect View')),
                    ),
                routes: [
                  GoRoute(
                    path: ':payment-method-id',
                    builder: (BuildContext context, GoRouterState state) {
                      final paymentMethodId =
                          state.pathParameters['payment-method-id'];
                      return Container(
                        color: Colors.orange.shade700,
                        child: Center(
                          child: Text(
                            'Connect Payment Method View: $paymentMethodId',
                          ),
                        ),
                      );
                    },
                    routes: [
                      GoRoute(
                        path: 'enter-wallet-identifier',
                        builder: (BuildContext context, GoRouterState state) {
                          final paymentMethodId =
                              state.pathParameters['payment-method-id'];
                          return Container(
                            color: Colors.orange.shade800,
                            child: Center(
                              child: Text(
                                'Enter Wallet Identifier View: $paymentMethodId',
                              ),
                            ),
                          );
                        },
                        routes: [
                          GoRoute(
                            path: 'completed',
                            builder: (
                              BuildContext context,
                              GoRouterState state,
                            ) {
                              final paymentMethodId =
                                  state.pathParameters['payment-method-id'];
                              return Container(
                                color: Colors.orange.shade900,
                                child: Center(
                                  child: Text(
                                    'Connect Completed View: $paymentMethodId',
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),

          // Notifications and sub-routes
          GoRoute(
            path: "notifications",
            builder:
                (BuildContext context, GoRouterState state) => Container(
                  color: Colors.indigo.shade100,
                  child: const Center(child: Text('Notifications View')),
                ),
            routes: [
              GoRoute(
                path: ':id',
                builder: (BuildContext context, GoRouterState state) {
                  final notificationId = state.pathParameters['id'];
                  return Container(
                    color: Colors.indigo.shade200,
                    child: Center(
                      child: Text('Notification Detail View: $notificationId'),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),

      // Onboarding
    ],
  );
}

final routerConfig = RoutingService.routerConfig;

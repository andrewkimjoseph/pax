import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pax/exports/views.dart';
import 'package:pax/providers/analytics/analytics_provider.dart';
import 'package:pax/providers/remote_config/remote_config_provider.dart';
import 'package:flutter/foundation.dart';

import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../theming/colors.dart' show PaxColors;

class HomeView extends ConsumerStatefulWidget {
  const HomeView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView> {
  int index = 0;
  String? screenName;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final featureFlags = ref.watch(featureFlagsProvider);

    return Scaffold(
      headers: [
        AppBar(
          height: 87.5,
          padding: EdgeInsets.all(8),
          backgroundColor: PaxColors.white,
          header: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                screenName ?? 'Dashboard',
                style: Theme.of(context).typography.base.copyWith(
                  fontWeight: FontWeight.w900,
                  fontSize: 32,
                  color: PaxColors.black,
                ),
              ),

              // GestureDetector(
              //   onPanDown:
              //       (details) => Navigator.push(
              //         context,
              //         MaterialPageRoute(
              //           builder: (context) => NotificationsView(),
              //         ),
              //       ),

              //   child: SvgPicture.asset(
              //     'lib/assets/svgs/active_notification.svg',
              //   ),
              // ),
            ],
          ).withPadding(bottom: 8),
          subtitle: Column(
            children: [
              Row(
                children: [
                  Button(
                    style: const ButtonStyle.primary(
                          density: ButtonDensity.dense,
                        )
                        .withBackgroundColor(
                          color:
                              index == 0
                                  ? PaxColors.deepPurple
                                  : Colors.transparent,
                        )
                        .withBorder(
                          border: Border.all(
                            color:
                                index == 0
                                    ? PaxColors.deepPurple
                                    : PaxColors.lilac,
                            width: 2,
                          ),
                        )
                        .withBorderRadius(
                          borderRadius: BorderRadius.circular(7),
                        ),
                    onPressed: () {
                      setState(() {
                        screenName = 'Dashboard';
                        index = 0;
                      });
                      ref.read(analyticsProvider).dashboardTapped();
                    },
                    child: Text(
                      'Dashboard',
                      style: TextStyle(
                        color: index == 0 ? PaxColors.white : PaxColors.black,
                      ),
                    ),
                  ).withPadding(right: 8),
                  featureFlags.when(
                    data:
                        (flags) =>
                            kDebugMode || flags['are_tasks_available'] == true
                                ? Button(
                                  style: const ButtonStyle.primary(
                                        density: ButtonDensity.dense,
                                      )
                                      .withBackgroundColor(
                                        color:
                                            index == 1
                                                ? PaxColors.deepPurple
                                                : Colors.transparent,
                                      )
                                      .withBorder(
                                        border: Border.all(
                                          color:
                                              index == 1
                                                  ? PaxColors.deepPurple
                                                  : PaxColors.lilac,
                                          width: 2,
                                        ),
                                      )
                                      .withBorderRadius(
                                        borderRadius: BorderRadius.circular(7),
                                      ),
                                  onPressed: () {
                                    setState(() {
                                      screenName = 'Tasks';
                                      index = 1;
                                    });
                                    ref.read(analyticsProvider).tasksTapped();
                                  },
                                  child: Text(
                                    'Tasks',
                                    style: TextStyle(
                                      color:
                                          index == 1
                                              ? PaxColors.white
                                              : PaxColors.black,
                                    ),
                                  ),
                                ).withPadding(right: 8)
                                : const SizedBox.shrink(),
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                  featureFlags.when(
                    data:
                        (flags) =>
                            kDebugMode ||
                                    flags['is_achievements_available'] == true
                                ? Button(
                                  style: const ButtonStyle.primary(
                                        density: ButtonDensity.dense,
                                      )
                                      .withBackgroundColor(
                                        color:
                                            index == 2
                                                ? PaxColors.deepPurple
                                                : Colors.transparent,
                                      )
                                      .withBorder(
                                        border: Border.all(
                                          color:
                                              index == 2
                                                  ? PaxColors.deepPurple
                                                  : PaxColors.lilac,
                                          width: 2,
                                        ),
                                      )
                                      .withBorderRadius(
                                        borderRadius: BorderRadius.circular(7),
                                      ),
                                  onPressed: () {
                                    setState(() {
                                      screenName = 'Achievements';
                                      index = 2;
                                    });
                                  },
                                  child: Text(
                                    'Achievements',
                                    style: TextStyle(
                                      color:
                                          index == 2
                                              ? PaxColors.white
                                              : PaxColors.black,
                                    ),
                                  ),
                                ).withPadding(right: 8)
                                : const SizedBox.shrink(),
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                ],
              ),
            ],
          ),
        ),
        Divider(color: PaxColors.lightGrey),
      ],
      child: IndexedStack(
        index: index,
        children: [
          DashboardView(),
          featureFlags.when(
            data:
                (flags) =>
                    kDebugMode || flags['are_tasks_available'] == true
                        ? TasksView()
                        : const SizedBox.shrink(),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          featureFlags.when(
            data:
                (flags) =>
                    kDebugMode || flags['is_achievements_available'] == true
                        ? AchievementsView()
                        : const SizedBox.shrink(),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  // Widget buildToast(BuildContext context, ToastOverlay overlay) {

  // }
}

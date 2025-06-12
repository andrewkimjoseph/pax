import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pax/exports/views.dart';
import 'package:pax/providers/analytics/analytics_provider.dart';
import 'package:pax/providers/remote_config/remote_config_provider.dart';
import 'package:pax/utils/remote_config_constants.dart';
import 'package:flutter/foundation.dart';
import 'package:pax/providers/db/participant/participant_provider.dart';
import 'package:pax/providers/db/tasks/task_provider.dart';
import 'package:pax/providers/route/home_selected_index_provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' hide Consumer;
import '../../theming/colors.dart' show PaxColors;

class HomeView extends ConsumerStatefulWidget {
  const HomeView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView> {
  String? screenName;

  @override
  Widget build(BuildContext context) {
    final featureFlags = ref.watch(featureFlagsProvider);
    final index = ref.watch(homeSelectedIndexProvider);

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
                      });
                      ref.read(homeSelectedIndexProvider.notifier).setIndex(0);
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
                            kDebugMode ||
                                    flags[RemoteConfigKeys.areTasksAvailable] ==
                                        true
                                ? Consumer(
                                  builder: (context, ref, child) {
                                    final participant =
                                        ref
                                            .watch(participantProvider)
                                            .participant;
                                    final tasksStream = ref.watch(
                                      availableTasksStreamProvider(
                                        participant?.id,
                                      ),
                                    );

                                    return tasksStream.when(
                                      data:
                                          (tasks) => Button(
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
                                                            ? PaxColors
                                                                .deepPurple
                                                            : tasks.isEmpty
                                                            ? PaxColors.lilac
                                                            : PaxColors.green,
                                                    width: 2,
                                                  ),
                                                )
                                                .withBorderRadius(
                                                  borderRadius:
                                                      BorderRadius.circular(7),
                                                ),
                                            onPressed: () {
                                              setState(() {
                                                screenName = 'Tasks';
                                              });
                                              ref
                                                  .read(
                                                    homeSelectedIndexProvider
                                                        .notifier,
                                                  )
                                                  .setIndex(1);
                                              ref
                                                  .read(analyticsProvider)
                                                  .tasksTapped();
                                            },
                                            child: Row(
                                              children: [
                                                Text(
                                                  'Tasks',
                                                  style: TextStyle(
                                                    color:
                                                        index == 1
                                                            ? PaxColors.white
                                                            : PaxColors.black,
                                                  ),
                                                ).withPadding(
                                                  right:
                                                      tasks.isNotEmpty ? 8 : 0,
                                                ),
                                                tasks.isNotEmpty
                                                    ? FaIcon(
                                                      FontAwesomeIcons
                                                          .solidCircle,
                                                      size: 12,
                                                      color: PaxColors.green,
                                                    )
                                                    : const SizedBox.shrink(),
                                              ],
                                            ),
                                          ).withPadding(right: 8),
                                      loading:
                                          () => Button(
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
                                                            ? PaxColors
                                                                .deepPurple
                                                            : PaxColors.lilac,
                                                    width: 2,
                                                  ),
                                                )
                                                .withBorderRadius(
                                                  borderRadius:
                                                      BorderRadius.circular(7),
                                                ),
                                            onPressed: () {
                                              setState(() {
                                                screenName = 'Tasks';
                                              });
                                              ref
                                                  .read(
                                                    homeSelectedIndexProvider
                                                        .notifier,
                                                  )
                                                  .setIndex(1);
                                              ref
                                                  .read(analyticsProvider)
                                                  .tasksTapped();
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
                                          ).withPadding(right: 8),
                                      error:
                                          (_, __) => Button(
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
                                                            ? PaxColors
                                                                .deepPurple
                                                            : PaxColors.lilac,
                                                    width: 2,
                                                  ),
                                                )
                                                .withBorderRadius(
                                                  borderRadius:
                                                      BorderRadius.circular(7),
                                                ),
                                            onPressed: () {
                                              setState(() {
                                                screenName = 'Tasks';
                                              });
                                              ref
                                                  .read(
                                                    homeSelectedIndexProvider
                                                        .notifier,
                                                  )
                                                  .setIndex(1);
                                              ref
                                                  .read(analyticsProvider)
                                                  .tasksTapped();
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
                                          ).withPadding(right: 8),
                                    );
                                  },
                                )
                                : const SizedBox.shrink(),
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                  featureFlags.when(
                    data:
                        (flags) =>
                            kDebugMode ||
                                    flags[RemoteConfigKeys
                                            .areAchievementsAvailable] ==
                                        true
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
                                    });
                                    ref
                                        .read(
                                          homeSelectedIndexProvider.notifier,
                                        )
                                        .setIndex(2);
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
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(opacity: animation, child: child);
        },
        child:
            index == 0
                ? DashboardView(key: const ValueKey('dashboard'))
                : index == 1
                ? featureFlags.when(
                  data:
                      (flags) =>
                          kDebugMode ||
                                  flags[RemoteConfigKeys.areTasksAvailable] ==
                                      true
                              ? TasksView(key: const ValueKey('tasks'))
                              : const SizedBox.shrink(
                                key: ValueKey('empty_tasks'),
                              ),
                  loading:
                      () =>
                          const SizedBox.shrink(key: ValueKey('loading_tasks')),
                  error:
                      (_, __) =>
                          const SizedBox.shrink(key: ValueKey('error_tasks')),
                )
                : featureFlags.when(
                  data:
                      (flags) =>
                          kDebugMode ||
                                  flags[RemoteConfigKeys
                                          .areAchievementsAvailable] ==
                                      true
                              ? AchievementsView(
                                key: const ValueKey('achievements'),
                              )
                              : const SizedBox.shrink(
                                key: ValueKey('empty_achievements'),
                              ),
                  loading:
                      () => const SizedBox.shrink(
                        key: ValueKey('loading_achievements'),
                      ),
                  error:
                      (_, __) => const SizedBox.shrink(
                        key: ValueKey('error_achievements'),
                      ),
                ),
      ),
    );
  }

  // Widget buildToast(BuildContext context, ToastOverlay overlay) {

  // }
}

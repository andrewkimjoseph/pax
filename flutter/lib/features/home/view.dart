import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart' show SvgPicture;
import 'package:pax/exports/views.dart';
import 'package:pax/features/notifications/view.dart';

import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../theming/colors.dart' show PaxColors;

class HomeView extends ConsumerStatefulWidget {
  const HomeView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView> {
  int index = 0;
  int selected = 0;
  String? screenName;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      headers: [
        AppBar(
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
                  color: PaxColors.black, // The purple color from your images
                ),
              ),

              GestureDetector(
                onPanDown:
                    (details) => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NotificationsView(),
                      ),
                    ),

                child: SvgPicture.asset(
                  'lib/assets/svgs/active_notification.svg',
                ),
              ),
            ],
          ).withPadding(bottom: 8),
          subtitle: Row(
            children: [
              Button(
                style: const ButtonStyle.primary(density: ButtonDensity.dense)
                    .withBackgroundColor(
                      color:
                          index == 0
                              ? PaxColors.deepPurple
                              : Colors.transparent,
                    )
                    .withBorder(
                      border: Border.all(
                        color:
                            index == 0 ? PaxColors.deepPurple : PaxColors.lilac,
                        width: 2,
                      ),
                    )
                    .withBorderRadius(borderRadius: BorderRadius.circular(7)),
                onPressed: () {
                  setState(() {
                    screenName = 'Dashboard';
                    index = 0;
                  });

                  // showToast(
                  //   context: context,
                  //   builder:
                  //       (context, overlay) => Container(
                  //         padding: EdgeInsets.all(12),
                  //         decoration: BoxDecoration(
                  //           gradient: LinearGradient(
                  //             colors: PaxColors.orangeToPinkGradient,
                  //           ),
                  //           borderRadius: BorderRadius.circular(15),
                  //         ),
                  //         child: Basic(
                  //           title: const Text('Event has been created'),
                  //           subtitle: const Text(
                  //             'Sunday, July 07, 2024 at 12:00 PM',
                  //           ),
                  //           trailing: PrimaryButton(
                  //             size: ButtonSize.small,
                  //             onPressed: () {
                  //               overlay.close();
                  //             },
                  //             child: const Text('Undo'),
                  //           ),
                  //           trailingAlignment: Alignment.center,
                  //         ),
                  //       ),
                  //   location: ToastLocation.bottomCenter,
                  // );
                },

                child: Text(
                  'Dashboard',
                  style: TextStyle(
                    color: index == 0 ? PaxColors.white : PaxColors.black,
                  ),
                ),
              ).withPadding(right: 8),
              Button(
                style: const ButtonStyle.primary(density: ButtonDensity.dense)
                    .withBackgroundColor(
                      color:
                          index == 1
                              ? PaxColors.deepPurple
                              : Colors.transparent,
                    )
                    .withBorder(
                      border: Border.all(
                        color:
                            index == 1 ? PaxColors.deepPurple : PaxColors.lilac,
                        width: 2,
                      ),
                    )
                    .withBorderRadius(borderRadius: BorderRadius.circular(7)),
                onPressed: () {
                  setState(() {
                    screenName = 'Tasks';
                    index = 1;
                  });
                },

                child: Text(
                  'Tasks',
                  style: TextStyle(
                    color: index == 1 ? PaxColors.white : PaxColors.black,
                  ),
                ),
              ).withPadding(right: 8),

              Button(
                style: const ButtonStyle.primary(density: ButtonDensity.dense)
                    .withBackgroundColor(
                      color:
                          index == 2
                              ? PaxColors.deepPurple
                              : Colors.transparent,
                    )
                    .withBorder(
                      border: Border.all(
                        color:
                            index == 2 ? PaxColors.deepPurple : PaxColors.lilac,
                        width: 2,
                      ),
                    )
                    .withBorderRadius(borderRadius: BorderRadius.circular(7)),
                onPressed: () {
                  setState(() {
                    screenName = 'Achievements';
                    index = 2;
                  });
                },

                child: Text(
                  'Achievements',
                  style: TextStyle(
                    color: index == 2 ? PaxColors.white : PaxColors.black,
                  ),
                ),
              ).withPadding(right: 8),
            ],
          ),
        ),
      ],

      child: IndexedStack(
        index: index,
        children: [DashboardView(), TasksView(), AchievementsView()],
      ),
    );
  }

  // Widget buildToast(BuildContext context, ToastOverlay overlay) {

  // }
}

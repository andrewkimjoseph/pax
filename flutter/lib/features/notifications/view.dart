// ignore_for_file: unused_import

import 'package:flutter/material.dart' show Divider;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart' show SvgPicture;
import 'package:go_router/go_router.dart';
import 'package:pax/features/home/achievements/view.dart';
import 'package:pax/features/home/dashboard/view.dart';
import 'package:pax/features/home/tasks/view.dart';
import 'package:pax/features/onboarding/view_model.dart';
import 'package:pax/widgets/account_option_card.dart';
import 'package:pax/widgets/help_and_support.dart';
import 'package:pax/widgets/notification_card.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' hide Divider;
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../theming/colors.dart' show PaxColors;
import '../../utils/clipper.dart';

class NotificationsView extends ConsumerStatefulWidget {
  const NotificationsView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _NotificationsViewState();
}

class _NotificationsViewState extends ConsumerState<NotificationsView> {
  String? selectedValue;
  String? genderValue;
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
          child: Row(
            children: [
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onPanDown: (details) {
                  context.pop();
                },
                child: SvgPicture.asset('lib/assets/svgs/arrow_left_long.svg'),
              ),
              Spacer(),
              Text(
                "Notifications",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20),
              ).withPadding(right: 16),
              Spacer(),
            ],
          ),
        ).withPadding(top: 16),
        Divider(color: PaxColors.lightGrey),
      ],

      child: SingleChildScrollView(
        child: Column(
          children: [
            Column(
              spacing: 12,
              children: [
                NotificationCard('New Survey Alert', 'NT'),
                NotificationCard('New Survey Alert', 'NT'),
                NotificationCard('New Survey Alert', 'NT'),
                NotificationCard('New Survey Alert', 'NT'),
                NotificationCard('New Survey Alert', 'NT'),
                NotificationCard('New Survey Alert', 'NT'),
                NotificationCard('New Survey Alert', 'NT'),
                NotificationCard('New Survey Alert', 'NT'),
              ],
            ),
          ],
        ),
      ).withPadding(all: 8),
    );
  }
}

// String? selectedValue;
// @override
// Widget build(BuildContext context) {
//   return 
// }


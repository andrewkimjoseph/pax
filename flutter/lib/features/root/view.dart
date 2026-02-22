import 'package:flutter/material.dart' show Badge;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pax/exports/views.dart';
import 'package:pax/providers/db/achievement/achievement_provider.dart';
import 'package:pax/providers/local/activity_providers.dart';
import 'package:pax/providers/route/root_selected_index_provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import '../../theming/colors.dart' show PaxColors;
import 'package:pax/utils/achievement_constants.dart';

class RootView extends ConsumerStatefulWidget {
  const RootView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _RootViewState();
}

class _RootViewState extends ConsumerState<RootView> {
  @override
  Widget build(BuildContext context) {
    final selected = ref.watch(rootSelectedIndexProvider);

    return Scaffold(
      footers: [
        const Divider(),
        SizedBox(
          child: IntrinsicHeight(
            child: NavigationBar(
              alignment: NavigationBarAlignment.spaceBetween,
              labelType: NavigationLabelType.expanded,
              expanded: true,
              expands: false,
              onSelected: (index) {
                ref.read(rootSelectedIndexProvider.notifier).setIndex(index);
              },
              index: selected,
              children: [
                buildButton('Home', selected == 0, badgeCount: null),
                buildButton(
                  'Activity',
                  selected == 1,
                  badgeCount: ref
                      .watch(unclaimedTaskCompletionsCountProvider)
                      .maybeWhen(data: (c) => c, orElse: () => null),
                ),
                buildButton('Account', selected == 2, badgeCount: null),
              ],
            ),
          ),
        ),
      ],
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(opacity: animation, child: child);
        },
        child:
            selected == 0
                ? HomeView(key: const ValueKey('home'))
                : selected == 1
                ? ActivityView(key: const ValueKey('activity'))
                : AccountView(key: const ValueKey('account')),
      ),
    );
  }

  IconData _getIconForLabel(String label) {
    switch (label) {
      case 'Home':
        return FontAwesomeIcons.house;
      case 'Activity':
        return FontAwesomeIcons.chartLine;
      case 'Account':
        return FontAwesomeIcons.circleUser;
      default:
        return FontAwesomeIcons.circle;
    }
  }

  NavigationItem buildButton(
    String label,
    bool isSelected, {
    int? badgeCount,
  }) {
    final achievementState = ref.watch(achievementsProvider);

    // Check for the presence of all three required achievements
    final requiredAchievements = [
      AchievementConstants.payoutConnector,
      AchievementConstants.profilePerfectionist,
      AchievementConstants.verifiedHuman,
      AchievementConstants.doublePayoutConnector,
    ];
    final userAchievementNames =
        achievementState.achievements
            .map((a) => a.name)
            .whereType<String>()
            .toSet();
    final hasAllRequired = requiredAchievements.every(
      (ach) => userAchievementNames.contains(ach),
    );

    final showAccountBadge =
        label == 'Account' &&
        achievementState.state == AchievementState.loaded &&
        !hasAllRequired;
    final showActivityBadge =
        label == 'Activity' && badgeCount != null && badgeCount > 0;

    return NavigationItem(
      style: const ButtonStyle.ghost(density: ButtonDensity.icon),
      selectedStyle: const ButtonStyle.ghost(density: ButtonDensity.icon),
      label: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          color: isSelected ? PaxColors.deepPurple : PaxColors.lilac,
          fontWeight: FontWeight.w900,
        ),
      ),
      child: Badge(
        isLabelVisible: showAccountBadge || showActivityBadge,
        offset: const Offset(10, -5),
        label: showActivityBadge
            ? Text(
                badgeCount > 99 ? '99+' : '$badgeCount',
                style: TextStyle(
                  fontSize: 10,
                  color: PaxColors.white,
                  fontWeight: FontWeight.w600,
                ),
              )
            : const Text(''),
        backgroundColor: PaxColors.red,
        smallSize: 10,
        child: FaIcon(
          _getIconForLabel(label),
          size: 24,
          color: isSelected ? PaxColors.deepPurple : PaxColors.lilac,
        ),
      ),
    );
  }
}

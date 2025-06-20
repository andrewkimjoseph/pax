import 'package:flutter/material.dart' show Badge;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart' show SvgPicture;
import 'package:pax/exports/views.dart';
import 'package:pax/providers/db/achievement/achievement_provider.dart';
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
                buildButton('Home', selected == 0),
                buildButton('Activity', selected == 1),
                buildButton('Account', selected == 2),
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

  NavigationItem buildButton(String label, bool isSelected) {
    final achievementState = ref.watch(achievementsProvider);

    // Check for the presence of all three required achievements
    final requiredAchievements = [
      AchievementConstants.payoutConnector,
      AchievementConstants.profilePerfectionist,
      AchievementConstants.verifiedHuman,
    ];
    final userAchievementNames =
        achievementState.achievements
            .map((a) => a.name)
            .whereType<String>()
            .toSet();
    final hasAllRequired = requiredAchievements.every(
      (ach) => userAchievementNames.contains(ach),
    );

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
        isLabelVisible: label == 'Account' && !hasAllRequired,
        offset: const Offset(10, -5),
        label: Text(""),
        backgroundColor: PaxColors.red,

        smallSize: 10,
        child: SvgPicture.asset(
          isSelected
              ? 'lib/assets/svgs/${label.toLowerCase()}_selected.svg'
              : 'lib/assets/svgs/${label.toLowerCase()}_unselected.svg',
          height: 24,
        ),
      ),
    );
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart' show SvgPicture;
import 'package:pax/exports/views.dart';
import 'package:pax/providers/route/selected_index_provider.dart';

import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../theming/colors.dart' show PaxColors;

class RootView extends ConsumerStatefulWidget {
  const RootView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _RootViewState();
}

class _RootViewState extends ConsumerState<RootView> {
  @override
  Widget build(BuildContext context) {
    final selected = ref.watch(selectedIndexProvider);

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
                ref.read(selectedIndexProvider.notifier).setIndex(index);
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

      child: IndexedStack(
        index: selected,
        children: [HomeView(), ActivityView(), AccountView()],
      ),
    );
  }

  NavigationItem buildButton(String label, bool isSelected) {
    return NavigationItem(
      style: const ButtonStyle.muted(density: ButtonDensity.icon),
      selectedStyle: const ButtonStyle.fixed(density: ButtonDensity.icon),
      label: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          color: isSelected ? PaxColors.deepPurple : PaxColors.lilac,
          fontWeight: FontWeight.w900,
        ),
      ),
      child: SvgPicture.asset(
        isSelected
            ? 'lib/assets/svgs/${label.toLowerCase()}_selected.svg'
            : 'lib/assets/svgs/${label.toLowerCase()}_unselected.svg',
        height: 24,
      ),
    );
  }
}

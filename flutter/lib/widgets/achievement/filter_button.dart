import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pax/theming/colors.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class FilterButton extends ConsumerWidget {
  const FilterButton({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onPressed,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Button(
      style: const ButtonStyle.primary(density: ButtonDensity.dense)
          .withBackgroundColor(
            color: isSelected ? PaxColors.deepPurple : Colors.transparent,
          )
          .withBorder(
            border: Border.all(
              color: isSelected ? PaxColors.deepPurple : PaxColors.lilac,
              width: 2,
            ),
          )
          .withBorderRadius(borderRadius: BorderRadius.circular(7)),
      onPressed: onPressed,
      child: Text(
        label,
        style: TextStyle(color: isSelected ? PaxColors.white : PaxColors.black),
      ),
    ).withPadding(right: 8);
  }
}

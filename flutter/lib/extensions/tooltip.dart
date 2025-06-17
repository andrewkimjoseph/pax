import 'package:pax/exports/shadcn.dart';
import 'package:pax/theming/colors.dart';

extension WithTooltip on Widget {
  Widget withToolTip(String tip, {bool showTooltip = true}) {
    if (!showTooltip) return this;
    return Tooltip(
      tooltip:
          (context) => Container(
            decoration: BoxDecoration(
              // border: Border.all(),
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(colors: PaxColors.orangeToPinkGradient),
            ),
            child: Text(
              tip,
              style: TextStyle(color: PaxColors.white),
            ).withPadding(all: 8),
          ),
      child: this,
    );
  }
}

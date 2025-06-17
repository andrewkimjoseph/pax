import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pax/theming/colors.dart';
import 'package:pax/utils/currency_symbol.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class SelectCurrencyButton extends ConsumerStatefulWidget {
  const SelectCurrencyButton(this.value, this.isSelected, {super.key});

  final String value;
  final bool isSelected;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _SelectCurrencyButtonState();
}

class _SelectCurrencyButtonState extends ConsumerState<SelectCurrencyButton> {
  @override
  Widget build(BuildContext context) {
    return SelectItemButton<String>(
      value: widget.value,
      style: ButtonStyle.ghost().withBackgroundColor(
        color: widget.isSelected ? PaxColors.lightLilac : null,
      ),

      child: Row(
        children: [
          SvgPicture.asset(
            'lib/assets/svgs/currencies/${widget.value}.svg',

            height: widget.value == 'good_dollar' ? 25 : 18,
          ).withPadding(right: 4),
          Text(CurrencySymbolUtil.getSymbolForCurrency(widget.value)),
        ],
      ),
    );
  }
}

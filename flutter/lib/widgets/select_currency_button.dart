import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class SelectCurrencyButton extends ConsumerStatefulWidget {
  const SelectCurrencyButton(this.value, {super.key});

  final String value;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _SelectCurrencyButtonState();
}

class _SelectCurrencyButtonState extends ConsumerState<SelectCurrencyButton> {
  @override
  Widget build(BuildContext context) {
    return SelectItemButton<String>(
      value: widget.value,
      child: Row(
        children: [
          SvgPicture.asset(
            'lib/assets/svgs/currencies/${widget.value}.svg',

            height: 25,
          ).withPadding(right: 4),
          Text(widget.value),
        ],
      ),
    );
  }
}

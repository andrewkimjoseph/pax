import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pax/theming/colors.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class WithdrawalOptionCard extends ConsumerStatefulWidget {
  const WithdrawalOptionCard(
    this.option,
    this.paymentMethodName,
    this.callBack, {
    super.key,
  });

  final String option;

  final String paymentMethodName;

  final VoidCallback callBack;

  @override
  ConsumerState<WithdrawalOptionCard> createState() =>
      _WithdrawalOptionCardState();
}

class _WithdrawalOptionCardState extends ConsumerState<WithdrawalOptionCard> {
  CheckboxState _state = CheckboxState.unchecked;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(7),
          child: SvgPicture.asset(
            'lib/assets/svgs/${widget.option}.svg',
            height: 48,
          ),
        ).withPadding(right: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  widget.paymentMethodName,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                    color: PaxColors.black,
                  ),
                ),
              ],
            ).withPadding(bottom: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  'Dollar stablecoin wallet',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    color: PaxColors.lilac,
                  ),
                ),
              ],
            ).withPadding(bottom: 8),
          ],
        ),
        Spacer(),
        Checkbox(
          state: _state,
          onChanged: (value) {
            setState(() {
              _state = value;
            });
          },
        ),
      ],
    );
  }
}

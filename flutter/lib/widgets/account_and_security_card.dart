import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pax/theming/colors.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class AccountAndSecurityCard extends ConsumerWidget {
  const AccountAndSecurityCard(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,

      // padding: EdgeInsets.all(10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      label,

                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                        color: PaxColors.red,
                      ),
                    ),
                  ],
                ).withPadding(bottom: 8),
              ),
            ],
          ),
          Spacer(flex: 1),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SvgPicture.asset(
                      'lib/assets/svgs/arrow_right.svg',

                      // height: 24,
                    ),
                  ],
                ).withPadding(bottom: 8),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pax/theming/colors.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:intl/intl.dart' show toBeginningOfSentenceCase;

class AccountOptionCard extends ConsumerWidget {
  const AccountOptionCard(this.option, this.isEarned, {super.key});

  final String option;

  final bool isEarned;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,

      // padding: EdgeInsets.all(10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SvgPicture.asset(
            'lib/assets/svgs/$option.svg',

            // height: 24,
          ).withPadding(right: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      option == 'profile'
                          ? 'My Profile'
                          : option == 'account'
                          ? 'Account & Security'
                          : option == 'payment_methods'
                          ? 'Withdrawal Methods'
                          : option == 'help_and_support'
                          ? 'Help & Support'
                          : option == 'logout'
                          ? 'Logout'
                          : toBeginningOfSentenceCase(option.split('_')[0]),

                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                        color:
                            option == 'logout' ? Colors.red : PaxColors.black,
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

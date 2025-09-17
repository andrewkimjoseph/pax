import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pax/theming/colors.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class ContactSupportCard extends ConsumerWidget {
  const ContactSupportCard(this.channel, this.icon, {super.key});

  final String channel;

  final String icon;
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
                    SvgPicture.asset(
                      'lib/assets/svgs/$icon.svg',
                      width: icon == 'telegram' ? 18 : 24,
                      height: icon == 'telegram' ? 18 : 24,
                    ).withPadding(right: 16, left: icon == 'telegram' ? 4 : 0),
                    Text(
                      channel,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                        color: PaxColors.black,
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
                  children: [FaIcon(FontAwesomeIcons.chevronRight, size: 12)],
                ).withPadding(bottom: 8),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

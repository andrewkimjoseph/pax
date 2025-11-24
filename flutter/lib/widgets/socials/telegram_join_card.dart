import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pax/theming/colors.dart';
import 'package:pax/utils/secret_constants.dart';
import 'package:pax/widgets/socials/x_follow_button.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class TelegramFollowCard extends ConsumerWidget {
  const TelegramFollowCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      height: 100,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Color(0xFF24A1DE),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SvgPicture.asset(
              'lib/assets/svgs/telegram.svg',
              // colorFilter: const ColorFilter.mode(
              //   // Colors.white,
              //   // BlendMode.srcIn,
              // ),
              height: 32,
            ),
          ).withPadding(right: 8, left: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Join the tribe!',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                    color: PaxColors.white,
                  ),
                ).withPadding(bottom: 8),
                const Text(
                  "Help us grow our Telegram community!",
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          FollowSocialButton(
            socialName: "Telegram",
            socialLink: telegramChannelLink,
          ),
        ],
      ),
    );
  }
}

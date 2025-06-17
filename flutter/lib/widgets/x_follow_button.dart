import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pax/providers/analytics/analytics_provider.dart';
import 'package:pax/theming/colors.dart';
import 'package:pax/utils/url_handler.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:pax/extensions/tooltip.dart';

class XFollowButton extends ConsumerStatefulWidget {
  const XFollowButton({super.key});

  @override
  ConsumerState<XFollowButton> createState() => _XFollowButtonState();
}

class _XFollowButtonState extends ConsumerState<XFollowButton> {
  @override
  Widget build(BuildContext context) {
    return Button(
      onPressed: () {
        ref.read(analyticsProvider).xFollowTapped();
        UrlHandler.launchInExternalBrowser('https://x.com/thecanvassing');
      },
      disableHoverEffect: true,
      disableTransition: true,
      style: ButtonStyle.outline(density: ButtonDensity.dense)
          .withBorder(border: Border.all(color: Colors.white))
          .withBorderRadius(
            borderRadius: BorderRadius.circular(20),
            hoverBorderRadius: BorderRadius.circular(20),
          ),
      trailing: SvgPicture.asset(
        'lib/assets/svgs/arrow_icon.svg',
        colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
        height: 16,
      ),
      child: const Text(
        "Follow",
        style: TextStyle(color: PaxColors.white, fontSize: 12),
      ),
    ).withToolTip('Follow us on X.');
  }
}

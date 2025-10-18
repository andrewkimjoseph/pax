import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
        UrlHandler.launchCustomTab(context, 'https://x.com/thecanvassing');
      },
      disableHoverEffect: true,
      disableTransition: true,
      style: ButtonStyle.outline(density: ButtonDensity.dense)
          .withBorder(border: Border.all(color: Colors.white))
          .withBorderRadius(
            borderRadius: BorderRadius.circular(20),
            hoverBorderRadius: BorderRadius.circular(20),
          ),
      trailing: FaIcon(
        FontAwesomeIcons.chevronRight,
        size: 12,
        color: PaxColors.white,
      ).withAlign(Alignment.center),
      child: const Text(
        "Follow",
        style: TextStyle(color: PaxColors.white, fontSize: 14),
      ).withPadding(horizontal: 8, vertical: 4),
    ).withToolTip('Follow us on X.');
  }
}

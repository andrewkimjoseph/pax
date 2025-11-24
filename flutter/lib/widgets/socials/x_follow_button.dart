import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pax/providers/analytics/analytics_provider.dart';
import 'package:pax/theming/colors.dart';
import 'package:pax/utils/url_handler.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class FollowSocialButton extends ConsumerStatefulWidget {
  const FollowSocialButton({
    super.key,
    required this.socialLink,
    required this.socialName,
  });

  final String socialLink;
  final String socialName;

  @override
  ConsumerState<FollowSocialButton> createState() => _FollowSocialButtonState();
}

class _FollowSocialButtonState extends ConsumerState<FollowSocialButton> {
  @override
  Widget build(BuildContext context) {
    return Button(
      onPressed: () {
        ref.read(analyticsProvider).joinTribeTapped({
          "social": widget.socialName,
        });
        UrlHandler.launchCustomTab(context, widget.socialLink);
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
      child: Text(
        widget.socialName == "X" ? "Follow" : "Join",
        style: TextStyle(color: PaxColors.white, fontSize: 14),
      ).withPadding(horizontal: 8, vertical: 4),
    );
  }
}

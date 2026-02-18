import 'package:flutter/material.dart' show InkWell;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pax/providers/analytics/analytics_provider.dart';
import 'package:pax/utils/secret_constants.dart';
import 'package:pax/utils/url_handler.dart';
import 'package:pax/widgets/option_card.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:pax/theming/colors.dart';

class Drawer extends ConsumerStatefulWidget {
  const Drawer({super.key});

  // Open a drawer from the left side
  static void open(BuildContext context, WidgetRef ref) {
    openDrawer(
      transformBackdrop: false,
      context: context,
      showDragHandle: false,
      builder: (drawerContext) {
        return Container(
          width: MediaQuery.of(context).size.width * 0.8,
          padding: const EdgeInsets.only(top: 16, left: 8, right: 8),
          decoration: BoxDecoration(color: PaxColors.white),
          child: Column(
            spacing: 16,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Options',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 32,
                  color: PaxColors.black,
                ),
              ),
              InkWell(
                onTap: () {
                  ref.read(analyticsProvider).goodWalletTapped({
                    "inviteCode": goodWalletInviteCode,
                  });
                  UrlHandler.launchCustomTab(
                    drawerContext,
                    goodWalletInviteLink,
                  );
                  // closeDrawer(drawerContext);
                },
                child: OptionCard(
                  'GoodWallet',
                  'lib/assets/svgs/wallets/goodwallet.svg',
                ),
              ).withPadding(top: 8),

              InkWell(
                onTap: () {
                  ref.read(analyticsProvider).goodPaxAppTapped({
                    "link": goodPaxAppLink,
                  });
                  UrlHandler.launchCustomTab(drawerContext, goodPaxAppLink);
                  // closeDrawer(drawerContext);
                },
                child: OptionCard(
                  'The Good Pax App',
                  'lib/assets/svgs/thegoodpaxapp.svg',
                ),
              ),

              InkWell(
                onTap: () {
                  ref.read(analyticsProvider).esiTapped();
                  UrlHandler.launchCustomTab(
                    drawerContext,
                    esiRegistrationLink,
                  );
                },
                child: OptionCard('ESI Level 1', 'lib/assets/svgs/esi.svg'),
              ),
            ],
          ),
        );
      },
      position: OverlayPosition.left,
    );
  }

  @override
  ConsumerState<Drawer> createState() => _StackedDrawerState();
}

class _StackedDrawerState extends ConsumerState<Drawer> {
  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

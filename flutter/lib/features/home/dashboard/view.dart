import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart' show SvgPicture;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:pax/data/forum_reports.dart';
import 'package:pax/extensions/tooltip.dart';
import 'package:pax/providers/db/pax_account/pax_account_provider.dart';
import 'package:pax/theming/colors.dart';
import 'package:pax/utils/currency_symbol.dart';
import 'package:pax/utils/gradient_border.dart';
import 'package:pax/utils/token_balance_util.dart';
import 'package:pax/widgets/published_reports_card.dart';
import 'package:pax/widgets/select_currency_button.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class DashboardView extends ConsumerStatefulWidget {
  const DashboardView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _DashboardViewState();
}

class _DashboardViewState extends ConsumerState<DashboardView> {
  String selectedValue = 'good_dollar';
  int index = 0;

  final CarouselController controller = CarouselController();

  String? screenName;
  bool viewYourProgress = false;

  final List<String> svgs = ['green', 'pink', 'red', 'orange', 'blue'];

  @override
  Widget build(BuildContext context) {
    final paxAccount = ref.read(paxAccountProvider);

    return Scaffold(
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              decoration: ShapeDecoration(
                shape: GradientBorder(
                  gradient: LinearGradient(
                    colors: PaxColors.orangeToPinkGradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  width: 2,
                  borderRadius: BorderRadius.circular(12),
                ),
                color: Colors.white,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Current Balance',
                        style: TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 20,
                          color: PaxColors.black,
                        ),
                      ).withPadding(bottom: 8),
                      Spacer(),
                      IconButton.ghost(
                        onPressed: () {
                          ref
                              .read(paxAccountProvider.notifier)
                              .syncBalancesFromBlockchain();
                        },
                        density: ButtonDensity.icon,
                        icon: const FaIcon(FontAwesomeIcons.arrowsRotate),
                      ),
                    ],
                  ),

                  Row(
                    children: [
                      Text(
                        TokenBalanceUtil.getFormattedBalanceByCurrency(
                          paxAccount.account?.balances,
                          selectedValue,
                        ),
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 28,
                          color: PaxColors.black,
                        ),
                      ).withPadding(right: 8),
                      SvgPicture.asset(
                        'lib/assets/svgs/currencies/$selectedValue.svg',
                        height: 25,
                      ),
                    ],
                  ).withPadding(bottom: 16),

                  Row(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 0.375,
                        decoration: BoxDecoration(
                          color: PaxColors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Select<String>(
                          // filled: true,
                          // disableHoverEffect: true,
                          itemBuilder: (context, item) {
                            return Row(
                              children: [
                                // Icon(
                                //   Icons.circle,
                                //   size: 12,
                                //   color: PaxColors.blue,
                                // ).withPadding(right: 4),
                                SvgPicture.asset(
                                  'lib/assets/svgs/currencies/$item.svg',

                                  height: 20,
                                ).withPadding(right: 8),
                                Text(
                                  CurrencySymbolUtil.getSymbolForCurrency(item),
                                ),
                              ],
                            );
                          },

                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                selectedValue = value;
                              });
                            }
                          },
                          value: selectedValue,
                          placeholder: const Text('Change currency'),
                          popup:
                              (context) => SelectPopup(
                                items: SelectItemList(
                                  children: [
                                    SelectCurrencyButton('good_dollar'),
                                    SelectCurrencyButton('celo_dollar'),

                                    SelectCurrencyButton('tether_usd'),

                                    SelectCurrencyButton(
                                      'usd_coin',
                                    ).withPadding(bottom: kIsWeb ? 0 : 30),
                                  ],
                                ),
                              ),
                        ),
                      ).withPadding(right: 8),

                      Button(
                        style: const ButtonStyle.outline(
                              density: ButtonDensity.normal,
                            )
                            .withBackgroundColor(color: PaxColors.deepPurple)
                            .withBorder(
                              // border: Border.all(color: PaxColors.deepPurple),
                            ),
                        onPressed: () async {
                          // DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
                          // AndroidDeviceInfo androidInfo =
                          //     await deviceInfo.androidInfo;
                          // if (kDebugMode) {
                          //   print('$androidInfo');
                          // }
                          context.go('/wallet');
                        },
                        child: Text(
                          'Wallet',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                            color:
                                PaxColors
                                    .white, // The purple color from your images
                          ),
                        ),
                      ).withToolTip('Check out your wallet.'),
                    ],
                  ),

                  // Row(
                  //   children: [
                  //     OutlineButton(
                  //       child: const Text('Cancel'),
                  //       onPressed: () {},
                  //     ),
                  //     const Spacer(),
                  //     PrimaryButton(
                  //       child: const Text('Deploy'),
                  //       onPressed: () {},
                  //     ),
                  //   ],
                  // ),
                ],
              ).withPadding(all: 12),
            ).withPadding(bottom: 8),

            Container(
              // width: double.infinity,
              height: 120,
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                // gradient: LinearGradient(
                //   colors: PaxColors.orangeToPinkGradient,
                // ),
                color: PaxColors.black,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SvgPicture.asset(
                      'lib/assets/svgs/x_white.svg',
                      colorFilter: ColorFilter.mode(
                        Colors.white,
                        BlendMode.srcIn,
                      ),

                      height: 32,
                    ),
                  ).withPadding(right: 12),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Join the tribe!',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                          color: PaxColors.white,
                        ),
                      ).withPadding(bottom: 8),

                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.5,
                        child: Text(
                          "Our X followers get early access to 30% more high-paying surveys.",
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),

                  Spacer(),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        child: Row(
                          children: [
                            Button(
                              onPressed: () {
                                launchExternalUrl(
                                  'https://x.com/thecanvassing',
                                );
                              },
                              disableHoverEffect: true,
                              disableTransition: true,
                              style: ButtonStyle.outline(
                                    density: ButtonDensity.dense,
                                  )
                                  .withBorder(
                                    border: Border.all(color: Colors.white),
                                  )
                                  .withBorderRadius(
                                    borderRadius: BorderRadius.circular(20),
                                    hoverBorderRadius: BorderRadius.circular(
                                      20,
                                    ),
                                  ),

                              trailing: SvgPicture.asset(
                                'lib/assets/svgs/arrow_icon.svg',
                                colorFilter: ColorFilter.mode(
                                  Colors.white,
                                  BlendMode.srcIn,
                                ),

                                height: 16,
                              ),
                              // onPressed: callBack,
                              child: const Text(
                                "Follow",
                                style: TextStyle(color: PaxColors.white),
                              ),
                            ).withToolTip('Follow us on X.'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ).withPadding(bottom: 8),

            SizedBox(
              height: MediaQuery.of(context).size.width / 2,

              child: Carousel(
                onIndexChanged: (value) {},
                // draggable: false,
                transition: const CarouselTransition.fading(),
                controller: controller,
                direction: Axis.horizontal,
                autoplaySpeed: const Duration(seconds: 1),
                // speed: Duration(seconds: 10),
                // sizeConstraint: CarouselSizeConstraint.fractional(1),
                itemCount: 5,
                itemBuilder: (context, index) {
                  return SvgPicture.asset(
                    placeholderBuilder:
                        (context) => Center(child: CircularProgressIndicator()),
                    fit: BoxFit.fitWidth,
                    'lib/assets/svgs/dashboard_carousel/${svgs[index]}.svg',
                  );
                },
                duration: const Duration(seconds: 1),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Published Reports',
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 20,
                    color: PaxColors.deepPurple,
                  ),
                ).withPadding(bottom: 8),

                GestureDetector(
                  onTap: () {},
                  child: SvgPicture.asset(
                    'lib/assets/svgs/arrow_icon.svg',
                    // height: 16,
                    // width: 16,
                  ),
                ),
              ],
            ).withPadding(bottom: 8, top: 4),

            PublishedReportCard(forumReports).withPadding(bottom: 12),
          ],
        ).withPadding(all: 8),
      ),
    );
  }
}

Future<void> launchExternalUrl(String url) async {
  final Uri uri = Uri.parse(url);
  if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
    // Show error if URL can't be launched
  }
}

// String? selectedValue;
// @override
// Widget build(BuildContext context) {
//   return 
// }





// final CarouselController controller = CarouselController();
// @override
// Widget build(BuildContext context) {
//   return 
// }

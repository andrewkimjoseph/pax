// ignore_for_file: unused_import

import 'package:flutter/material.dart' show Divider;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart' show SvgPicture;
import 'package:go_router/go_router.dart';
import 'package:pax/features/home/achievements/view.dart';
import 'package:pax/features/home/dashboard/view.dart';
import 'package:pax/features/home/task/view.dart';
import 'package:pax/features/onboarding/view_model.dart';
import 'package:pax/widgets/account_option_card.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' hide Divider;
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../theming/colors.dart' show PaxColors;
import '../../utils/clipper.dart';

class ProfileView extends ConsumerStatefulWidget {
  const ProfileView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ProfileViewState();
}

class _ProfileViewState extends ConsumerState<ProfileView> {
  PhoneNumber? _phoneNumber;
  String? selectedValue;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      headers: [
        AppBar(
          padding: EdgeInsets.all(8),
          leading: [
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onPanDown: (details) {
                context.pop();
              },
              child: SvgPicture.asset(
                'lib/assets/svgs/arrow_left_long.svg',
              ).withPadding(left: 16),
            ),
          ],
          trailing: [Icon(Icons.more_vert)],
          title: Text(
            "My Profile",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20),
          ),

          backgroundColor: PaxColors.white,
        ).withPadding(top: 16),
      ],

      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              width: double.infinity,
              decoration: BoxDecoration(
                color: PaxColors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: PaxColors.lightLilac, width: 1),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        // padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color:
                                PaxColors.deepPurple, // Change color as needed
                            width: 2.5, // Adjust border thickness as needed
                          ),
                        ),
                        child: Avatar(
                          size: 70,
                          initials: Avatar.getInitials('sunarya-thito'),
                          provider: const NetworkImage(
                            'https://avatars.githubusercontent.com/u/64018564?v=4',
                          ),
                        ),
                      ),

                      SvgPicture.asset('lib/assets/svgs/edit_profile.svg'),
                    ],
                  ).withPadding(bottom: 8, top: 8),

                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: PaxColors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: PaxColors.lightLilac, width: 1),
                    ),
                    child: Column(
                      children: [
                        // Row(
                        //   mainAxisAlignment: MainAxisAlignment.center,
                        //   crossAxisAlignment: CrossAxisAlignment.start,
                        //   children: [],
                        // ).withPadding(bottom: 8, top: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Full Name",
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            ).withPadding(bottom: 8),
                            TextField(
                              placeholder: Text('Enter your name'),
                              decoration: BoxDecoration(
                                color: PaxColors.lightLilac,
                                borderRadius: BorderRadius.circular(7),
                              ),
                              features: [],
                              // enabled: false,
                            ),
                          ],
                        ).withPadding(bottom: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Email",
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            ).withPadding(bottom: 8),
                            TextField(
                              placeholder: Text(
                                'andrewk@thecanvassing.com',
                                style: TextStyle(
                                  color: PaxColors.black,
                                  fontSize: 14,
                                ),
                              ),
                              decoration: BoxDecoration(
                                color: PaxColors.lightLilac,
                                borderRadius: BorderRadius.circular(7),
                              ),
                              features: [
                                InputFeature.leading(
                                  SvgPicture.asset(
                                    'lib/assets/svgs/email.svg',
                                    height: 20,
                                    width: 20,
                                  ),
                                ),
                              ],
                              // enabled: false,
                            ),
                          ],
                        ).withPadding(bottom: 16),

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Phone Number",
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            ).withPadding(bottom: 8),
                            Container(
                              decoration: BoxDecoration(
                                color: PaxColors.lightLilac,
                                borderRadius: BorderRadius.circular(7),
                              ),
                              child: FittedBox(
                                child: PhoneInput(
                                  initialValue: PhoneNumber(
                                    Country.kenya,
                                    '0722978938',
                                  ),
                                  initialCountry: Country.kenya,
                                  onChanged: (value) {
                                    setState(() {
                                      _phoneNumber = value;
                                    });
                                  },
                                ),
                              ),
                            ),
                            // Text(_phoneNumber?.value ?? '(No value)'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ).withPadding(all: 8),
    );
  }
}

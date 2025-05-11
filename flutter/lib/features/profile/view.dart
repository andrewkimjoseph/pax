import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart' show SvgPicture;
import 'package:go_router/go_router.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../theming/colors.dart' show PaxColors;

class ProfileView extends ConsumerStatefulWidget {
  const ProfileView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ProfileViewState();
}

class _ProfileViewState extends ConsumerState<ProfileView> {
  PhoneNumber? phoneNumber;
  String? selectedValue;
  DateTime? _value;
  String? genderValue;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      headers: [
        AppBar(
          padding: EdgeInsets.all(8),

          backgroundColor: PaxColors.white,
          child: Row(
            children: [
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onPanDown: (details) {
                  context.pop();
                },
                child: SvgPicture.asset('lib/assets/svgs/arrow_left_long.svg'),
              ),
              Spacer(),
              Text(
                "My Profile",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20),
              ),

              Spacer(),
              // Icon(Icons.more_vert),
            ],
          ),
        ).withPadding(top: 16),
        Divider(color: PaxColors.lightGrey),
      ],

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
                          color: PaxColors.deepPurple, // Change color as needed
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
                  ],
                ).withPadding(bottom: 16, top: 12),

                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: PaxColors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: PaxColors.lightLilac, width: 1),
                  ),
                  child: Column(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Display Name",
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                          ).withPadding(bottom: 8),
                          TextField(
                            enableInteractiveSelection: true,
                            placeholder: Text(
                              'Andrew Kim',
                              style: TextStyle(
                                color: PaxColors.black,
                                fontSize: 14,
                              ),
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
                            enabled: false,
                            keyboardType: TextInputType.emailAddress,

                            placeholder: Text(
                              'andrewk@thecanvassing.com',
                              style: TextStyle(
                                color: PaxColors.black,
                                fontSize: 14,
                              ),
                            ),
                            // decoration: BoxDecoration(
                            //   color: PaxColors.lightLilac,
                            //   borderRadius: BorderRadius.circular(7),
                            // ),
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

                      SizedBox(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Phone Number",
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            ).withPadding(bottom: 8),
                            FittedBox(
                              fit: BoxFit.fill,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  PhoneInput(
                                    initialValue: PhoneNumber(
                                      Country.kenya,
                                      '722978938',
                                    ),
                                    initialCountry: Country.kenya,
                                    onChanged: (value) {
                                      setState(() {
                                        phoneNumber = value;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                            // Text(_phoneNumber?.value ?? '(No value)'),
                          ],
                        ).withPadding(bottom: 16),
                      ),

                      Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Gender",
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            ).withPadding(bottom: 8),
                            SizedBox(
                              // decoration: BoxDecoration(
                              //   color: PaxColors.lightLilac,
                              //   borderRadius: BorderRadius.circular(7),
                              // ),
                              width: double.infinity,
                              child: Select<String>(
                                disableHoverEffect: true,
                                itemBuilder: (context, item) {
                                  return Text(item);
                                },

                                onChanged: (value) {
                                  setState(() {
                                    selectedValue = value;
                                  });
                                },
                                value: selectedValue,
                                placeholder: const Text('Gender'),
                                popup: (context) {
                                  return SelectPopup(
                                    items: SelectItemList(
                                      children: [
                                        SelectItemButton(
                                          value: 'Male',
                                          child: Text('Male'),
                                        ),
                                        SelectItemButton(
                                          value: 'Female',
                                          child: Text('Female'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                            // Text(_phoneNumber?.value ?? '(No value)'),
                          ],
                        ).withPadding(bottom: 16),
                      ),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Birthdate",
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                          ).withPadding(bottom: 8),
                          SizedBox(
                            // decoration: BoxDecoration(
                            //   color: PaxColors.lightLilac,
                            //   borderRadius: BorderRadius.circular(7),
                            // ),
                            width: double.infinity,
                            child: DatePicker(
                              placeholder: Text(
                                'Select date',
                                style: TextStyle(color: Colors.black),
                              ),
                              value: _value,
                              mode: PromptMode.dialog,
                              stateBuilder: (date) {
                                if (date.isAfter(DateTime.now())) {
                                  return DateState.disabled;
                                }
                                return DateState.enabled;
                              },
                              onChanged: (value) {
                                setState(() {
                                  _value = value;
                                });
                              },
                            ),
                          ),
                        ],
                      ).withPadding(bottom: 16),
                    ],
                  ),
                ),

                Container(
                  // padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  color: Colors.white,

                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: PrimaryButton(
                          onPressed: () {},

                          child: Text(
                            'Save',
                            style: Theme.of(context).typography.base.copyWith(
                              fontWeight: FontWeight.normal,
                              fontSize: 14,
                              color: PaxColors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ).withPadding(top: 16),
              ],
            ),
          ),
        ],
      ).withPadding(all: 8),
    );
  }
}

// String? selectedValue;
// @override
// Widget build(BuildContext context) {
//   return 
// }


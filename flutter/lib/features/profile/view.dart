import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart' show SvgPicture;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pax/providers/analytics/analytics_provider.dart';
import 'package:pax/providers/db/participant/participant_provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../theming/colors.dart' show PaxColors;

class ProfileView extends ConsumerStatefulWidget {
  const ProfileView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ProfileViewState();
}

class _ProfileViewState extends ConsumerState<ProfileView> {
  PhoneNumber? phoneNumber;
  DateTime? dateTime;
  String? genderValue;
  bool isProcessing = false;

  @override
  void initState() {
    super.initState();
  }

  // Helper method to show toast notifications
  void _showToast({
    required String message,
    required Color backgroundColor,
    required IconData icon,
  }) {
    showToast(
      context: context,
      location: ToastLocation.topCenter,
      builder:
          (context, overlay) => Container(
            width: MediaQuery.of(context).size.width * 0.95,
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Basic(
              subtitle: Text(
                message,
                style: const TextStyle(color: PaxColors.white),
              ),
              trailing: FaIcon(icon, color: PaxColors.white),
              trailingAlignment: Alignment.center,
            ),
          ),
    );
  }

  // Validate phone number
  bool _validatePhoneNumber() {
    if (phoneNumber == null || phoneNumber!.number.isEmpty) {
      _showToast(
        message: 'Phone number is required',
        backgroundColor: Colors.amber,
        icon: FontAwesomeIcons.circleInfo,
      );
      return false;
    }

    // Additional validation could be added here
    // For example, checking minimum length based on country
    if (phoneNumber!.number.length < 6) {
      _showToast(
        message: 'Phone number is too short',
        backgroundColor: Colors.amber,
        icon: FontAwesomeIcons.circleInfo,
      );
      return false;
    }

    return true;
  }

  // Validate gender selection
  bool _validateGender() {
    if (genderValue == null) {
      _showToast(
        message: 'Gender selection is required',
        backgroundColor: Colors.amber,
        icon: FontAwesomeIcons.circleInfo,
      );
      return false;
    }
    return true;
  }

  // Validate birthdate
  bool _validateBirthdate() {
    if (dateTime == null) {
      _showToast(
        message: 'Birthdate is required',
        backgroundColor: Colors.amber,
        icon: FontAwesomeIcons.circleInfo,
      );
      return false;
    }

    // Check if user is at least 18 years old
    final DateTime now = DateTime.now();
    final DateTime minimumDate = DateTime(now.year - 18, now.month, now.day);

    if (dateTime!.isAfter(minimumDate)) {
      _showToast(
        message: 'You must be at least 18 years old',
        backgroundColor: Colors.amber,
        icon: FontAwesomeIcons.circleInfo,
      );
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    final participant = ref.watch(participantProvider).participant;
    final participantState = ref.watch(participantProvider).state;
    final isLoading = participantState == ParticipantState.loading;

    // Initialize phone number from participant if available
    if (participant != null && participant.phoneNumber != null) {
      try {
        // Parse existing phone number if available (format: "+254 712345678")
        final parts = participant.phoneNumber!.split(' ');
        if (parts.length == 2) {
          final countryCode = parts[0];
          final number = parts[1];
          // Find country by dial code
          final country = Country.values.firstWhere(
            (c) => c.dialCode == countryCode,
            orElse: () => Country.kenya,
          );

          // Always set phone number from participant data to ensure it's properly displayed
          if (phoneNumber == null || phoneNumber!.number.isEmpty) {
            phoneNumber = PhoneNumber(country, number);
          }
        }
      } catch (e) {
        // Fallback for parsing errors if this is the first time loading
        phoneNumber ??= PhoneNumber(Country.kenya, '');
      }
    } else {
      phoneNumber ??= PhoneNumber(Country.kenya, '');
    }

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
            ],
          ),
        ).withPadding(top: 16),
        Divider(color: PaxColors.lightGrey),
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
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: PaxColors.deepPurple,
                            width: 2.5,
                          ),
                        ),
                        child: Avatar(
                          size: 70,
                          initials: Avatar.getInitials(
                            participant!.profilePictureURI!,
                          ),
                          provider: NetworkImage(
                            participant.profilePictureURI!,
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
                        // Display Name Field
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
                              enabled: false,
                              enableInteractiveSelection: true,
                              placeholder: Text(
                                participant.displayName!,
                                style: TextStyle(
                                  color: PaxColors.mediumPurple,
                                  fontSize: 14,
                                ),
                              ),
                              features: [],
                            ),
                          ],
                        ).withPadding(bottom: 16),

                        // Email Field
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
                                participant.emailAddress!,
                                style: TextStyle(
                                  color: PaxColors.mediumPurple,
                                  fontSize: 14,
                                ),
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
                            ),
                          ],
                        ).withPadding(bottom: 16),

                        // Phone Number Field
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

                              if (participant.phoneNumber != null)
                                TextField(
                                  enabled: false,
                                  placeholder: Text(phoneNumber.toString()),
                                ),

                              Visibility(
                                visible: participant.phoneNumber == null,
                                child: FittedBox(
                                  fit: BoxFit.fill,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      PhoneInput(
                                        initialValue:
                                            phoneNumber?.country != null &&
                                                    phoneNumber?.number != null
                                                ? PhoneNumber(
                                                  phoneNumber!.country,
                                                  phoneNumber!.number,
                                                )
                                                : null,

                                        onChanged: (value) {
                                          setState(() {
                                            phoneNumber = value;
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ).withPadding(bottom: 16),
                        ),

                        // Gender Field
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
                                width: double.infinity,
                                child: Select<String>(
                                  disableHoverEffect: true,
                                  itemBuilder: (context, item) {
                                    return Text(item);
                                  },
                                  onChanged: (value) {
                                    setState(() {
                                      genderValue = value;
                                    });
                                  },
                                  value: genderValue ?? participant.gender,
                                  // Only allow editing if gender hasn't been set
                                  enabled: participant.gender == null,
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
                            ],
                          ).withPadding(bottom: 16),
                        ),

                        // Birthdate Field
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
                              width: double.infinity,
                              child: DatePicker(
                                // Only allow editing if birthdate hasn't been set
                                enabled: participant.dateOfBirth == null,
                                placeholder: Text(
                                  'Select date',
                                  style: TextStyle(color: Colors.black),
                                ),
                                value:
                                    dateTime ??
                                    (participant.dateOfBirth != null
                                        ? DateTime.fromMillisecondsSinceEpoch(
                                          participant
                                              .dateOfBirth!
                                              .millisecondsSinceEpoch,
                                        )
                                        : null),
                                mode: PromptMode.dialog,
                                stateBuilder: (date) {
                                  if (date.isAfter(DateTime.now())) {
                                    return DateState.disabled;
                                  }
                                  return DateState.enabled;
                                },
                                onChanged: (value) {
                                  setState(() {
                                    dateTime = value;
                                  });
                                },
                              ),
                            ),
                          ],
                        ).withPadding(bottom: 16),
                      ],
                    ),
                  ),

                  // Save Button
                  Container(
                    color: Colors.white,
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: PrimaryButton(
                            onPressed:
                                (isLoading || isProcessing)
                                    ? null
                                    : () async {
                                      ref
                                          .read(analyticsProvider)
                                          .saveProfileChangesTapped();
                                      // Prevent double-pressing
                                      setState(() {
                                        isProcessing = true;
                                      });

                                      try {
                                        // Validate phone number if not already set
                                        if (participant.phoneNumber == null &&
                                            !_validatePhoneNumber()) {
                                          setState(() {
                                            isProcessing = false;
                                          });
                                          return;
                                        }

                                        if (participant.gender == null &&
                                            !_validateGender()) {
                                          setState(() {
                                            isProcessing = false;
                                          });
                                          return;
                                        }

                                        // Validate birthdate if not already set
                                        if (participant.dateOfBirth == null &&
                                            !_validateBirthdate()) {
                                          setState(() {
                                            isProcessing = false;
                                          });
                                          return;
                                        }
                                        // Create update data map
                                        final Map<String, dynamic> updateData =
                                            {};

                                        // Only add gender if it's not already set
                                        if (participant.gender == null &&
                                            genderValue != null) {
                                          updateData['gender'] = genderValue;
                                        }

                                        // Only add birthdate if it's not already set
                                        if (participant.dateOfBirth == null &&
                                            dateTime != null) {
                                          updateData['dateOfBirth'] =
                                              Timestamp.fromDate(dateTime!);
                                        }

                                        // Add phone number and country if not already set
                                        if (participant.phoneNumber == null &&
                                            phoneNumber != null) {
                                          final formattedPhoneNumber =
                                              '${phoneNumber!.country.dialCode} ${phoneNumber!.number}';
                                          updateData['phoneNumber'] =
                                              formattedPhoneNumber;
                                          updateData['country'] =
                                              phoneNumber!.country.toString();
                                        }

                                        // Only proceed if there are changes to save
                                        if (updateData.isNotEmpty) {
                                          await ref
                                              .read(
                                                participantProvider.notifier,
                                              )
                                              .updateProfile(updateData);
                                          _showToast(
                                            message:
                                                'Profile updated successfully',
                                            backgroundColor: Colors.green,
                                            icon: FontAwesomeIcons.circleCheck,
                                          );
                                        } else {
                                          _showToast(
                                            message: 'No changes to save',
                                            backgroundColor: Colors.blue,
                                            icon: FontAwesomeIcons.circleInfo,
                                          );
                                        }
                                      } catch (e) {
                                        _showToast(
                                          message:
                                              'Error updating profile: ${e.toString()}',
                                          backgroundColor: Colors.red,
                                          icon:
                                              FontAwesomeIcons
                                                  .circleExclamation,
                                        );
                                      } finally {
                                        setState(() {
                                          isProcessing = false;
                                        });
                                      }
                                    },
                            child:
                                (isLoading || isProcessing)
                                    ? CircularProgressIndicator(onSurface: true)
                                    : Text(
                                      'Save',
                                      style: Theme.of(
                                        context,
                                      ).typography.base.copyWith(
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
      ),
    );
  }
}

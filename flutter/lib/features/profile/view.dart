import 'package:flutter/material.dart' show InkWell;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart' show SvgPicture;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pax/providers/analytics/analytics_provider.dart';
import 'package:pax/providers/db/participant/participant_provider.dart';
import 'package:pax/providers/db/pax_account/pax_account_provider.dart';
import 'package:pax/utils/country_util.dart';
import 'package:pax/widgets/custom_avatar.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../theming/colors.dart' show PaxColors;

class ProfileView extends ConsumerStatefulWidget {
  const ProfileView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ProfileViewState();
}

class _ProfileViewState extends ConsumerState<ProfileView> {
  DateTime? dateTime;
  String? genderValue;
  String? selectedCountry;
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
    if (!context.mounted) return;
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

  // Validate country selection
  bool _validateCountry() {
    if (selectedCountry == null) {
      _showToast(
        message: 'Country selection is required',
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

  // Validate date of birth
  bool _validateDateOfBirth() {
    if (dateTime == null) {
      _showToast(
        message: 'Date of birth is required',
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
    final participantState = ref.watch(participantProvider);
    final participant = participantState.participant;
    final isLoading = participantState.state == ParticipantState.loading;
    final paxAccount = ref.watch(paxAccountProvider).account;
    final hasPaymentMethod = paxAccount?.contractAddress != null;

    final bool isProfileComplete =
        participant != null &&
        participant.country != null &&
        participant.gender != null &&
        participant.dateOfBirth != null;

    // Initialize selected country from participant if available
    if (participant != null && participant.country != null) {
      // Extract country name from participant.country string if it's not already set
      if (selectedCountry == null) {
        try {
          // participant.country might be in format "Country.kenya" or just "Kenya"
          final countryString = participant.country!;
          if (countryString.contains('Country.')) {
            // Parse enum format like "Country.kenya"
            final enumName = countryString.split('.').last;
            final country =
                Country.values
                    .where(
                      (c) => c.name.toLowerCase() == enumName.toLowerCase(),
                    )
                    .firstOrNull;
            selectedCountry = country?.name;
          } else {
            // Direct country name
            selectedCountry = countryString;
          }
        } catch (e) {
          // Fallback - could set a default country if needed
          selectedCountry = null;
        }
      }
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      headers: [
        AppBar(
          padding: EdgeInsets.all(8),
          backgroundColor: PaxColors.white,
          child: Row(
            children: [
              InkWell(
                onTap: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go("/home");
                  }
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

      child:
          !hasPaymentMethod
              ? Center(
                child: Text(
                  'Please connect a withdrawal method to view your profile.',
                  textAlign: TextAlign.center,
                ).withPadding(all: 16),
              )
              : SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: PaxColors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: PaxColors.lightLilac,
                          width: 1,
                        ),
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
                                child: CustomAvatar(size: 70),
                              ),
                            ],
                          ).withPadding(bottom: 16, top: 12),

                          Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: PaxColors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: PaxColors.lightLilac,
                                width: 1,
                              ),
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
                                      placeholder:
                                          participant != null &&
                                                  participant.displayName !=
                                                      null
                                              ? Text(
                                                participant.displayName!,
                                                style: TextStyle(
                                                  color: PaxColors.mediumPurple,
                                                  fontSize: 14,
                                                ),
                                              )
                                              : null,
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
                                      placeholder:
                                          participant != null &&
                                                  participant.emailAddress !=
                                                      null
                                              ? Text(
                                                participant.emailAddress!,
                                                style: TextStyle(
                                                  color: PaxColors.mediumPurple,
                                                  fontSize: 14,
                                                ),
                                              )
                                              : null,
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

                                // Country Field
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Country",
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ).withPadding(bottom: 8),
                                    SizedBox(
                                      width: double.infinity,
                                      child: Select<String>(
                                        itemBuilder: (context, item) {
                                          // Find the country by name to get the flag
                                          final country =
                                              CountryUtil.allCountries
                                                  .where((c) => c.name == item)
                                                  .firstOrNull;
                                          return Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              if (country != null) ...[
                                                Text(country.flag),
                                                SizedBox(width: 8),
                                              ],
                                              Text(item),
                                            ],
                                          );
                                        },
                                        popup:
                                            SelectPopup.builder(
                                              searchPlaceholder: const Text(
                                                'Search country',
                                              ),
                                              emptyBuilder: (context) {
                                                return const Center(
                                                  child: Text(
                                                    'No country found',
                                                  ),
                                                );
                                              },
                                              loadingBuilder: (context) {
                                                return const Center(
                                                  child:
                                                      CircularProgressIndicator(),
                                                );
                                              },
                                              builder: (
                                                context,
                                                searchQuery,
                                              ) async {
                                                final allCountries =
                                                    CountryUtil.allCountries;
                                                final filteredCountries =
                                                    searchQuery == null
                                                        ? allCountries
                                                        : allCountries
                                                            .where(
                                                              (
                                                                country,
                                                              ) => CountryUtil.filterCountry(
                                                                country,
                                                                searchQuery
                                                                    .toLowerCase(),
                                                              ),
                                                            )
                                                            .toList();
                                                return SelectItemBuilder(
                                                  childCount:
                                                      filteredCountries.isEmpty
                                                          ? 0
                                                          : filteredCountries
                                                              .length,
                                                  builder: (context, index) {
                                                    final country =
                                                        filteredCountries[index];
                                                    return SelectItemButton(
                                                      value: country.name,
                                                      child: Row(
                                                        children: [
                                                          Text(country.flag),
                                                          SizedBox(width: 8),
                                                          Expanded(
                                                            child: Text(
                                                              country.name,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  },
                                                );
                                              },
                                            ).call,
                                        onChanged: (value) {
                                          setState(() {
                                            selectedCountry = value;
                                          });
                                        },
                                        enabled: participant?.country == null,
                                        constraints: const BoxConstraints(
                                          minWidth: 200,
                                        ),
                                        value: selectedCountry,
                                        placeholder: const Text(
                                          'Select a country',
                                        ),
                                      ),
                                    ),
                                  ],
                                ).withPadding(bottom: 16),

                                // Gender Field
                                Container(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                            // Add emoji to the selected value display
                                            String displayText = item;
                                            if (item == 'Male') {
                                              displayText = '♂️  Male';
                                            } else if (item == 'Female') {
                                              displayText = '♀️  Female';
                                            }
                                            return Text(displayText);
                                          },
                                          onChanged: (value) {
                                            setState(() {
                                              genderValue = value;
                                            });
                                          },
                                          value:
                                              genderValue ??
                                              participant?.gender,
                                          enabled: participant?.gender == null,
                                          placeholder: const Text('Gender'),
                                          popup: (context) {
                                            return SelectPopup(
                                              items: SelectItemList(
                                                children: [
                                                  SelectItemButton(
                                                    value: 'Male',
                                                    child: Text('♂️ Male'),
                                                  ),
                                                  SelectItemButton(
                                                    value: 'Female',
                                                    child: Text('♀️ Female'),
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
                                      "Date of Birth",
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
                                        enabled:
                                            participant?.dateOfBirth == null,
                                        placeholder: Text(
                                          'Select date',
                                          style: TextStyle(color: Colors.black),
                                        ),
                                        value:
                                            dateTime ??
                                            (participant?.dateOfBirth != null
                                                ? DateTime.fromMillisecondsSinceEpoch(
                                                  participant
                                                          ?.dateOfBirth
                                                          ?.millisecondsSinceEpoch ??
                                                      0,
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
                                        (isLoading ||
                                                isProcessing ||
                                                isProfileComplete)
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
                                                // Validate country if not already set
                                                if (participant != null &&
                                                    participant.country ==
                                                        null &&
                                                    !_validateCountry()) {
                                                  setState(() {
                                                    isProcessing = false;
                                                  });
                                                  return;
                                                }

                                                if (participant?.gender ==
                                                        null &&
                                                    !_validateGender()) {
                                                  setState(() {
                                                    isProcessing = false;
                                                  });
                                                  return;
                                                }

                                                // Validate birthdate if not already set
                                                if (participant?.dateOfBirth ==
                                                        null &&
                                                    !_validateDateOfBirth()) {
                                                  setState(() {
                                                    isProcessing = false;
                                                  });
                                                  return;
                                                }
                                                // Create update data map
                                                final Map<String, dynamic>
                                                updateData = {};

                                                // Only add gender if it's not already set
                                                if (participant?.gender ==
                                                        null &&
                                                    genderValue != null) {
                                                  updateData['gender'] =
                                                      genderValue;
                                                }

                                                // Only add birthdate if it's not already set
                                                if (participant?.dateOfBirth ==
                                                        null &&
                                                    dateTime != null) {
                                                  updateData['dateOfBirth'] =
                                                      Timestamp.fromDate(
                                                        dateTime!,
                                                      );
                                                }

                                                // Add country if not already set
                                                if (participant?.country ==
                                                        null &&
                                                    selectedCountry != null) {
                                                  updateData['country'] =
                                                      selectedCountry;
                                                }

                                                // Only proceed if there are changes to save
                                                if (updateData.isNotEmpty) {
                                                  await ref
                                                      .read(
                                                        participantProvider
                                                            .notifier,
                                                      )
                                                      .updateProfile(
                                                        updateData,
                                                      );
                                                  _showToast(
                                                    message:
                                                        'Profile updated successfully',
                                                    backgroundColor:
                                                        Colors.green,
                                                    icon:
                                                        FontAwesomeIcons
                                                            .circleCheck,
                                                  );
                                                } else {
                                                  _showToast(
                                                    message:
                                                        'No changes to save',
                                                    backgroundColor:
                                                        Colors.blue,
                                                    icon:
                                                        FontAwesomeIcons
                                                            .circleInfo,
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
                                                if (mounted) {
                                                  setState(() {
                                                    isProcessing = false;
                                                  });
                                                }
                                              }
                                            },
                                    child:
                                        isProfileComplete
                                            ? FaIcon(
                                              FontAwesomeIcons.circleCheck,
                                              size: 20,
                                              color: PaxColors.white,
                                            )
                                            : (isLoading || isProcessing)
                                            ? CircularProgressIndicator(
                                              onSurface: true,
                                            )
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
                ),
              ).withPadding(all: 8),
    );
  }
}

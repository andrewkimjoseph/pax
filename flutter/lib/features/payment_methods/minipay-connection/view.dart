// views/minipay_connection_view.dart (refactored to use provider)
import 'package:flutter/material.dart' show Divider, InkWell;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart' show SvgPicture;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:pax/providers/analytics/analytics_provider.dart';

import 'package:pax/providers/auth/auth_provider.dart';
import 'package:pax/providers/minipay/minipay_provider.dart';
import 'package:pax/theming/colors.dart';
import 'package:pax/widgets/gooddollar_verification_steps.dart';
import 'package:pax/services/notifications/notification_service.dart';
import 'package:pax/providers/fcm/fcm_provider.dart';
import 'package:pax/utils/url_handler.dart';

import 'package:shadcn_flutter/shadcn_flutter.dart' hide Divider, Consumer;

class MiniPayConnectionView extends ConsumerStatefulWidget {
  const MiniPayConnectionView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _MiniPayConnectionViewState();
}

class _MiniPayConnectionViewState extends ConsumerState<MiniPayConnectionView> {
  final TextEditingController _walletAddressController =
      TextEditingController();
  bool _isShowingDialog = false;
  bool _isConnecting = false;

  @override
  void initState() {
    super.initState();
    // Reset the connection state when the view is loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(miniPayConnectionProvider.notifier).resetState();
    });
  }

  @override
  void dispose() {
    _walletAddressController.dispose();
    super.dispose();
  }

  void _connectWallet() {
    if (_isConnecting) return;
    _isConnecting = true;
    FocusManager.instance.primaryFocus?.unfocus();
    ref.read(analyticsProvider).connectMinipayTapped();
    final miniPayWalletAddress = _walletAddressController.text.trim();
    final authState = ref.read(authProvider);

    // Show processing dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _buildProcessingDialog(),
    );

    // Connect wallet using the provider
    ref
        .read(miniPayConnectionProvider.notifier)
        .connectMiniPay(authState.user.uid, miniPayWalletAddress);
  }

  // Dialog showing processing state
  Widget _buildProcessingDialog() {
    return PopScope(
      canPop: false,
      child: AlertDialog(
        content: Consumer(
          builder: (context, ref, _) {
            final connectionState = ref.watch(miniPayConnectionProvider);

            // Handle different connection states
            if (connectionState.state == MiniPayConnectionState.success) {
              // Dismiss the dialog after a short delay
              Future.delayed(Duration(milliseconds: 500), () {
                if (context.mounted && !_isShowingDialog) {
                  _isShowingDialog = true;
                  context.pop();
                  _showSuccessDialog();
                }
              });
            } else if (connectionState.state == MiniPayConnectionState.error) {
              // Dismiss the dialog after a short delay
              Future.delayed(Duration(milliseconds: 500), () {
                if (context.mounted && !_isShowingDialog) {
                  _isShowingDialog = true;
                  context.pop();
                  _showErrorDialog(
                    connectionState.errorMessage ?? 'An unknown error occurred',
                  );
                }
              });
            }

            // Show loading indicator with current state message
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text(_getStateMessage(connectionState.state)),
              ],
            );
          },
        ),
      ),
    );
  }

  String _getStateMessage(MiniPayConnectionState state) {
    switch (state) {
      case MiniPayConnectionState.validating:
        return 'Validating address...';
      case MiniPayConnectionState.checkingWhitelist:
        return 'Checking GoodDollar verification...';
      case MiniPayConnectionState.creatingServerWallet:
        return 'Creating secure wallet...';
      case MiniPayConnectionState.deployingContract:
        return 'Deploying smart contract...';
      case MiniPayConnectionState.creatingPaymentMethod:
        return 'Setting up payment method...';
      case MiniPayConnectionState.updatingParticipant:
        return 'Syncing account data...';
      case MiniPayConnectionState.success:
        return 'Success!';
      default:
        return 'Processing your connection...';
    }
  }

  // Error dialog
  void _showErrorDialog(String errorMessage) {
    showDialog(
      context: context,
      builder: (context) {
        return PopScope(
          canPop: false,
          child: AlertDialog(
            title: Column(
              children: [
                SvgPicture.asset(
                  'lib/assets/svgs/canvassing.svg',
                  height: 24,
                ).withPadding(bottom: 16),
                Text(
                  'Connection Failed',
                  style: TextStyle(fontSize: 16),
                ).withAlign(Alignment.center),
              ],
            ),
            content: Text(
              errorMessage,
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
            ),
            actions: [
              OutlineButton(
                onPressed: () {
                  _isShowingDialog = false;
                  context.pop();
                },
                child: Text('OK'),
              ),
            ],
          ),
        );
      },
    );
  }

  // Success dialog
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return PopScope(
          canPop: false,
          child: AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  'lib/assets/svgs/minipay_connected.svg',
                ).withPadding(bottom: 8),

                const Text(
                  'Success!',
                  style: TextStyle(
                    color: PaxColors.deepPurple,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ).withPadding(bottom: 8),

                const Text(
                  'MiniPay Wallet Connected Successfully',
                  style: TextStyle(
                    color: PaxColors.deepPurple,
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                  ),
                  textAlign: TextAlign.center,
                ).withPadding(bottom: 8),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 2.5,
                      child: PrimaryButton(
                        child: const Text('OK'),
                        onPressed: () {
                          _isShowingDialog = false;
                          // Reset the connection state before popping
                          ref
                              .read(miniPayConnectionProvider.notifier)
                              .resetState();
                          context.go("/home");
                        },
                      ),
                    ),
                  ],
                ).withPadding(top: 8),
              ],
            ),
          ),
        );
      },
    );

    // Send notification in the background
    _sendNotification();
  }

  Future<void> _sendNotification() async {
    try {
      final fcmToken = await ref.read(fcmTokenProvider.future);
      if (fcmToken != null) {
        final notificationService = NotificationService();
        await notificationService.sendPaymentMethodLinkedNotification(
          token: fcmToken,
          paymentData: {
            'paymentMethodName': 'MiniPay',
            'walletAddress': _walletAddressController.text.trim(),
          },
        );
      }
    } catch (e) {
      // Silently handle notification errors
      debugPrint('Failed to send notification: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch the connection state
    final connectionState = ref.watch(miniPayConnectionProvider);

    // Reset _isConnecting flag if not connecting
    if (connectionState.state == MiniPayConnectionState.initial ||
        connectionState.state == MiniPayConnectionState.error ||
        connectionState.state == MiniPayConnectionState.success) {
      _isConnecting = false;
    }

    return Scaffold(
      footers: [
        Container(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            children: [
              const Divider().withPadding(top: 10, bottom: 10),
              _buildConnectButton(connectionState),
            ],
          ),
        ).withPadding(horizontal: 16, bottom: 32),
      ],
      resizeToAvoidBottomInset: false,
      loadingProgressIndeterminate: connectionState.isConnecting,
      headers: [
        AppBar(
          padding: const EdgeInsets.all(8),
          leading: const [],
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
              const Spacer(),
              const Text(
                "Connect Your MiniPay",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20),
              ).withPadding(right: 16),
              const Spacer(),
            ],
          ),
        ).withPadding(top: 16),
        const Divider(color: PaxColors.lightGrey),
      ],

      // Use Column as the main container
      child: SingleChildScrollView(
        child: InkWell(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: Column(
            children: [
              // Fixed-size content area (not scrollable)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SvgPicture.asset(
                        'lib/assets/svgs/minipay.svg',
                        height: 50,
                      ),
                    ),
                    const Text(
                      "Paste MiniPay Wallet Address",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ).withPadding(vertical: 20),

                    // _buildErrorMessage(connectionState).animate().fadeIn(),
                    Container(
                      padding: const EdgeInsets.all(8),
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        color: PaxColors.otherOrange.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: PaxColors.otherOrange,
                          width: 2,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            children: [
                              FaIcon(
                                FontAwesomeIcons.triangleExclamation,
                                color: PaxColors.otherOrange,
                                size: 20,
                              ).withPadding(right: 4),
                              // SvgPicture.asset(
                              //   'lib/assets/svgs/verification_required.svg',
                              // ).withPadding(right: 8),
                            ],
                          ),

                          Expanded(
                            child: Column(
                              children: [
                                InkWell(
                                  // onTap:
                                  //     () => UrlHandler.launchInAppWebView(
                                  //       context,
                                  //       'https://www.gooddollar.org/blog-posts/face-verification-challenge-identity',
                                  //     ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,

                                    children: [
                                      const Text(
                                        'GoodDollar',
                                        style: TextStyle(
                                          color: PaxColors.deepPurple,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SvgPicture.asset(
                                        'lib/assets/svgs/currencies/good_dollar.svg',
                                        height: 20,
                                      ),

                                      const Text(
                                        ' Face Verification Required',
                                        style: TextStyle(
                                          color: PaxColors.deepPurple,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      // .withPadding(right: 8),

                                      // SvgPicture.asset(
                                      //   'lib/assets/svgs/redirect_window.svg',
                                      //   height: 15,
                                      // ),
                                    ],
                                  ),
                                ),
                                // .withPadding(bottom: 8),
                                // Row(
                                //   crossAxisAlignment:
                                //       CrossAxisAlignment.start,
                                //   children: [
                                //     Expanded(
                                //       child: const Text(
                                //         'To connect successfully, your wallet should be GoodDollar verified.',
                                //         style: TextStyle(
                                //           color: PaxColors.black,
                                //           fontSize: 14,
                                //         ),
                                //       ),
                                //     ),
                                //   ],
                                // ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ).withPadding(bottom: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Wallet address (0x..)",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                          ),
                        ).withPadding(bottom: 20),
                        TextField(
                          controller: _walletAddressController,
                          onChanged: (value) {
                            // Reset error message when user types
                            if (connectionState.state ==
                                MiniPayConnectionState.error) {
                              ref
                                  .read(miniPayConnectionProvider.notifier)
                                  .resetState();
                            }
                            // Force UI update
                            setState(() {});
                          },
                          onSubmitted: (_) {
                            FocusManager.instance.primaryFocus?.unfocus();
                          },
                          textInputAction: TextInputAction.done,
                          scrollPhysics: const ClampingScrollPhysics(),
                          enabled: !connectionState.isConnecting,
                          keyboardType: TextInputType.text,
                          placeholder: const Text(
                            'Paste address here',
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
                                'lib/assets/svgs/wallet_address.svg',
                                height: 20,
                                width: 20,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ).withPadding(bottom: 20),

                    Row(
                      children: [
                        const Text(
                          "Don't have a wallet address?",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            color: PaxColors.black,
                            fontSize: 13,
                            fontWeight: FontWeight.normal,
                          ),
                        ).withPadding(right: 2),
                        InkWell(
                          onTap:
                              () => UrlHandler.launchInExternalBrowser(
                                'https://play.google.com/store/apps/details?id=com.opera.minipay&hl=en',
                              ),
                          child: Row(
                            children: [
                              const Text(
                                "Set up a MiniPay wallet",
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  color: PaxColors.black,
                                  fontSize: 13,
                                  fontWeight: FontWeight.normal,
                                  decoration: TextDecoration.underline,
                                ),
                              ).withPadding(vertical: 4, right: 4),
                              SvgPicture.asset(
                                'lib/assets/svgs/redirect_window.svg',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ).withPadding(bottom: 8),
                    const Divider().withPadding(vertical: 8),
                    Row(
                      children: [
                        const Text(
                          "How to do GoodDollar",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                          ),
                        ),

                        SvgPicture.asset(
                          'lib/assets/svgs/currencies/good_dollar.svg',
                          height: 20,
                        ),
                        const Text(
                          " Face Verification:",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),

                    const GoodDollarVerificationSteps().withPadding(
                      vertical: 8,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConnectButton(MiniPayConnectionStateModel connectionState) {
    // Show loading indicator when connecting
    if (connectionState.state != MiniPayConnectionState.initial &&
        connectionState.state != MiniPayConnectionState.error) {
      return SizedBox(
        width: double.infinity,
        height: 48,
        child: PrimaryButton(
          enabled: false,
          onPressed: null,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(onSurface: true),
              const SizedBox(width: 8),
              Text(
                'Connecting...',
                style: TextStyle(fontSize: 14, color: PaxColors.white),
              ),
            ],
          ),
        ),
      );
    }

    // Normal connect button
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: PrimaryButton(
        onPressed:
            _walletAddressController.text.trim().isNotEmpty &&
                    _walletAddressController.text.length >= 42
                ? _connectWallet
                : null,
        child: Text(
          'Connect',
          style: TextStyle(fontSize: 14, color: PaxColors.white),
        ),
      ),
    );
  }

  // Widget _buildErrorMessage(MiniPayConnectionStateModel connectionState) {
  //   if (connectionState.state == MiniPayConnectionState.error &&
  //       connectionState.errorMessage != null) {
  //     return Container(
  //           width: double.infinity,
  //           padding: const EdgeInsets.all(8),
  //           margin: const EdgeInsets.only(bottom: 16),
  //           decoration: BoxDecoration(
  //             color: PaxColors.red.withValues(alpha: 0.2),
  //             borderRadius: BorderRadius.circular(8),
  //             border: Border.all(color: PaxColors.red, width: 2),
  //           ),
  //           child: Row(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               FaIcon(
  //                 FontAwesomeIcons.xmark,
  //                 color: PaxColors.red,
  //                 size: 25,
  //               ).withPadding(right: 8),
  //               Expanded(
  //                 child: Text(
  //                   connectionState.errorMessage!,
  //                   style: TextStyle(color: PaxColors.red, fontSize: 14),
  //                 ),
  //               ),
  //             ],
  //           ),
  //         )
  //         .animate()
  //         .fadeIn(duration: 200.ms)
  //         .slideX(begin: -0.1, end: 0, duration: 200.ms, curve: Curves.easeOut);
  //   }
  //   return const SizedBox.shrink();
  // }
}

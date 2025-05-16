// views/minipay_connection_view.dart (refactored to use provider)
import 'package:flutter/material.dart' show Divider;
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart' show SvgPicture;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import 'package:pax/providers/auth/auth_provider.dart';
import 'package:pax/providers/minipay/minipay_provider.dart';
import 'package:pax/theming/colors.dart';
import 'package:pax/widgets/gooddollar_verification_steps.dart';

import 'package:shadcn_flutter/shadcn_flutter.dart' hide Divider;
import 'package:url_launcher/url_launcher.dart';

class MiniPayConnectionView extends ConsumerStatefulWidget {
  const MiniPayConnectionView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _MiniPayConnectionViewState();
}

class _MiniPayConnectionViewState extends ConsumerState<MiniPayConnectionView> {
  final TextEditingController _walletAddressController =
      TextEditingController();

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
    final walletAddress = _walletAddressController.text.trim();
    final authState = ref.read(authProvider);

    // Connect wallet using the provider
    ref
        .read(miniPayConnectionProvider.notifier)
        .connectPrimaryPaymentMethod(authState.user.uid, walletAddress);
  }

  // Show success dialog when connection is successful
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
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
              ).withPadding(bottom: 8),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 2.5,
                    child: PrimaryButton(
                      child: const Text('OK'),
                      onPressed: () {
                        context.pop();
                        context.pop(); // Pop the MiniPayConnectionView too
                      },
                    ),
                  ),
                ],
              ).withPadding(top: 8),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Watch the connection state
    final connectionState = ref.watch(miniPayConnectionProvider);

    // Show success dialog when connection is successful
    if (connectionState.state == MiniPayConnectionState.success) {
      // Use post-frame callback to avoid build phase issues
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showSuccessDialog();
      });
    }

    return Scaffold(
      footers: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              const Divider().withPadding(top: 10, bottom: 10),
              _buildConnectButton(connectionState),
            ],
          ),
        ).withPadding(bottom: 32),
      ],
      resizeToAvoidBottomInset: false,
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
        child: GestureDetector(
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

                    _buildErrorMessage(connectionState),

                    Visibility(
                      visible: !connectionState.isConnecting,

                      child: Container(
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
                                  size: 25,
                                ).withPadding(right: 8),
                                // SvgPicture.asset(
                                //   'lib/assets/svgs/verification_required.svg',
                                // ).withPadding(right: 8),
                              ],
                            ),

                            Expanded(
                              child: Column(
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                        ' Verification Required',
                                        style: TextStyle(
                                          color: PaxColors.deepPurple,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ).withPadding(bottom: 8),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: const Text(
                                          'To connect successfully, your wallet should be GoodDollar verified. \n\nIf verified, paste the address and connect.',
                                          style: TextStyle(
                                            color: PaxColors.black,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ).withPadding(bottom: 8),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Wallet address (0x..)",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                          ),
                        ).withPadding(bottom: 16),
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
                    ).withPadding(bottom: 16),

                    Row(
                      children: [
                        const Text(
                          "Don't have a wallet address?",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            color: PaxColors.black,
                            fontSize: 12,
                            fontWeight: FontWeight.normal,
                          ),
                        ).withPadding(right: 2),
                        GestureDetector(
                          onPanDown:
                              (details) =>
                                  _launchExternalUrl('https://www.minipay.to/'),

                          child: Row(
                            children: [
                              const Text(
                                "Set up a MiniPay wallet",
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  color: PaxColors.black,
                                  fontSize: 12,
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
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),

                        SvgPicture.asset(
                          'lib/assets/svgs/currencies/good_dollar.svg',
                          height: 20,
                        ),
                        const Text(
                          " verification:",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontSize: 18,
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
    // Different button states based on connection state
    switch (connectionState.state) {
      case MiniPayConnectionState.validating:
        return SizedBox(
          width: double.infinity,
          height: 48,
          child: PrimaryButton(
            enabled: true,
            onPressed: null,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(onSurface: true),
                ),
                const SizedBox(width: 8),
                Text(
                  'Validating address...',
                  style: Theme.of(context).typography.base.copyWith(
                    fontWeight: FontWeight.normal,
                    fontSize: 14,
                    color: PaxColors.white,
                  ),
                ),
              ],
            ),
          ),
        );

      case MiniPayConnectionState.checkingWhitelist:
        return SizedBox(
          width: double.infinity,
          height: 48,
          child: PrimaryButton(
            enabled: false,
            onPressed: null,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(onSurface: true),
                ),
                const SizedBox(width: 8),
                Text(
                  'Checking GoodDollar verification...',
                  style: Theme.of(context).typography.base.copyWith(
                    fontWeight: FontWeight.normal,
                    fontSize: 14,
                    color: PaxColors.white,
                  ),
                ),
              ],
            ),
          ),
        );

      case MiniPayConnectionState.creatingServerWallet ||
          MiniPayConnectionState.deployingContract ||
          MiniPayConnectionState.creatingPaymentMethod:
        return SizedBox(
          width: double.infinity,
          height: 48,
          child: PrimaryButton(
            enabled: false,
            onPressed: null,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(onSurface: true),
                ),
                const SizedBox(width: 8),
                Text(
                  'Connecting wallet...',
                  style: Theme.of(context).typography.base.copyWith(
                    fontWeight: FontWeight.normal,
                    fontSize: 14,
                    color: PaxColors.white,
                  ),
                ),
              ],
            ),
          ),
        );

      default:
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
              style: Theme.of(context).typography.base.copyWith(
                fontWeight: FontWeight.normal,
                fontSize: 14,
                color: PaxColors.white,
              ),
            ),
          ),
        );
    }
  }

  Widget _buildErrorMessage(MiniPayConnectionStateModel connectionState) {
    if (connectionState.state == MiniPayConnectionState.error &&
        connectionState.errorMessage != null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(8),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: PaxColors.red.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: PaxColors.red, width: 2),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FaIcon(
              FontAwesomeIcons.xmark,
              color: PaxColors.red,
              size: 25,
            ).withPadding(right: 8),
            // SvgPicture.asset(
            //   'lib/assets/svgs/error.svg',
            //   height: 20,
            // ).withPadding(right: 8, top: 2),
            Expanded(
              child: Text(
                connectionState.errorMessage!,
                style: TextStyle(color: PaxColors.red, fontSize: 14),
              ),
            ),
          ],
        ),
      ).animate().fadeIn().shader();
    }
    return const SizedBox.shrink();
  }

  Future<void> _launchExternalUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      // Show error if URL can't be launched
    }
  }
}

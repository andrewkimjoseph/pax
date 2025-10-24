import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pax/theming/colors.dart';
import 'package:pax/utils/responsive_util.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

/// Widget that restricts content to mobile screens only
class MobileOnlyWrapper extends ConsumerWidget {
  /// The child widget to display when on mobile screens
  final Widget child;

  /// Custom message to show on desktop screens
  final Widget? desktopMessage;

  const MobileOnlyWrapper({
    super.key,
    required this.child,
    this.desktopMessage,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ResponsiveUtil.shouldShowMobileOnlyMessage(context)) {
      return desktopMessage ?? _buildDefaultDesktopMessage(context);
    }
    return child;
  }

  /// Default desktop message widget using shadcn_flutter components
  Widget _buildDefaultDesktopMessage(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: PaxColors.white,
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const FaIcon(
                FontAwesomeIcons.mobileScreen,
                size: 64,
                color: PaxColors.darkGrey,
              ),
              const SizedBox(height: 16),
              Text(
                'Mobile App Only',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: PaxColors.black,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'This app is designed for mobile devices. Please access it from your smartphone or tablet.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: PaxColors.darkGrey,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: PaxColors.lightGrey,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const FaIcon(
                      FontAwesomeIcons.lightbulb,
                      size: 20,
                      color: PaxColors.darkGrey,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Tip: Try resizing your browser window to mobile size or use your device\'s developer tools to simulate a mobile view.',
                        style: TextStyle(
                          fontSize: 14,
                          color: PaxColors.darkGrey,
                        ),
                      ),
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
}

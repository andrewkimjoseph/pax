import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
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
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [PaxColors.deepPurple, Color(0xFF4A4380)],
        ),
      ),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 420),
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: PaxColors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: PaxColors.black.withValues(alpha: 0.2),
                blurRadius: 40,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Gradient icon container
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: PaxColors.orangeToPinkGradient,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: PaxColors.orange.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Image.asset(
                    'lib/assets/logos/main.png',
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 28),
              // Title with gradient text effect
              ShaderMask(
                shaderCallback:
                    (bounds) => const LinearGradient(
                      colors: [PaxColors.deepPurple, PaxColors.mediumPurple],
                    ).createShader(bounds),
                child: Text(
                  'Mobile Experience',
                  style: GoogleFonts.sen(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: PaxColors.white,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Pax is designed for the best experience on your smartphone or tablet.',
                textAlign: TextAlign.center,
                style: GoogleFonts.sen(
                  fontSize: 16,
                  color: PaxColors.darkGrey.withValues(alpha: 0.8),
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 28),
              // Tip card with subtle styling
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: PaxColors.deepPurple.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: PaxColors.deepPurple.withValues(alpha: 0.1),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: PaxColors.deepPurple.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: FaIcon(
                          FontAwesomeIcons.lightbulb,
                          size: 18,
                          color: PaxColors.deepPurple,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Resize your browser to mobile dimensions or use developer tools to preview.',
                        style: GoogleFonts.sen(
                          fontSize: 13,
                          color: PaxColors.darkGrey.withValues(alpha: 0.7),
                          height: 1.4,
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

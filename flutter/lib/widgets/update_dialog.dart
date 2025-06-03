import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pax/providers/analytics/analytics_provider.dart';
import 'package:pax/providers/remote_config/remote_config_provider.dart';
import 'package:pax/theming/colors.dart';
import 'package:pax/utils/version_util.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' hide Colors;
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';

class UpdateDialog extends ConsumerWidget {
  const UpdateDialog({super.key});

  Future<String> getCurrentAppVersion() async {
    final info = await PackageInfo.fromPlatform();
    return info.version;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appVersionConfigAsync = ref.watch(appVersionConfigProvider);

    return appVersionConfigAsync.when(
      data: (config) {
        return FutureBuilder<String>(
          future: getCurrentAppVersion(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const SizedBox.shrink();
            if (snapshot.hasError) return const SizedBox.shrink();

            final currentAppVersion = snapshot.data!;
            final needsUpdate =
                config.forceUpdate &&
                VersionUtil.isVersionLower(
                  currentAppVersion,
                  config.minimumVersion,
                );

            if (!needsUpdate) return const SizedBox.shrink();

            return Stack(
              children: [
                Container(color: PaxColors.black.withValues(alpha: 0.5)),
                AlertDialog(
                  content: SizedBox(
                    width: MediaQuery.of(context).size.width / 2,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          'lib/assets/svgs/canvassing.svg',
                          height: 48,
                        ).withPadding(bottom: 16),
                        const Text(
                          'Update Required',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ).withPadding(bottom: 16),
                        Text(
                          config.updateMessage,
                          style: const TextStyle(fontSize: 16),
                          textAlign: TextAlign.center,
                        ).withPadding(bottom: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const FaIcon(
                              FontAwesomeIcons.circleArrowRight,
                              size: 16,
                            ).withPadding(right: 8),
                            Text(
                              '(v${config.minimumVersion})',
                              style: const TextStyle(fontSize: 16),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ).withPadding(top: 12, bottom: 24),
                        SizedBox(
                          width: MediaQuery.of(context).size.width / 2.5,
                          child: PrimaryButton(
                            onPressed: () async {
                              ref.read(analyticsProvider).updateNowTapped();
                              final url = Uri.parse(config.updateUrl);
                              if (await canLaunchUrl(url)) {
                                await launchUrl(url);
                              }
                            },
                            child: const Text('Update Now'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ).withAlign(Alignment.center),
              ],
            );
          },
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

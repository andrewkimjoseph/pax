import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pax/theming/colors.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class LogOutDrawer extends ConsumerStatefulWidget {
  final VoidCallback onClose;
  final BuildContext rootContext;
  final VoidCallback onLogoutConfirmed;
  const LogOutDrawer({
    super.key,
    required this.onClose,
    required this.rootContext,
    required this.onLogoutConfirmed,
  });

  @override
  ConsumerState<LogOutDrawer> createState() => _LogOutDrawerState();
}

class _LogOutDrawerState extends ConsumerState<LogOutDrawer> {
  bool isLoggingOut = false;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !isLoggingOut,
      child: Container(
        padding: const EdgeInsets.all(4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Logout",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ).withPadding(bottom: 8),
                Divider().withPadding(top: 8, bottom: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        "Are you sure you want to log out?",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                          fontWeight: FontWeight.normal,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ).withPadding(top: 8, bottom: 32),
                Divider().withPadding(top: 8, bottom: 8),
              ],
            ).withPadding(left: 16, right: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.4,
                  height: 48,
                  child: Button(
                    style: const ButtonStyle.primary(),
                    onPressed: isLoggingOut ? null : widget.onClose,
                    child: Text(
                      'Cancel',
                      style: Theme.of(context).typography.base.copyWith(
                        fontWeight: FontWeight.normal,
                        fontSize: 14,
                        color: PaxColors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.4,
                  height: 48,
                  child: Button.outline(
                    onPressed:
                        isLoggingOut
                            ? null
                            : () async {
                              setState(() {
                                isLoggingOut = true;
                              });
                              closeDrawer(context);
                              await Future.delayed(
                                const Duration(milliseconds: 300),
                              );
                              if (!widget.rootContext.mounted) return;
                              widget.onLogoutConfirmed();
                              setState(() {
                                isLoggingOut = false;
                              });
                            },
                    child:
                        isLoggingOut
                            ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Logging out',
                                  style: Theme.of(
                                    context,
                                  ).typography.base.copyWith(
                                    fontWeight: FontWeight.normal,
                                    fontSize: 14,
                                    color: PaxColors.deepPurple,
                                  ),
                                ),
                              ],
                            )
                            : Text(
                              'Yes, Logout',
                              style: Theme.of(context).typography.base.copyWith(
                                fontWeight: FontWeight.normal,
                                fontSize: 14,
                                color: PaxColors.deepPurple,
                              ),
                            ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ).withPadding(bottom: 32),
    );
  }
}

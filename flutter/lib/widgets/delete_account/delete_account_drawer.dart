import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:pax/providers/account/account_deletion_provider.dart';
import 'package:pax/providers/analytics/analytics_provider.dart';
import 'package:pax/theming/colors.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:pax/widgets/toast.dart';

class DeleteAccountDrawer extends ConsumerStatefulWidget {
  final VoidCallback onClose;
  final BuildContext rootContext;

  const DeleteAccountDrawer({
    super.key,
    required this.onClose,
    required this.rootContext,
  });

  @override
  ConsumerState<DeleteAccountDrawer> createState() =>
      _DeleteAccountDrawerState();
}

class _DeleteAccountDrawerState extends ConsumerState<DeleteAccountDrawer> {
  bool _hasShownToast = false;

  @override
  void initState() {
    super.initState();
    _hasShownToast = false;
  }

  @override
  Widget build(BuildContext context) {
    final deletionState = ref.watch(accountDeletionProvider);

    // Handle success state
    if (deletionState.state == AccountDeletionState.success &&
        !_hasShownToast) {
      _hasShownToast = true;
      ref.read(analyticsProvider).accountDeletionComplete();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showToast(
          context: widget.rootContext,
          location: ToastLocation.topCenter,
          builder:
              (context, overlay) => Toast(
                toastColor: PaxColors.green,
                text: "Account successfully deleted",
                trailingIcon: FontAwesomeIcons.solidCircleCheck,
              ),
        );

        // Navigate to onboarding after a short delay to show the toast
        Future.delayed(const Duration(seconds: 2), () {
          if (context.mounted) {
            context.go('/onboarding');
          }
        });
      });
    }

    // Handle error state
    if (deletionState.state == AccountDeletionState.error &&
        deletionState.errorMessage != null &&
        !_hasShownToast) {
      _hasShownToast = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showToast(
          context: widget.rootContext,
          location: ToastLocation.topCenter,
          builder:
              (context, overlay) => Toast(
                toastColor:
                    deletionState.errorMessage!.contains("withdraw all funds")
                        ? PaxColors.orange
                        : PaxColors.red,
                text: deletionState.errorMessage!,
                trailingIcon: FontAwesomeIcons.triangleExclamation,
              ),
        );
        widget.onClose();
      });
    }

    return PopScope(
      canPop: false,
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
                      "Delete account",
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
                        "Are you sure you want to delete your account?",
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
                    onPressed: widget.onClose,
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
                        deletionState.isDeleting
                            ? null
                            : () async {
                              await ref
                                  .read(accountDeletionProvider.notifier)
                                  .deleteAccount();
                            },
                    child:
                        deletionState.isDeleting
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
                                  'Processing...',
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
                              'Yes, delete',
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

// String? selectedValue;
// @override
// Widget build(BuildContext context) {
//   return 
// }


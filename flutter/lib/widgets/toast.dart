import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pax/exports/shadcn.dart';
import 'package:pax/theming/colors.dart';

class Toast extends ConsumerWidget {
  const Toast({
    required this.toastColor,
    required this.text,
    required this.trailingIcon,

    this.trailingIconColor = PaxColors.white,
    this.leadingIcon,
    this.leadingIconColor = PaxColors.white,
    super.key,
  });

  final Color toastColor;

  final String text;

  final Color leadingIconColor;

  final Color trailingIconColor;
  final IconData? leadingIcon;

  final IconData trailingIcon;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.95,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: toastColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Basic(
        leading:
            leadingIcon != null
                ? FaIcon(leadingIcon, color: leadingIconColor)
                : null,
        subtitle: Text(text, style: TextStyle(color: PaxColors.white)),
        trailing: FaIcon(trailingIcon, color: trailingIconColor),
        trailingAlignment: Alignment.center,
      ),
    );
  }
}

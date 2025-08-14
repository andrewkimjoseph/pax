import 'package:flutter/material.dart' show InkWell;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pax/theming/colors.dart' show PaxColors;
import 'package:pax/utils/gradient_border.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class GoodDollarStepImage extends ConsumerWidget {
  const GoodDollarStepImage(this.step, this.route, {super.key});
  final String step;
  final String route;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imagePath =
        'lib/assets/images/gooddollar_verification_steps/$step.png';

    return InkWell(
      onTap: () {
        context.go(
          '/withdrawal-methods/$route/image-photo-view',
          extra: imagePath,
        );
      },
      child: Container(
        height: 270,
        decoration: ShapeDecoration(
          shape: GradientBorder(
            gradient: LinearGradient(
              colors: PaxColors.orangeToPinkGradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            width: 2,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset(
            imagePath,
            fit: BoxFit.fitHeight,
            filterQuality: FilterQuality.high,
          ),
        ),
      ),
    );
  }
}

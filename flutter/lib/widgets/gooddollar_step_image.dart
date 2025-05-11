import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pax/theming/colors.dart' show PaxColors;
import 'package:pax/utils/gradient_border.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class GoodDollarStepImage extends ConsumerWidget {
  const GoodDollarStepImage(this.step, {super.key});
  final String step;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
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
        image: DecorationImage(
          filterQuality: FilterQuality.high,
          image: AssetImage(
            'lib/assets/images/gooddollar_verification_steps/$step.png',
          ),
          fit: BoxFit.fitHeight,
        ),
      ),
    );
  }
}

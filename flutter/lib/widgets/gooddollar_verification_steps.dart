import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pax/widgets/gooddollar_step_image.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class GoodDollarVerificationSteps extends ConsumerStatefulWidget {
  const GoodDollarVerificationSteps({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _GoodDollarVerificationStepsState();
}

class _GoodDollarVerificationStepsState
    extends ConsumerState<GoodDollarVerificationSteps> {
  final StepperController controller = StepperController();

  @override
  Widget build(BuildContext context) {
    return Stepper(
      controller: controller,
      direction: Axis.vertical,
      steps: [
        Step(
          title: const Text('Step 1: MiniPay > Apps (Mini Apps)'),
          contentBuilder: (context) {
            return StepContainer(
              actions: [
                const OutlineButton(child: Text('Prev')),
                PrimaryButton(
                  child: const Text('Next'),
                  onPressed: () {
                    controller.nextStep();
                  },
                ),
              ],
              child: GoodDollarStepImage('step_1'),
            );
          },
        ),
        Step(
          title: const Text("Step 2: Finance > Universal basic income"),
          contentBuilder: (context) {
            return StepContainer(
              actions: [
                OutlineButton(
                  child: const Text('Prev'),
                  onPressed: () {
                    controller.previousStep();
                  },
                ),
                PrimaryButton(
                  child: const Text('Next'),
                  onPressed: () {
                    controller.nextStep();
                  },
                ),
              ],
              child: GoodDollarStepImage('step_2'),
            );
          },
        ),
        Step(
          title: const Text("Step 3: Claim Now > Verify I'm Human"),
          contentBuilder: (context) {
            return StepContainer(
              actions: [
                OutlineButton(
                  child: const Text('Prev'),
                  onPressed: () {
                    controller.previousStep();
                  },
                ),
                PrimaryButton(
                  child: const Text('Next'),
                  onPressed: () {
                    controller.nextStep();
                  },
                ),
              ],
              child: GoodDollarStepImage('step_3'),
            );
          },
        ),
        Step(
          title: const Text("Step 4: Sign message"),
          contentBuilder: (context) {
            return StepContainer(
              actions: [
                OutlineButton(
                  child: const Text('Prev'),
                  onPressed: () {
                    controller.previousStep();
                  },
                ),
                PrimaryButton(
                  child: const Text('Next'),
                  onPressed: () {
                    controller.nextStep();
                  },
                ),
              ],
              child: GoodDollarStepImage('step_4'),
            );
          },
        ),
        Step(
          title: const Text("Step 5: Complete face verification"),
          contentBuilder: (context) {
            return StepContainer(
              actions: [
                OutlineButton(
                  child: const Text('Prev'),
                  onPressed: () {
                    controller.previousStep();
                  },
                ),
                PrimaryButton(
                  child: const Text('Finish'),
                  onPressed: () {
                    controller.nextStep();
                  },
                ),
              ],
              child: GoodDollarStepImage('step_5'),
            );
          },
        ),
      ],
    );
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pax/widgets/gooddollar_step_image.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class MiniPayLinkingStepsWithFaceVerification extends ConsumerStatefulWidget {
  const MiniPayLinkingStepsWithFaceVerification({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _MinipayLinkingStepsWithFaceVerificationState();
}

class _MinipayLinkingStepsWithFaceVerificationState
    extends ConsumerState<MiniPayLinkingStepsWithFaceVerification> {
  final StepperController controller = StepperController();

  @override
  Widget build(BuildContext context) {
    return Stepper(
      controller: controller,
      direction: Axis.vertical,
      steps: [
        Step(
          title:
              const Text(
                'Step 1: Download MiniPay > Apps (Mini Apps).',
              ).expanded(),
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
              child: GoodDollarStepImage(
                'minipay/with_face_verification/step_1',
                'minipay-connection',
              ),
            );
          },
        ),
        Step(
          title:
              const Text(
                "Step 2: Finance > Universal basic income.",
              ).expanded(),
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
              child: GoodDollarStepImage(
                'minipay/with_face_verification/step_2',
                'minipay-connection',
              ),
            );
          },
        ),
        Step(
          title: const Text("Step 3: Claim Now > Verify I'm Human.").expanded(),
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
              child: GoodDollarStepImage(
                'minipay/with_face_verification/step_3',
                'minipay-connection',
              ),
            );
          },
        ),
        Step(
          title: const Text("Step 4: Sign message.").expanded(),
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
              child: GoodDollarStepImage(
                'minipay/with_face_verification/step_4',
                'minipay-connection',
              ),
            );
          },
        ),
        Step(
          title: const Text("Step 5: Complete face verification.").expanded(),
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
              child: GoodDollarStepImage(
                'minipay/with_face_verification/step_5',
                'minipay-connection',
              ),
            );
          },
        ),
      ],
    );
  }
}

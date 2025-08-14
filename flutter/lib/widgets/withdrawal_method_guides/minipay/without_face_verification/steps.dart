import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pax/widgets/gooddollar_step_image.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class MiniPayLinkingStepsWithoutFaceVerification
    extends ConsumerStatefulWidget {
  const MiniPayLinkingStepsWithoutFaceVerification({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _MinipayLinkingStepsWithoutFaceVerificationState();
}

class _MinipayLinkingStepsWithoutFaceVerificationState
    extends ConsumerState<MiniPayLinkingStepsWithoutFaceVerification> {
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
                'Step 1: Download MiniPay and sign in with Google',
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
                'minipay/without_face_verification/step_1',
                'minipay-connection',
              ),
            );
          },
        ),
        Step(
          title:
              const Text(
                "Step 2: Complete the sign up process - connect your phone number to MiniPay",
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
                'minipay/without_face_verification/step_2',
                'minipay-connection',
              ),
            );
          },
        ),
        Step(
          title:
              const Text("Step 3: Tap Deposit and select Exchange").expanded(),
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
                'minipay/without_face_verification/step_3',
                'minipay-connection',
              ),
            );
          },
        ),
        Step(
          title:
              const Text(
                "Step 4: Check the box and then Get started",
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
                'minipay/without_face_verification/step_4',
                'minipay-connection',
              ),
            );
          },
        ),
        Step(
          title:
              const Text(
                "Step 5: Tap the copy icon to get your wallet address",
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
                  child: const Text('Finish'),
                  onPressed: () {
                    controller.nextStep();
                  },
                ),
              ],
              child: GoodDollarStepImage(
                'minipay/without_face_verification/step_5',
                'minipay-connection',
              ),
            );
          },
        ),
      ],
    );
  }
}

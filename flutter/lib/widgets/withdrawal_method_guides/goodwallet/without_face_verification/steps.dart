import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pax/widgets/gooddollar_step_image.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class GoodWalletLinkingStepsWithoutFaceVerification
    extends ConsumerStatefulWidget {
  const GoodWalletLinkingStepsWithoutFaceVerification({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _GoodWalletLinkingStepsWithoutFaceVerificationState();
}

class _GoodWalletLinkingStepsWithoutFaceVerificationState
    extends ConsumerState<GoodWalletLinkingStepsWithoutFaceVerification> {
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
                'Step 1: Open GoodWallet (link above) and Continue with Google.',
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
                'good_wallet/without_face_verification/step_1',
                'good-wallet-connection',
              ),
            );
          },
        ),
        Step(
          title: const Text("Step 2: Tap the Receive button.").expanded(),
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
                'good_wallet/without_face_verification/step_2',
                'good-wallet-connection',
              ),
            );
          },
        ),
        Step(
          title:
              const Text(
                "Step 3: Tap the network dropdown button with Ethereum selected.",
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
                'good_wallet/without_face_verification/step_3',
                'good-wallet-connection',
              ),
            );
          },
        ),
        Step(
          title: const Text("Step 4: Select Celo as the network.").expanded(),
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
                'good_wallet/without_face_verification/step_4',
                'good-wallet-connection',
              ),
            );
          },
        ),
        Step(
          title:
              const Text(
                "Step 5: In the wallet, tap the copy icon and select Celo to get the verified wallet address.",
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
                'good_wallet/without_face_verification/step_5',
                'good-wallet-connection',
              ),
            );
          },
        ),
      ],
    );
  }
}

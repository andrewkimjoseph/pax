import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pax/widgets/gooddollar_step_image.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class ForCopyingMiniPayWalletAddress extends ConsumerStatefulWidget {
  const ForCopyingMiniPayWalletAddress({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ForCopyingMiniPayWalletAddressState();
}

class _ForCopyingMiniPayWalletAddressState
    extends ConsumerState<ForCopyingMiniPayWalletAddress> {
  final StepperController controller = StepperController();

  @override
  Widget build(BuildContext context) {
    return Stepper(
      controller: controller,
      direction: Axis.vertical,
      steps: [
        Step(
          title:
              const Text("Step 1: Tap Deposit and select Exchange").expanded(),
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
                'minipay-connection/copy-wallet-address',
              ),
            );
          },
        ),
        Step(
          title:
              const Text(
                "Step 2: Check the box and then Get started",
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
                'minipay-connection/copy-wallet-address',
              ),
            );
          },
        ),
        Step(
          title:
              const Text(
                "Step 3: Tap the copy icon to get your wallet address",
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
                'minipay-connection/copy-wallet-address',
              ),
            );
          },
        ),
      ],
    );
  }
}

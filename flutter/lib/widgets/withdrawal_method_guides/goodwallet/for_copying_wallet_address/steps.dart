import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pax/widgets/gooddollar_step_image.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class ForCopyingGoodWalletWalletAddress extends ConsumerStatefulWidget {
  const ForCopyingGoodWalletWalletAddress({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ForCopyingGoodWalletWalletAddressState();
}

class _ForCopyingGoodWalletWalletAddressState
    extends ConsumerState<ForCopyingGoodWalletWalletAddress> {
  final StepperController controller = StepperController();

  @override
  Widget build(BuildContext context) {
    return Stepper(
      controller: controller,
      direction: Axis.vertical,
      steps: [
        Step(
          title: const Text("Step 1: Tap the Receive button.").expanded(),
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
                'good-wallet-connection/copy-wallet-address',
              ),
            );
          },
        ),
        Step(
          title:
              const Text(
                "Step 2: Tap the dropdown button with Ethereum selected.",
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
                'good-wallet-connection/copy-wallet-address',
              ),
            );
          },
        ),
        Step(
          title: const Text("Step 3: Select Celo from the list.").expanded(),
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
                'good-wallet-connection/copy-wallet-address',
              ),
            );
          },
        ),
        Step(
          title:
              const Text(
                "Step 4: Tap the copy icon to get the wallet address.",
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
                'good-wallet-connection/copy-wallet-address',
              ),
            );
          },
        ),
      ],
    );
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pax/widgets/gooddollar_step_image.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class GoodWalletGoodDollarVerificationSteps extends ConsumerStatefulWidget {
  const GoodWalletGoodDollarVerificationSteps({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _GoodWalletGoodDollarVerificationStepsState();
}

class _GoodWalletGoodDollarVerificationStepsState
    extends ConsumerState<GoodWalletGoodDollarVerificationSteps> {
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
              child: GoodDollarStepImage('good_wallet/step_1'),
            );
          },
        ),
        Step(
          title: const Text("Step 2: Tap the Claim button.").expanded(),
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
              child: GoodDollarStepImage('good_wallet/step_2'),
            );
          },
        ),
        Step(
          title:
              const Text(
                "Step 3: Tap Verify and confirm you are over 18 years to complete face verification.",
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
              child: GoodDollarStepImage('good_wallet/step_3'),
            );
          },
        ),
        Step(
          title: const Text("Step 4: Complete face verification.").expanded(),
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
              child: GoodDollarStepImage('good_wallet/step_4'),
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
              child: GoodDollarStepImage('good_wallet/step_5'),
            );
          },
        ),
      ],
    );
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pax/widgets/socials/telegram_join_card.dart';
import 'package:pax/widgets/socials/whatsapp_join_card.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:pax/widgets/socials/x_follow_card.dart';

class SocialLinksCarousel extends ConsumerStatefulWidget {
  const SocialLinksCarousel({super.key});

  @override
  ConsumerState<SocialLinksCarousel> createState() =>
      _SocialLinksCarouselState();
}

class _SocialLinksCarouselState extends ConsumerState<SocialLinksCarousel> {
  final CarouselController controller = CarouselController();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 100,
            child: Carousel(
              pauseOnHover: false,
              disableDraggingVelocity: true,
              transition: const CarouselTransition.sliding(gap: 6),
              controller: controller,
              autoplaySpeed: const Duration(seconds: 5),
              itemCount: 3,
              itemBuilder: (context, index) {
                return index == 0
                    ? const XFollowCard()
                    : index == 1
                    ? const WhatsappFollowCard()
                    : const TelegramFollowCard();
              },
              // Duration of the slide transition animation.
              duration: const Duration(seconds: 1),
            ),
          ),
        ),
        // const Gap(12),
        // OutlineButton(
        //   shape: ButtonShape.circle,
        //   onPressed: () {
        //     // Animate to next slide.
        //     controller.animateNext(const Duration(milliseconds: 500));
        //   },
        //   child: const Icon(Icons.arrow_forward),
        // ),
      ],
    );
  }
}

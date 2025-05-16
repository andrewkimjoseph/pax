import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pax/theming/colors.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class AchievementEarningCard extends ConsumerWidget {
  const AchievementEarningCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: EdgeInsets.all(10),
      width: double.infinity,
      decoration: BoxDecoration(
        color: PaxColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: PaxColors.lightGrey,
            spreadRadius: 1,
            blurRadius: 2,
            offset: Offset(0, 1), // changes position of shadow
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Survey starter',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  color: PaxColors.black,
                ),
              ).withPadding(bottom: 8),
            ],
          ).withPadding(bottom: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Complete your first survey to earn Good Dollar tokens',
                  style: TextStyle(fontSize: 12, color: PaxColors.black),
                ).withPadding(bottom: 8),
              ),
            ],
          ).withPadding(bottom: 8),

          SizedBox(
            width: double.infinity,
            child: Button(
              style: const ButtonStyle.primary(
                density: ButtonDensity.normal,
              ).withBorderRadius(borderRadius: BorderRadius.circular(7)),

              onPressed: () {},
              child: Text(
                'Start Earning rewards',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                  color: PaxColors.white, // The purple color from your images
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

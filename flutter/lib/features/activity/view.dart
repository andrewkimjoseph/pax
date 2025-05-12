import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pax/widgets/activity_card.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import '../../theming/colors.dart' show PaxColors;

class ActivityView extends ConsumerStatefulWidget {
  const ActivityView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ActivityViewState();
}

class _ActivityViewState extends ConsumerState<ActivityView> {
  int index = 0;
  int selected = 0;
  String? screenName;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      headers: [
        AppBar(
          height: 87.5,
          padding: EdgeInsets.all(8),
          backgroundColor: PaxColors.white,
          header: Row(
            children: [
              Text(
                'Activity',
                style: Theme.of(context).typography.base.copyWith(
                  fontWeight: FontWeight.w900,
                  fontSize: 32,
                  color: PaxColors.black, // The purple color from your images
                ),
              ),
            ],
          ).withPadding(bottom: 8),
          subtitle: Row(
            children: [
              Button(
                style: const ButtonStyle.primary(density: ButtonDensity.dense)
                    .withBackgroundColor(
                      color:
                          index == 0
                              ? PaxColors.deepPurple
                              : Colors.transparent,
                    )
                    .withBorder(
                      border: Border.all(
                        color:
                            index == 0 ? PaxColors.deepPurple : PaxColors.lilac,
                        width: 2,
                      ),
                    )
                    .withBorderRadius(borderRadius: BorderRadius.circular(7)),
                onPressed: () {
                  setState(() {
                    index = 0;
                  });
                },

                child: Text(
                  'Task Completions',
                  style: TextStyle(
                    color: index == 0 ? PaxColors.white : PaxColors.black,
                  ),
                ),
              ).withPadding(right: 8),

              Button(
                style: const ButtonStyle.primary(density: ButtonDensity.dense)
                    .withBackgroundColor(
                      color:
                          index == 1
                              ? PaxColors.deepPurple
                              : Colors.transparent,
                    )
                    .withBorder(
                      border: Border.all(
                        color:
                            index == 1 ? PaxColors.deepPurple : PaxColors.lilac,
                        width: 2,
                      ),
                    )
                    .withBorderRadius(borderRadius: BorderRadius.circular(7)),
                onPressed: () {
                  setState(() {
                    index = 1;
                  });
                },

                child: Text(
                  'Rewards',
                  style: TextStyle(
                    color: index == 1 ? PaxColors.white : PaxColors.black,
                  ),
                ),
              ).withPadding(right: 8),

              Button(
                style: const ButtonStyle.primary(density: ButtonDensity.dense)
                    .withBackgroundColor(
                      color:
                          index == 2
                              ? PaxColors.deepPurple
                              : Colors.transparent,
                    )
                    .withBorder(
                      border: Border.all(
                        color:
                            index == 2 ? PaxColors.deepPurple : PaxColors.lilac,
                        width: 2,
                      ),
                    )
                    .withBorderRadius(borderRadius: BorderRadius.circular(7)),
                onPressed: () {
                  setState(() {
                    index = 2;
                  });
                },

                child: Text(
                  'Withdrawals',
                  style: TextStyle(
                    color: index == 2 ? PaxColors.white : PaxColors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
        Divider(color: PaxColors.lightGrey),
      ],

      child: SingleChildScrollView(
        child: Column(
          children: [
            // for (var item in [1, 2, 3, 4, 5, 6, 7])
            ActivityCard('payout').withPadding(all: 8),
            ActivityCard('task_completion').withPadding(all: 8),
            ActivityCard('reward').withPadding(all: 8),
            ActivityCard('payout').withPadding(all: 8),
            ActivityCard('task_completion').withPadding(all: 8),
            ActivityCard('reward').withPadding(all: 8),
            ActivityCard('payout').withPadding(all: 8),
            ActivityCard('task_completion').withPadding(all: 8),
            ActivityCard('reward').withPadding(all: 8),
          ],
        ),
      ),
    );
  }
}

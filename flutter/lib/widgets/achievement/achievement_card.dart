import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:pax/theming/colors.dart';
import 'package:pax/utils/gradient_border.dart';
import 'package:pax/models/firestore/achievement/achievement_model.dart';
import 'package:pax/utils/token_balance_util.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:intl/intl.dart';
import 'package:pax/providers/local/achievement_provider.dart';
import 'package:pax/utils/currency_symbol.dart';

class AchievementCard extends ConsumerStatefulWidget {
  const AchievementCard({required this.achievement, super.key});

  final Achievement achievement;

  @override
  ConsumerState<AchievementCard> createState() => _AchievementCardState();
}

class _AchievementCardState extends ConsumerState<AchievementCard> {
  @override
  Widget build(BuildContext context) {
    final isEarned = widget.achievement.status == AchievementStatus.earned;
    final isClaimed = widget.achievement.status == AchievementStatus.claimed;
    final claimState = ref.watch(achievementClaimProvider);
    final isClaiming = claimState.isClaiming(widget.achievement.id);

    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.all(8),
      decoration:
          isEarned && !isClaimed
              ? ShapeDecoration(
                shape: GradientBorder(
                  gradient: LinearGradient(
                    colors: PaxColors.orangeToPinkGradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  width: 2,
                  borderRadius: BorderRadius.circular(12),
                ),
                color: Colors.white,
              )
              : BoxDecoration(
                color: PaxColors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: PaxColors.lightLilac, width: 1),
              ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  SvgPicture.asset(
                    'lib/assets/svgs/achievements/${widget.achievement.svgAssetName}.svg',
                    height: 48,
                  ).withPadding(right: 12),
                ],
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            widget.achievement.name ?? 'Achievement',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                              color: PaxColors.black,
                            ),
                          ),
                        ),
                        Text(
                          isEarned
                              ? 'Earned'
                              : 'G\$ ${widget.achievement.amountEarned}',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ).withPadding(bottom: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.achievement.goal,
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                            fontSize: 12,
                            color: PaxColors.black,
                          ),
                        ).withPadding(bottom: 8),

                        if (isEarned || isClaimed)
                          Text(
                            'Earned on ${DateFormat('MMMM d, yyyy | h:mm a').format(widget.achievement.timeCompleted!.toDate())}',
                            style: TextStyle(
                              fontWeight: FontWeight.normal,
                              fontSize: 11,
                              color: PaxColors.black,
                            ),
                          ),

                        if (!isEarned && !isClaimed)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: double.infinity,
                                height: 5,
                                child: ShaderMask(
                                  shaderCallback: (Rect bounds) {
                                    return LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: PaxColors.orangeToPinkGradient,
                                      stops: [0.0, 1.0],
                                    ).createShader(bounds);
                                  },
                                  blendMode: BlendMode.srcIn,
                                  child: Progress(
                                    progress:
                                        (widget.achievement.tasksCompleted /
                                                widget
                                                    .achievement
                                                    .tasksNeededForCompletion *
                                                100)
                                            .toDouble(),
                                    min: 0,
                                    max: 100,
                                  ),
                                ),
                              ).withPadding(bottom: 4),

                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${widget.achievement.tasksCompleted}/${widget.achievement.tasksNeededForCompletion}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.normal,
                                      fontSize: 11,
                                      color: PaxColors.black,
                                    ),
                                  ),
                                  Text(
                                    'Complete ${widget.achievement.tasksNeededForCompletion - widget.achievement.tasksCompleted} more to earn',
                                    style: TextStyle(
                                      fontWeight: FontWeight.normal,
                                      fontSize: 11,
                                      color: PaxColors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ).withPadding(bottom: 8),
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: 35,
            child: Button(
              onPressed: isClaiming ? null : _handleClaim,
              enabled: isEarned && !isClaimed && !isClaiming,
              style:
                  isEarned && !isClaimed && !isClaiming
                      ? const ButtonStyle.primary(
                        density: ButtonDensity.dense,
                      ).withBorderRadius(borderRadius: BorderRadius.circular(7))
                      : const ButtonStyle.outline(density: ButtonDensity.dense)
                          .withBorderRadius(
                            borderRadius: BorderRadius.circular(7),
                          )
                          .withBorder(
                            border: Border.all(
                              color: PaxColors.mediumPurple,
                              width: 2,
                            ),
                          ),
              child:
                  isClaiming
                      ? CircularProgressIndicator()
                      : Text(
                        isClaimed
                            ? 'Claimed G\$ ${widget.achievement.amountEarned}'
                            : 'Claim G\$ ${widget.achievement.amountEarned}',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                          color:
                              isEarned && !isClaimed && !isClaiming
                                  ? PaxColors.white
                                  : PaxColors.lilac,
                        ),
                      ),
            ),
          ),
        ],
      ),
    ).withPadding(bottom: 8);
  }

  Future<void> _handleClaim() async {
    final claimState = ref.read(achievementClaimProvider.notifier);

    // Show claiming dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (dialogContext) => AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                SizedBox(height: 8),
                Text(
                  'Please wait while we process your claim...',
                  style: TextStyle(
                    color: PaxColors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
    );

    try {
      await claimState.claimAchievement(achievement: widget.achievement);

      if (!mounted) return;
      context.pop();

      // Show success dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (dialogContext) => AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    'lib/assets/svgs/withdrawal_complete.svg',
                  ).withPadding(bottom: 8),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Achievement Claimed!',
                        style: TextStyle(
                          color: PaxColors.deepPurple,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ).withPadding(bottom: 8).withAlign(Alignment.center),
                    ],
                  ),

                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            TokenBalanceUtil.getLocaleFormattedAmount(
                              widget.achievement.amountEarned ?? 0,
                            ),
                            style: TextStyle(
                              color: PaxColors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SvgPicture.asset(
                            'lib/assets/svgs/currencies/${CurrencySymbolUtil.getNameForCurrency(1)}.svg',
                            height: 25,
                          ),
                        ],
                      ).withPadding(vertical: 4),
                      Text(
                        'has been added to your wallet!',
                        style: TextStyle(
                          color: PaxColors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                        ),
                        textAlign: TextAlign.center,
                      ).withPadding(vertical: 8),
                    ],
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 2.5,
                        child: PrimaryButton(
                          child: const Text('OK'),
                          onPressed: () => dialogContext.pop(),
                        ),
                      ),
                    ],
                  ).withPadding(top: 8),
                ],
              ),
            ),
      );
    } catch (e) {
      if (!mounted) return;
      context.pop();

      // Show error dialog
      showDialog(
        context: context,
        builder:
            (dialogContext) => AlertDialog(
              title: Column(
                children: [
                  SvgPicture.asset(
                    'lib/assets/svgs/canvassing.svg',
                    height: 24,
                  ).withPadding(bottom: 16),
                  Text(
                    'Claim Failed',
                    style: TextStyle(fontSize: 16),
                  ).withAlign(Alignment.center),
                ],
              ),
              content: Text(
                e.toString(),
                maxLines: 5,
                overflow: TextOverflow.ellipsis,
              ),
              actions: [
                OutlineButton(
                  onPressed: () => dialogContext.pop(),
                  child: Text('OK'),
                ),
              ],
            ),
      );
    }
  }
}

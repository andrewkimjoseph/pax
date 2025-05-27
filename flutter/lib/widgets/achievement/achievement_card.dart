import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:pax/providers/db/achievement/achievement_provider.dart';
import 'package:pax/theming/colors.dart';
import 'package:pax/utils/gradient_border.dart';
import 'package:pax/models/firestore/achievement/achievement_model.dart';
import 'package:pax/services/achievement_service.dart';
import 'package:pax/providers/db/pax_account/pax_account_provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:intl/intl.dart';

class AchievementCard extends ConsumerStatefulWidget {
  const AchievementCard({required this.achievement, super.key});

  final Achievement achievement;

  @override
  ConsumerState<AchievementCard> createState() => _AchievementCardState();
}

class _AchievementCardState extends ConsumerState<AchievementCard> {
  bool _isClaiming = false;

  @override
  Widget build(BuildContext context) {
    final isEarned =
        widget.achievement.status == AchievementStatus.earned ||
        widget.achievement.status == AchievementStatus.claimed;
    final isClaimed = widget.achievement.status == AchievementStatus.claimed;

    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.all(8),
      decoration:
          isEarned
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
                              : 'G\$ ${widget.achievement.amountAwarded}',
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

                        if (isEarned &&
                            widget.achievement.timeCompleted != null)
                          Text(
                            'Earned on ${DateFormat('MMMM d, yyyy | h:mm a').format(widget.achievement.timeCompleted!.toDate())}',
                            style: TextStyle(
                              fontWeight: FontWeight.normal,
                              fontSize: 11,
                              color: PaxColors.black,
                            ),
                          ),

                        if (!isEarned)
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
              onPressed: _isClaiming ? null : _handleClaim,
              enabled: isEarned && !isClaimed && !_isClaiming,
              style:
                  isEarned && !isClaimed && !_isClaiming
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
                  _isClaiming
                      ? CircularProgressIndicator()
                      : Text(
                        isClaimed
                            ? 'Claimed G\$ ${widget.achievement.amountAwarded}'
                            : 'Claim G\$ ${widget.achievement.amountAwarded}',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                          color:
                              isEarned && !isClaimed && !_isClaiming
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
    if (_isClaiming) return;

    setState(() => _isClaiming = true);

    try {
      // Show claiming dialog
      if (!mounted) return;
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
                  Text(
                    'Claiming Achievement',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      color: PaxColors.black,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Please wait while we process your claim...',
                    style: TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 14,
                      color: PaxColors.black,
                    ),
                  ),
                ],
              ),
            ),
      );

      // Get the PAX account address from your provider
      final paxAccountContractAddress =
          ref.read(paxAccountProvider).account?.contractAddress;

      if (paxAccountContractAddress == null) {
        throw Exception('Pax account not found');
      }

      // Call the cloud function
      final achievementService = AchievementService();

      await achievementService.processAchievementClaim(
        achievementId: widget.achievement.id,
        paxAccountContractAddress: paxAccountContractAddress,
        amountEarned: widget.achievement.amountAwarded,
        tasksCompleted: widget.achievement.tasksCompleted,
      );

      ref.invalidate(achievementProvider);

      if (!mounted) return;
      context.pop();

      // Show success dialog
      if (!mounted) return;
      showDialog(
        context: context,
        builder:
            (dialogContext) => AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 48),
                  SizedBox(height: 16),
                  Text(
                    'Achievement Claimed!',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      color: PaxColors.black,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'You have successfully claimed G\$${widget.achievement.amountAwarded}',
                    style: TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 14,
                      color: PaxColors.black,
                    ),
                  ),
                  SizedBox(height: 24),
                  Button(
                    onPressed: () => Navigator.of(context).pop(),
                    style: const ButtonStyle.primary(),
                    child: const Text('Close'),
                  ),
                ],
              ),
            ),
      );
    } catch (e) {
      // Close the claiming dialog if it's open
      if (mounted && context.canPop()) {
        context.pop();
      }

      print(e.toString());

      // Show error dialog
      if (!mounted) return;
      showDialog(
        context: context,
        builder:
            (dialogContext) => AlertDialog(
              title: Text('Claim Failed'),
              content: Text(
                e.toString(),
                // maxLines: 3,
                // overflow: TextOverflow.ellipsis,
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('OK'),
                ),
              ],
            ),
      );
    } finally {
      if (mounted) {
        setState(() => _isClaiming = false);
      }
    }
  }
}

// lib/models/activity/activity_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:pax/exports/shadcn.dart';
import 'package:pax/models/firestore/reward/reward_model.dart';
import 'package:pax/models/firestore/task_completion/task_completion_model.dart';
import 'package:pax/models/firestore/withdrawal/withdrawal_model.dart';

enum ActivityType { taskCompletion, reward, withdrawal }

class Activity {
  final String id;
  final ActivityType type;
  final dynamic data; // TaskCompletion, Reward, or Withdrawal

  Activity({required this.id, required this.type, required this.data});

  // Convenience getters
  TaskCompletion? get taskCompletion =>
      type == ActivityType.taskCompletion ? data as TaskCompletion : null;
  Reward? get reward => type == ActivityType.reward ? data as Reward : null;
  Withdrawal? get withdrawal =>
      type == ActivityType.withdrawal ? data as Withdrawal : null;

  // Get timestamp for sorting activities
  Timestamp? get timestamp {
    switch (type) {
      case ActivityType.taskCompletion:
        return taskCompletion?.timeCompleted;
      case ActivityType.reward:
        return reward?.timeCreated;
      case ActivityType.withdrawal:
        return withdrawal?.timeCreated;
    }
  }

  // Get participant ID
  String? get participantId {
    switch (type) {
      case ActivityType.taskCompletion:
        return taskCompletion?.participantId;
      case ActivityType.reward:
        return reward?.participantId;
      case ActivityType.withdrawal:
        return withdrawal?.participantId;
    }
  }

  // Get title for display
  String getTitle() {
    switch (type) {
      case ActivityType.taskCompletion:
        return 'Task Completed';
      case ActivityType.reward:
        return 'Reward Earned';
      case ActivityType.withdrawal:
        return 'Withdrawal';
    }
  }

  // Get subtitle for display
  String getSubtitle() {
    switch (type) {
      case ActivityType.taskCompletion:
        return 'You completed a task';
      case ActivityType.reward:
        final reward = this.reward;
        return reward?.isPaidOutToPaxAccount == true
            ? 'Paid to your account'
            : 'Reward pending';
      case ActivityType.withdrawal:
        return 'Funds withdrawn';
    }
  }

  // Get amount for display
  String? getAmount() {
    final NumberFormat formatter = NumberFormat(
      '#,###',
      Intl.getCurrentLocale(),
    );

    if (type == ActivityType.reward && reward?.amountReceived != null) {
      return formatter.format(reward!.amountReceived!);
    } else if (type == ActivityType.withdrawal &&
        withdrawal?.amountTakenOut != null) {
      return formatter.format(withdrawal!.amountTakenOut!);
    }
    return null;
  }

  IconData? getIcon() {
    if (type == ActivityType.taskCompletion) {
      return FontAwesomeIcons.flagCheckered;
    }

    if (type == ActivityType.reward) {
      return FontAwesomeIcons.gift;
    }

    if (type == ActivityType.withdrawal) {
      return FontAwesomeIcons.solidMoneyBill1;
    }
    return null;
  }

  // Get currency ID
  int? getCurrencyId() {
    switch (type) {
      case ActivityType.taskCompletion:
        return null;
      case ActivityType.reward:
        return reward?.rewardCurrencyId;
      case ActivityType.withdrawal:
        return withdrawal?.rewardCurrencyId;
    }
  }

  // Get formatted date
  String getFormattedDate() {
    final ts = timestamp;
    if (ts == null) return 'N/A';

    final dateTime = ts.toDate();
    return DateFormat('MMM d, yyyy • h:mm a').format(dateTime);
  }

  // Get status for display
  String getStatus() {
    switch (type) {
      case ActivityType.taskCompletion:
        return 'completed';
      case ActivityType.reward:
        return reward?.isPaidOutToPaxAccount == true ? 'paid' : 'pending';
      case ActivityType.withdrawal:
        return 'processed';
    }
  }

  // Factory methods to create activities from different types

  factory Activity.fromTaskCompletion(TaskCompletion taskCompletion) {
    return Activity(
      id: taskCompletion.id,
      type: ActivityType.taskCompletion,
      data: taskCompletion,
    );
  }

  factory Activity.fromReward(Reward reward) {
    return Activity(id: reward.id, type: ActivityType.reward, data: reward);
  }

  factory Activity.fromWithdrawal(Withdrawal withdrawal) {
    return Activity(
      id: withdrawal.id,
      type: ActivityType.withdrawal,
      data: withdrawal,
    );
  }
}

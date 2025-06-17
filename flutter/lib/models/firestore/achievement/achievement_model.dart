import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pax/utils/achievement_constants.dart';

enum AchievementStatus { inProgress, earned, claimed }

class Achievement {
  final String id;
  final String? participantId;
  final String? name;
  final int tasksCompleted;
  final int tasksNeededForCompletion;
  final Timestamp? timeCreated;
  final Timestamp? timeCompleted;
  final Timestamp? timeClaimed;
  final num? amountEarned;
  final String? txnHash;

  Achievement({
    required this.id,
    this.participantId,
    this.name,
    required this.tasksCompleted,
    required this.tasksNeededForCompletion,
    this.timeCreated,
    this.timeCompleted,
    this.timeClaimed,
    this.amountEarned,
    this.txnHash,
  });

  // Computed properties
  AchievementStatus get status {
    if (txnHash != null) return AchievementStatus.claimed;
    if (amountEarned != null && timeCompleted != null) {
      return AchievementStatus.earned;
    }
    return AchievementStatus.inProgress;
  }

  String get goal {
    final isCompleted =
        status == AchievementStatus.earned ||
        status == AchievementStatus.claimed;
    switch (name) {
      case AchievementConstants.payoutConnector:
        return isCompleted
            ? 'Connected a payment method'
            : 'Connect a payment method';
      case AchievementConstants.verifiedHuman:
        return isCompleted
            ? 'Verified humanness on your connected payment method'
            : 'Verify humanness on your connected payment method';
      case AchievementConstants.profilePerfectionist:
        return isCompleted
            ? 'Filled in your phone number, gender, and date of birth'
            : 'Fill in your phone number, gender, and date of birth';
      case AchievementConstants.taskStarter:
        return isCompleted
            ? 'Completed $tasksNeededForCompletion task${tasksNeededForCompletion == 1 ? '' : 's'}'
            : 'Complete $tasksNeededForCompletion task${tasksNeededForCompletion == 1 ? '' : 's'}';
      case AchievementConstants.taskExpert:
        return isCompleted ? 'Completed 10 tasks' : 'Complete 10 tasks';
      default:
        return '';
    }
  }

  String get svgAssetName {
    switch (name) {
      case AchievementConstants.payoutConnector:
        return 'payout_connector';
      case AchievementConstants.verifiedHuman:
        return 'verified_human';
      case AchievementConstants.profilePerfectionist:
        return 'profile_perfectionist';
      case AchievementConstants.taskStarter:
        return 'task_starter';
      case AchievementConstants.taskExpert:
        return 'task_expert';
      default:
        return '';
    }
  }

  String get completionMessage {
    if (status == AchievementStatus.earned ||
        status == AchievementStatus.claimed) {
      return 'Earned on ${timeCompleted?.toDate().toString()}';
    }
    return '$tasksCompleted/$tasksNeededForCompletion';
  }

  // Factory method to create an Achievement from Firestore document
  factory Achievement.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;

    if (data == null) {
      return Achievement(
        id: doc.id,
        tasksCompleted: 0,
        tasksNeededForCompletion: 1,
      );
    }

    return Achievement(
      id: doc.id,
      participantId: data['participantId'],
      name: data['name'],
      tasksCompleted: data['tasksCompleted'] ?? 0,
      tasksNeededForCompletion: data['tasksNeededForCompletion'] ?? 1,
      timeCreated: data['timeCreated'],
      timeCompleted: data['timeCompleted'],
      timeClaimed: data['timeClaimed'],
      amountEarned: data['amountEarned'],
      txnHash: data['txnHash'],
    );
  }

  // Convert Achievement to a Map
  Map<String, dynamic> toMap() {
    return {
      'participantId': participantId,
      'name': name,
      'tasksCompleted': tasksCompleted,
      'tasksNeededForCompletion': tasksNeededForCompletion,
      'timeCreated': timeCreated,
      'timeCompleted': timeCompleted,
      'timeClaimed': timeClaimed,
      'amountEarned': amountEarned,
      'txnHash': txnHash,
    };
  }

  // Create a copy with updated values
  Achievement copyWith({
    String? id,
    String? participantId,
    String? name,
    int? tasksCompleted,
    int? tasksNeededForCompletion,
    Timestamp? timeCreated,
    Timestamp? timeCompleted,
    Timestamp? timeClaimed,
    num? amountEarned,
    String? txnHash,
  }) {
    return Achievement(
      id: id ?? this.id,
      participantId: participantId ?? this.participantId,
      name: name ?? this.name,
      tasksCompleted: tasksCompleted ?? this.tasksCompleted,
      tasksNeededForCompletion:
          tasksNeededForCompletion ?? this.tasksNeededForCompletion,
      timeCreated: timeCreated ?? this.timeCreated,
      timeCompleted: timeCompleted ?? this.timeCompleted,
      timeClaimed: timeClaimed ?? this.timeClaimed,
      amountEarned: amountEarned ?? this.amountEarned,
      txnHash: txnHash ?? this.txnHash,
    );
  }

  // Create an empty achievement
  factory Achievement.empty() {
    return Achievement(id: '', tasksCompleted: 0, tasksNeededForCompletion: 1);
  }

  bool get isEmpty => id.isEmpty;
  bool get isNotEmpty => !isEmpty;
}

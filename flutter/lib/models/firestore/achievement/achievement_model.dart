import 'package:cloud_firestore/cloud_firestore.dart';

enum AchievementStatus { inProgress, earned, claimed }

class Achievement {
  final String id;
  final String? participantId;
  final String? name;
  final int tasksCompleted;
  final int tasksNeededForCompletion;
  final Timestamp? timeCreated;
  final Timestamp? timeCompleted;
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
      case 'Payout Connector':
        return isCompleted
            ? 'Connected a payment method'
            : 'Connect a payment method';
      case 'Verified Human':
        return isCompleted
            ? 'Verified humanness on your connected payment method'
            : 'Verify humanness on your connected payment method';
      case 'Profile Perfectionist':
        return isCompleted
            ? 'Filled in your phone number, gender, and date of birth'
            : 'Fill in your phone number, gender, and date of birth';
      case 'Task Starter':
        return isCompleted
            ? 'Completed $tasksNeededForCompletion task${tasksNeededForCompletion == 1 ? '' : 's'}'
            : 'Complete $tasksNeededForCompletion task${tasksNeededForCompletion == 1 ? '' : 's'}';
      case 'Task Expert':
        return isCompleted ? 'Completed 10 tasks' : 'Complete 10 tasks';
      default:
        return '';
    }
  }

  String get svgAssetName {
    switch (name) {
      case 'Payout Connector':
        return 'payout_connector';
      case 'Verified Human':
        return 'verified_human';
      case 'Profile Perfectionist':
        return 'profile_perfectionist';
      case 'Task Starter':
        return 'task_starter';
      case 'Task Expert':
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

  // num get amountAwarded {
  //   switch (name) {
  //     case 'Payout Connector':
  //       return 100;
  //     case 'Verified Human':
  //       return 100;
  //     case 'Profile Perfectionist':
  //       return 100;
  //     case 'Task Starter':
  //       return 100;
  //     case 'Task Expert':
  //       return 1000;
  //     default:
  //       return 0;
  //   }
  // }

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

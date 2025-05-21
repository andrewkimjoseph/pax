// lib/models/task/task_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  final String id;
  final String? taskMasterId;
  final String? title;
  final String? type;
  final String? category;
  final int? estimatedTimeOfCompletionInMinutes;
  final Timestamp? deadline;
  final int? targetNumberOfParticipants;
  final String? link;
  final String? levelOfDifficulty;
  final String? managerContractAddress;
  final num? rewardAmountPerParticipant;
  final int? rewardCurrencyId;
  final bool? isAvailable;
  final Timestamp? timeCreated;
  final Timestamp? timeUpdated;
  final bool? isTest;

  Task({
    required this.id,
    this.taskMasterId,
    this.title,
    this.type = "General",
    this.category = "General",
    this.estimatedTimeOfCompletionInMinutes,
    this.deadline,
    this.targetNumberOfParticipants,
    this.link,
    this.levelOfDifficulty,
    this.managerContractAddress,
    this.rewardAmountPerParticipant,
    this.rewardCurrencyId,
    this.isAvailable,
    this.timeCreated,
    this.timeUpdated,
    this.isTest,
  });

  // Factory method to create a Task from Firestore document
  factory Task.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;

    if (data == null) {
      return Task(id: doc.id);
    }

    return Task(
      id: doc.id,
      taskMasterId: data['taskMasterId'],
      title: data['title'],
      type: data['type'] ?? 'general',
      category: data['category'] ?? 'general',
      estimatedTimeOfCompletionInMinutes:
          data['estimatedTimeOfCompletionInMinutes'],
      deadline: data['deadline'],
      targetNumberOfParticipants: data['targetNumberOfParticipants'],
      link: data['link'],
      levelOfDifficulty: data['levelOfDifficulty'],
      managerContractAddress: data['managerContractAddress'],
      rewardAmountPerParticipant: data['rewardAmountPerParticipant'],
      rewardCurrencyId: data['rewardCurrencyId'],
      isAvailable: data['isAvailable'],
      timeCreated: data['timeCreated'],
      timeUpdated: data['timeUpdated'],
      isTest: data['isTest'],
    );
  }

  // Convert Task to a Map
  Map<String, dynamic> toMap() {
    return {
      'taskMasterId': taskMasterId,
      'title': title,
      'type': type,
      'category': category,
      'estimatedTimeOfCompletionInMinutes': estimatedTimeOfCompletionInMinutes,
      'deadline': deadline,
      'targetNumberOfParticipants': targetNumberOfParticipants,
      'link': link,
      'levelOfDifficulty': levelOfDifficulty,
      'managerContractAddress': managerContractAddress,
      'rewardAmountPerParticipant': rewardAmountPerParticipant,
      'rewardCurrencyId': rewardCurrencyId,
      'isAvailable': isAvailable,
      'timeCreated': timeCreated,
      'timeUpdated': timeUpdated,
      'isTest': isTest,
    };
  }
}

// models/fcm/fcm_token_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class FCMToken {
  final String id;
  final String? participantId;
  final String? token;
  final Timestamp? timeCreated;
  final Timestamp? timeUpdated;

  FCMToken({
    required this.id,
    this.participantId,
    this.token,
    this.timeCreated,
    this.timeUpdated,
  });

  // Create a copy with updates
  FCMToken copyWith({
    String? participantId,
    String? token,
    Timestamp? timeUpdated,
  }) {
    return FCMToken(
      id: id,
      participantId: participantId ?? this.participantId,
      token: token ?? this.token,
      timeCreated: timeCreated,
      timeUpdated: timeUpdated ?? this.timeUpdated,
    );
  }

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'participantId': participantId,
      'token': token,
      'timeCreated': timeCreated,
      'timeUpdated': timeUpdated,
    };
  }

  // Create from Firestore data
  factory FCMToken.fromMap(Map<String, dynamic> map, {required String id}) {
    return FCMToken(
      id: id,
      participantId: map['participantId'],
      token: map['token'],
      timeCreated: map['timeCreated'],
      timeUpdated: map['timeUpdated'],
    );
  }

  // Create an empty token model
  factory FCMToken.empty() {
    return FCMToken(id: '');
  }

  bool get isEmpty => id.isEmpty;
  bool get isNotEmpty => !isEmpty;
}

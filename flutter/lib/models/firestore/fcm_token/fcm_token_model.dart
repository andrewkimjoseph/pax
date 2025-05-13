// models/fcm/fcm_token_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class FcmTokenModel {
  final String id;
  final String? participantId;
  final String? token;
  final Timestamp? timeCreated;
  final Timestamp? timeUpdated;

  FcmTokenModel({
    required this.id,
    this.participantId,
    this.token,
    this.timeCreated,
    this.timeUpdated,
  });

  // Create a copy with updates
  FcmTokenModel copyWith({
    String? participantId,
    String? token,
    Timestamp? timeUpdated,
  }) {
    return FcmTokenModel(
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
  factory FcmTokenModel.fromMap(
    Map<String, dynamic> map, {
    required String id,
  }) {
    return FcmTokenModel(
      id: id,
      participantId: map['participantId'],
      token: map['token'],
      timeCreated: map['timeCreated'],
      timeUpdated: map['timeUpdated'],
    );
  }

  // Create an empty token model
  factory FcmTokenModel.empty() {
    return FcmTokenModel(id: '');
  }

  bool get isEmpty => id.isEmpty;
  bool get isNotEmpty => !isEmpty;
}

import 'package:cloud_firestore/cloud_firestore.dart';

class ParticipantModel {
  final String id;
  final String? displayName;
  final String? emailAddress;
  final String? phoneNumber;
  final String? gender;
  final String? country;
  final Timestamp? dateOfBirth;
  final String? profilePictureURI;
  final String? goodDollarWalletAddress;
  final String? goodDollarIdentityExpiryData;
  final Timestamp? timeCreated;
  final Timestamp? timeUpdated;
  final String? _createdBy;
  final String? _updatedBy;

  ParticipantModel({
    required this.id,
    this.displayName,
    this.emailAddress,
    this.phoneNumber,
    this.gender,
    this.country,
    this.dateOfBirth,
    this.profilePictureURI,
    this.goodDollarWalletAddress,
    this.goodDollarIdentityExpiryData,
    this.timeCreated,
    this.timeUpdated,
    String? createdBy,
    String? updatedBy,
  }) : _createdBy = createdBy,
       _updatedBy = updatedBy;

  // Create a copy of this participant with modified fields
  ParticipantModel copyWith({
    String? displayName,
    String? emailAddress,
    String? phoneNumber,
    String? gender,
    String? country,
    Timestamp? dateOfBirth,
    String? profilePictureURI,
    String? goodDollarWalletAddress,
    String? goodDollarIdentityExpiryData,
    Timestamp? timeUpdated,
    String? updatedBy,
  }) {
    return ParticipantModel(
      id: id,
      displayName: displayName ?? this.displayName,
      emailAddress: emailAddress ?? this.emailAddress,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      gender: gender ?? this.gender,
      country: country ?? this.country,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      profilePictureURI: profilePictureURI ?? this.profilePictureURI,
      goodDollarWalletAddress:
          goodDollarWalletAddress ?? this.goodDollarWalletAddress,
      goodDollarIdentityExpiryData:
          goodDollarIdentityExpiryData ?? this.goodDollarIdentityExpiryData,
      timeCreated: timeCreated,
      timeUpdated: timeUpdated ?? this.timeUpdated,
      createdBy: _createdBy,
      updatedBy: updatedBy ?? _updatedBy,
    );
  }

  // Convert model to a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'displayName': displayName,
      'emailAddress': emailAddress,
      'phoneNumber': phoneNumber,
      'gender': gender,
      'country': country,
      'dateOfBirth': dateOfBirth,
      'profilePictureURI': profilePictureURI,
      'goodDollarWalletAddress': goodDollarWalletAddress,
      'goodDollarIdentityExpiryData': goodDollarIdentityExpiryData,
      'timeCreated': timeCreated,
      'timeUpdated': timeUpdated,
      '_createdBy': _createdBy,
      '_updatedBy': _updatedBy,
    };
  }

  // Create a model from a Firestore map
  factory ParticipantModel.fromMap(
    Map<String, dynamic> map, {
    required String id,
  }) {
    return ParticipantModel(
      id: id,
      displayName: map['displayName'],
      emailAddress: map['emailAddress'],
      phoneNumber: map['phoneNumber'],
      gender: map['gender'],
      country: map['country'],
      dateOfBirth: map['dateOfBirth'],
      profilePictureURI: map['profilePictureURI'],
      goodDollarWalletAddress: map['goodDollarWalletAddress'],
      goodDollarIdentityExpiryData: map['goodDollarIdentityExpiryData'],
      timeCreated: map['timeCreated'],
      timeUpdated: map['timeUpdated'],
      createdBy: map['_createdBy'],
      updatedBy: map['_updatedBy'],
    );
  }

  // Create an empty participant model
  factory ParticipantModel.empty() {
    return ParticipantModel(id: '');
  }

  // Check if this is an empty participant
  bool get isEmpty => id.isEmpty;
  bool get isNotEmpty => !isEmpty;
}

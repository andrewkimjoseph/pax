import 'package:cloud_firestore/cloud_firestore.dart';

class Participant {
  final String id;
  final String? displayName;
  final String? emailAddress;
  final String? phoneNumber;
  final String? gender;
  final String? country;
  final Timestamp? dateOfBirth;
  final String? profilePictureURI;
  final Timestamp? goodDollarIdentityTimeLastAuthenticated;
  final Timestamp? goodDollarIdentityExpiryDate;

  final Timestamp? timeCreated;
  final Timestamp? timeUpdated;

  Participant({
    required this.id,
    this.displayName,
    this.emailAddress,
    this.phoneNumber,
    this.gender,
    this.country,
    this.dateOfBirth,
    this.profilePictureURI,
    this.goodDollarIdentityTimeLastAuthenticated,
    this.goodDollarIdentityExpiryDate,

    this.timeCreated,
    this.timeUpdated,
    String? createdBy,
    String? updatedBy,
  });

  // Create a copy of this participant with modified fields
  Participant copyWith({
    String? displayName,
    String? emailAddress,
    String? phoneNumber,
    String? gender,
    String? country,
    Timestamp? dateOfBirth,
    String? profilePictureURI,
    Timestamp? goodDollarIdentityTimeLastAuthenticated,
    Timestamp? goodDollarIdentityExpiryDate,

    Timestamp? timeUpdated,
  }) {
    return Participant(
      id: id,
      displayName: displayName ?? this.displayName,
      emailAddress: emailAddress ?? this.emailAddress,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      gender: gender ?? this.gender,
      country: country ?? this.country,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      profilePictureURI: profilePictureURI ?? this.profilePictureURI,
      goodDollarIdentityTimeLastAuthenticated:
          goodDollarIdentityTimeLastAuthenticated ??
          this.goodDollarIdentityTimeLastAuthenticated,
      goodDollarIdentityExpiryDate:
          goodDollarIdentityExpiryDate ?? this.goodDollarIdentityExpiryDate,
      timeCreated: timeCreated,
      timeUpdated: timeUpdated ?? this.timeUpdated,
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
      'goodDollarIdentityTimeLastAuthenticated':
          goodDollarIdentityTimeLastAuthenticated,
      'goodDollarIdentityExpiryDate': goodDollarIdentityExpiryDate,
      'timeCreated': timeCreated,
      'timeUpdated': timeUpdated,
    };
  }

  // Create a model from a Firestore map
  factory Participant.fromMap(Map<String, dynamic> map, {required String id}) {
    return Participant(
      id: id,
      displayName: map['displayName'],
      emailAddress: map['emailAddress'],
      phoneNumber: map['phoneNumber'],
      gender: map['gender'],
      country: map['country'],
      dateOfBirth: map['dateOfBirth'],
      profilePictureURI: map['profilePictureURI'],
      goodDollarIdentityTimeLastAuthenticated:
          map['goodDollarIdentityTimeLastAuthenticated'],
      goodDollarIdentityExpiryDate: map['goodDollarIdentityExpiryDate'],
      timeCreated: map['timeCreated'],
      timeUpdated: map['timeUpdated'],
      createdBy: map['_createdBy'],
      updatedBy: map['_updatedBy'],
    );
  }

  // Create an empty participant model
  factory Participant.empty() {
    return Participant(id: '');
  }

  // Check if this is an empty participant
  bool get isEmpty => id.isEmpty;
  bool get isNotEmpty => !isEmpty;
}

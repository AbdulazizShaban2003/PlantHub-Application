// features/profile/domain/models/profile_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileModel {
  final String? uid;
  final String name;
  final String email;
  final String phoneNumber;
  final String countryCode;
  final String gender;
  final DateTime? birthdate;
  final String? profileImagePath;

  ProfileModel({
    this.uid,
    required this.name,
    required this.email,
    required this.phoneNumber,
    this.countryCode = '+1',
    this.gender = 'Male',
    this.birthdate,
    this.profileImagePath,
  });

  factory ProfileModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProfileModel(
      uid: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      countryCode: data['countryCode'] ?? '+1',
      gender: data['gender'] ?? 'Male',
      birthdate: data['birthdate']?.toDate(),
      profileImagePath: data['profileImagePath'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'countryCode': countryCode,
      'gender': gender,
      'birthdate': birthdate != null ? Timestamp.fromDate(birthdate!) : null,
      'profileImagePath': profileImagePath,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  ProfileModel copyWith({
    String? name,
    String? email,
    String? phoneNumber,
    String? countryCode,
    String? gender,
    DateTime? birthdate,
    String? profileImagePath,
  }) {
    return ProfileModel(
      uid: uid,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      countryCode: countryCode ?? this.countryCode,
      gender: gender ?? this.gender,
      birthdate: birthdate ?? this.birthdate,
      profileImagePath: profileImagePath ?? this.profileImagePath,
    );
  }
}
// features/profile/domain/repositories/profile_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../data/profile_model.dart';

abstract class ProfileRepository {
  Future<ProfileModel> getProfile();
  Future<void> updateProfile(ProfileModel profile);
  Future<String?> getProfileImage();
  Future<void> saveProfileImage(String imagePath);
}

// features/profile/data/repositories/profile_repository_impl.dart

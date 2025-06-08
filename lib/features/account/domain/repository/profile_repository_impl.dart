import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:plant_hub_app/features/account/domain/repository/profile_repository.dart';

import '../../../../core/cache/cache_helper.dart';
import '../../../../core/service/service_locator.dart';
import '../../data/profile_model.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  ProfileRepositoryImpl({
    required FirebaseAuth auth,
    required FirebaseFirestore firestore
  })  : _auth = auth,
        _firestore = firestore;

  @override
  Future<ProfileModel> getProfile() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final doc = await _firestore.collection('users').doc(user.uid).get();

    if (!doc.exists) {
      final defaultProfile = ProfileModel(
        uid: user.uid,
        name: user.displayName ?? '',
        email: user.email ?? '',
        phoneNumber: '',
      );
      await _firestore.collection('users').doc(user.uid).set(defaultProfile.toMap());
      return defaultProfile;
    }

    return ProfileModel.fromFirestore(doc);
  }

  @override
  Future<void> updateProfile(ProfileModel profile) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    await _firestore.collection('users').doc(user.uid).update(profile.toMap());
  }

  @override
  Future<String?> getProfileImage() async {
    return sl<CacheHelper>().getData(key: 'profile_image_path');
  }

  @override
  Future<void> saveProfileImage(String imagePath) async {
    await sl<CacheHelper>().saveData(key: 'profile_image_path', value:imagePath);

  }
}
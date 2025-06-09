import 'package:flutter/material.dart';

import '../../data/profile_model.dart';
import '../../domain/repository/profile_repository.dart';

class ProfileProvider with ChangeNotifier {
  final ProfileRepository _repository;

  ProfileModel? _profile;
  bool _isLoading = false;
  String? _profileImagePath;

  ProfileProvider(this._repository);

  ProfileModel? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get profileImagePath => _profileImagePath;

  Future<void> loadProfile() async {
    _isLoading = true;
    notifyListeners();

    try {
      _profile = await _repository.getProfile();
      _profileImagePath = await _repository.getProfileImage();
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile(ProfileModel updatedProfile) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _repository.updateProfile(updatedProfile);
      _profile = updatedProfile;
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfileImage(String imagePath) async {
    try {
      await _repository.saveProfileImage(imagePath);
      _profileImagePath = imagePath;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }


}
// auth_remote_data_source.dart
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../../core/utils/app_strings.dart';
import '../models/user_model.dart';

class AuthRemoteDataSource {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  Timer? _tokenRefreshTimer;

  Future<UserModel> signUpWithEmailAndPassword({
    required String name,
    required String email,
    required String password,
  }) async {
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await userCredential.user!.sendEmailVerification();

    final user = UserModel(
      id: userCredential.user!.uid,
      name: name,
      email: email,
    );

    await _firestore
        .collection('users')
        .doc(userCredential.user!.uid)
        .set(user.toMap());

    return user;
  }

  void _startTokenAutoRefresh(User user) {
    _tokenRefreshTimer?.cancel();
    _tokenRefreshTimer = Timer.periodic(const Duration(minutes: 55), (_) async {
      try {
        await user.getIdToken(true);
      } catch (e) {
        debugPrint('${AppStrings.tokenRefreshError}$e');
      }
    });
  }

  Future<UserModel> loginWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final userCredential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    _startTokenAutoRefresh(userCredential.user!);

    final userDoc = await _firestore
        .collection('users')
        .doc(userCredential.user!.uid)
        .get();

    if (!userDoc.exists) {
      throw Exception(AppStrings.userDataNotFound);
    }

    return UserModel.fromMap(userDoc.data()!, userDoc.id);
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> sendEmailVerification() async {
    await _auth.currentUser?.sendEmailVerification();
  }

  Future<bool> checkEmailVerification() async {
    await _auth.currentUser?.reload();
    return _auth.currentUser?.emailVerified ?? false;
  }

  Future<UserModel> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      throw Exception(AppStrings.googleSignInCancelled);
    }

    final GoogleSignInAuthentication googleAuth =
    await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential = await _auth.signInWithCredential(credential);
    final isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;

    if (isNewUser) {
      final user = UserModel(
        id: userCredential.user!.uid,
        name: userCredential.user!.displayName ?? AppStrings.noName,
        email: userCredential.user!.email ?? '',
      );

      await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .set(user.toMap());

      return user;
    } else {
      final userDoc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (!userDoc.exists) {
        throw Exception(AppStrings.userDataNotFound);
      }

      return UserModel.fromMap(userDoc.data()!, userDoc.id);
    }
  }

  Future<void> signOut() async {
    _tokenRefreshTimer?.cancel();
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
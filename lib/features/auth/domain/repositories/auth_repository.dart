import '../../data/models/user_model.dart';

abstract class AuthRepository {
  Future<UserModel> signUpWithEmailAndPassword({
    required String name,
    required String email,
    required String password,
  });

  Future<UserModel> loginWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<void> sendPasswordResetEmail(String email);
  Future<UserModel> signInWithGoogle();

}
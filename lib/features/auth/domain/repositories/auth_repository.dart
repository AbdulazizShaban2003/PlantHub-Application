import 'package:dartz/dartz.dart';
import '../../data/models/user_model.dart';

abstract class AuthRepository {
  Future<Either<String, UserModel>> signUpWithEmailAndPassword({
    required String name,
    required String email,
    required String password,
  });

  Future<Either<String, UserModel>> loginWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<Either<String, Unit>> sendPasswordResetEmail(String email);

  Future<Either<String, Unit>> sendEmailVerification();

  Future<Either<String, bool>> checkEmailVerification();

  Future<Either<String, UserModel>> signInWithGoogle();

  Future<Either<String, Unit>> signOut();
}
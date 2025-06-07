import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/datasources/auth_remote_data_source.dart';
import '../../data/models/user_model.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<String, UserModel>> loginWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final user = await remoteDataSource.loginWithEmailAndPassword(
        email: email,
        password: password,
      );
      return Right(user);
    } on FirebaseAuthException catch (e) {
      return Left(e.message ?? 'Authentication failed. Please check your credentials.');
    } catch (e) {
      return Left('An unexpected error occurred during login');
    }
  }

  @override
  Future<Either<String, UserModel>> signUpWithEmailAndPassword({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final user = await remoteDataSource.signUpWithEmailAndPassword(
        name: name,
        email: email,
        password: password,
      );
      await remoteDataSource.sendEmailVerification();
      return Right(user);
    } on FirebaseAuthException catch (e) {
      return Left(e.message ?? 'Registration failed. Please try again.');
    } catch (e) {
      return Left('An unexpected error occurred during registration');
    }
  }

  @override
  Future<Either<String, Unit>> sendPasswordResetEmail(String email) async {
    try {
      await remoteDataSource.sendPasswordResetEmail(email);
      return const Right(unit);
    } on FirebaseAuthException catch (e) {
      return Left(e.message ?? 'Failed to send password reset email');
    } catch (e) {
      return Left('An unexpected error occurred while sending reset email');
    }
  }

  @override
  Future<Either<String, Unit>> sendEmailVerification() async {
    try {
      await remoteDataSource.sendEmailVerification();
      return const Right(unit);
    } on FirebaseAuthException catch (e) {
      return Left(e.message ?? 'Failed to send verification email');
    } catch (e) {
      return Left('An unexpected error occurred while sending verification email');
    }
  }

  @override
  Future<Either<String, bool>> checkEmailVerification() async {
    try {
      final isVerified = await remoteDataSource.checkEmailVerification();
      return Right(isVerified);
    } on FirebaseAuthException catch (e) {
      return Left(e.message ?? 'Failed to check email verification status');
    } catch (e) {
      return Left('An unexpected error occurred while checking verification status');
    }
  }

  @override
  Future<Either<String, UserModel>> signInWithGoogle() async {
    try {
      final user = await remoteDataSource.signInWithGoogle();
      return Right(user);
    } on FirebaseAuthException catch (e) {
      return Left(e.message ?? 'Google sign in failed');
    } catch (e) {
      return Left('An unexpected error occurred during Google sign in');
    }
  }

  @override
  Future<Either<String, Unit>> signOut() async {
    try {
      await remoteDataSource.signOut();
      return const Right(unit);
    } on FirebaseAuthException catch (e) {
      return Left(e.message ?? 'Sign out failed');
    } catch (e) {
      return Left('An unexpected error occurred during sign out');
    }
  }
}
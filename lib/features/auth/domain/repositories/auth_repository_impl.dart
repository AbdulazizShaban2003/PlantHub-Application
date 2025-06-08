import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/utils/app_strings.dart';
import '../../data/datasources/auth_remote_data_source.dart';
import '../../data/models/user_model.dart';
import 'auth_repository.dart' show AuthRepository;

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
      return Left(e.message ?? AppStrings.authFailed);
    } catch (e) {
      return Left(AppStrings.unexpectedLoginError);
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
      return Left(e.message ?? AppStrings.registrationFailed);
    } catch (e) {
      return Left(AppStrings.unexpectedRegistrationError);
    }
  }

  @override
  Future<Either<String, Unit>> sendPasswordResetEmail(String email) async {
    try {
      await remoteDataSource.sendPasswordResetEmail(email);
      return const Right(unit);
    } on FirebaseAuthException catch (e) {
      return Left(e.message ?? AppStrings.passwordResetFailed);
    } catch (e) {
      return Left(AppStrings.unexpectedResetError);
    }
  }

  @override
  Future<Either<String, Unit>> sendEmailVerification() async {
    try {
      await remoteDataSource.sendEmailVerification();
      return const Right(unit);
    } on FirebaseAuthException catch (e) {
      return Left(e.message ?? AppStrings.verificationEmailFailed);
    } catch (e) {
      return Left(AppStrings.unexpectedVerificationError);
    }
  }

  @override
  Future<Either<String, bool>> checkEmailVerification() async {
    try {
      final isVerified = await remoteDataSource.checkEmailVerification();
      return Right(isVerified);
    } on FirebaseAuthException catch (e) {
      return Left(e.message ?? AppStrings.checkVerificationFailed);
    } catch (e) {
      return Left(AppStrings.unexpectedCheckVerificationError);
    }
  }

  @override
  Future<Either<String, UserModel>> signInWithGoogle() async {
    try {
      final user = await remoteDataSource.signInWithGoogle();
      return Right(user);
    } on FirebaseAuthException catch (e) {
      return Left(e.message ?? AppStrings.googleSignInFailed);
    } catch (e) {
      return Left(AppStrings.unexpectedGoogleSignInError);
    }
  }

  @override
  Future<Either<String, Unit>> signOut() async {
    try {
      await remoteDataSource.signOut();
      return const Right(unit);
    } on FirebaseAuthException catch (e) {
      return Left(e.message ?? AppStrings.signOutFailed);
    } catch (e) {
      return Left(AppStrings.unexpectedSignOutError);
    }
  }
}
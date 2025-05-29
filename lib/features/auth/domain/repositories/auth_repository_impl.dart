import '../../data/datasources/auth_remote_data_source.dart';
import '../../data/models/user_model.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<UserModel> loginWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return await remoteDataSource.loginWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  @override
  Future<UserModel> signUpWithEmailAndPassword({
    required String name,
    required String email,
    required String password,
  }) async {
    return await remoteDataSource.signUpWithEmailAndPassword(
      name: name,
      email: email,
      password: password,
    );
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await remoteDataSource.sendPasswordResetEmail(email);
  }
  @override
  Future<UserModel> signInWithGoogle() async {
    return await remoteDataSource.signInWithGoogle();
  }
}
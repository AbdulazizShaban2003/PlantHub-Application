import '../repositories/auth_repository.dart';
import '../../data/models/user_model.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase({required this.repository});

  Future<UserModel> call({
    required String email,
    required String password,
  }) async {
    return await repository.loginWithEmailAndPassword(
      email: email,
      password: password,
    );
  }
}